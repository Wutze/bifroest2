<?php

/**
 * für Debian 12
 * das hat ein anderes Zeitformat
 */

$logfile = '/var/log/iptables.log';
$bucket = 'iptables';
$org = 'xVPN';
$token = 'vMVROfvqDd5RHc8gLSXS3YrzqZgDUEhltrXs3DKo4KvF5hXu7pWL4BrGXn4f-LwyBBYhkOjRdlRj6ehdWRlNWg==';

$influxUrl = 'http://db2.home:8086/api/v2/write?org=' . urlencode($org) . '&bucket=' . urlencode($bucket);
$bufferFile = '/tmp/unsent_firewall_logs.txt';

function influx_escape_tag($value) {
    return str_replace(['\\', ' ', ',', '='], ['\\\\', '\\ ', '\\,', '\\='], $value);
}

function influx_escape_field_string($value) {
    return '"' . str_replace(['\\', '"'], ['\\\\', '\\"'], $value) . '"';
}

function send_to_influx($lineproto, $influxUrl, $token) {
    $ch = curl_init($influxUrl);
    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_HTTPHEADER => ["Authorization: Token $token"],
        CURLOPT_POSTFIELDS => $lineproto,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 5,
    ]);

    $response = curl_exec($ch);
    $error = curl_errno($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    return ($error === 0 && $httpCode === 204);
}

function retry_unsent_lines($bufferFile, $influxUrl, $token) {
    if (!file_exists($bufferFile)) return;

    $lines = file($bufferFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    if (!$lines) return;

    $remaining = [];
    foreach ($lines as $line) {
        if (!send_to_influx($line, $influxUrl, $token)) {
            $remaining[] = $line;
        }
    }

    // Schreibe nur die übrig gebliebenen Zeilen zurück
    file_put_contents($bufferFile, implode("\n", $remaining) . (count($remaining) ? "\n" : ""));
}

function check_influx_health($host, $token) {
    $ch = curl_init("$host/health");
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => ["Authorization: Token $token"],
        CURLOPT_TIMEOUT => 5,
    ]);

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error = curl_errno($ch);
    curl_close($ch);

    if ($error !== 0) {
        echo "❌ InfluxDB nicht erreichbar: Netzwerkfehler\n";
        return false;
    }

    if ($httpCode !== 200) {
        echo "❌ InfluxDB antwortet mit HTTP $httpCode\n";
        return false;
    }

    $data = json_decode($response, true);
    if (isset($data['status']) && $data['status'] === 'pass') {
        echo "✅ InfluxDB ist erreichbar und gesund\n";
        return true;
    }

    echo "⚠️ Antwort von InfluxDB: $response\n";
    return false;
}

// Healthcheck durchführen
if (!check_influx_health('http://db2.home:8086', $token)) {
    echo "Starte trotzdem – Logs werden ggf. gepuffert.\n";
}

// Tail starten
$fp = popen("tail -n0 -F $logfile", 'r'); // -n0 = keine alten Zeilen, nur neue
stream_set_blocking($fp, false);

while (true) {
    $read = [$fp];
    $write = $except = [];

    if (stream_select($read, $write, $except, 1)) {
        $line = fgets($fp);
        if ($line === false) {
            usleep(100_000);
            continue;
        }

        // Debug: Zeile ausgeben
        echo "RAW: $line\n";

        // Regex für Debian 12 / PHP 8.2 Logs
        if (preg_match(
            '/^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+\+\d{2}:\d{2})\s+\S+\s+kernel:\s+\[\s*\d+\.\d+\]\s+\[FW\]\s+([^\s]+)\s+IN=([^\s]*)\s+OUT=([^\s]*)\s+.*SRC=([^\s]+)\s+DST=([^\s]+)\s+.*PROTO=([^\s]+)\s+SPT=(\d+)\s+DPT=(\d+)/',
            $line, $m
        )) {
            [$full, $timestampStr, $action, $in, $out, $src, $dst, $proto, $sport, $dport] = $m;

            // Zeitstempel in Nanosekunden für Influx
            $dt = new DateTime($timestampStr);
            $timestamp = (int)$dt->format('U') * 1_000_000_000 + (int)($dt->format('u')) * 1_000;

            // Tags & Fields
            $action = influx_escape_tag($action);
            $proto  = influx_escape_tag($proto);
            $in     = influx_escape_tag($in ?: 'false');
            $out    = influx_escape_tag($out ?: 'false');
            $src    = influx_escape_field_string($src);
            $dst    = influx_escape_field_string($dst);
            $sport  = (int)$sport;
            $dport  = (int)$dport;

            $tags = "action=$action,proto=$proto,in_if=$in,out_if=$out";
            $fields = "src=$src,dst=$dst,src_port=$sport,dst_port=$dport,count=1";

            $lineproto = "firewall_log,$tags $fields $timestamp";

            // Senden & Pufferung
            if (!send_to_influx($lineproto, $influxUrl, $token)) {
                file_put_contents($bufferFile, $lineproto . "\n", FILE_APPEND);
                echo "Daten gepuffert (Server nicht erreichbar)\n";
            } else {
                retry_unsent_lines($bufferFile, $influxUrl, $token);
            }
        }
    }
}