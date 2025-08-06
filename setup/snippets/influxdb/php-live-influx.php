<?php
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
    ]);

    $response = curl_exec($ch);
    $error = curl_errno($ch);
    curl_close($ch);
    return $error === 0;
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

    // Schreibe nur übrig gebliebene zurück
    file_put_contents($bufferFile, implode("\n", $remaining) . "\n");
}

$fp = popen("tail -F $logfile", 'r');
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

        if (preg_match('/^([A-Z][a-z]{2})\s+(\d{1,2})\s+(\d{2}:\d{2}:\d{2})\s+\S+\s+kernel:.*\[FW\]\s+([^\s]+).*IN=([^\s]*) OUT=([^\s]*) .*SRC=([^\s]+) DST=([^\s]+).*PROTO=([^\s]+) SPT=(\d+) DPT=(\d+)/', $line, $m)) {
            [$full, $mon, $day, $timeStr, $action, $in, $out, $src, $dst, $proto, $sport, $dport] = $m;

            $monthNum = [
                'Jan'=>1, 'Feb'=>2, 'Mar'=>3, 'Apr'=>4, 'May'=>5, 'Jun'=>6,
                'Jul'=>7, 'Aug'=>8, 'Sep'=>9, 'Oct'=>10, 'Nov'=>11, 'Dec'=>12
            ][$mon];

            $year = date('Y');
            $timestamp = strtotime(sprintf('%04d-%02d-%02d %s', $year, $monthNum, (int)$day, $timeStr)) * 1_000_000_000;

            $action = influx_escape_tag($action);
            $proto = influx_escape_tag($proto);
            $in = influx_escape_tag($in);
            $out = influx_escape_tag($out);
            $src = influx_escape_field_string($src);
            $dst = influx_escape_field_string($dst);

            $tags = [
                "action=$action",
                "proto=$proto",
                'out_if=' . ($out ?: 'false'),
                'in_if='  . ($in  ?: 'false')
            ];
            $tagString = implode(",", $tags);
            $fieldString = "src=$src,dst=$dst,src_port=$sport,dst_port=$dport,count=1";

            $lineproto = "firewall_log,$tagString $fieldString $timestamp";

            if (!send_to_influx($lineproto, $influxUrl, $token)) {
                // Fehler -> in Datei zwischenspeichern
                file_put_contents($bufferFile, $lineproto . "\n", FILE_APPEND);
                echo "Daten gepuffert (Server nicht erreichbar)\n";
            } else {
                retry_unsent_lines($bufferFile, $influxUrl, $token);
            }
        }
    }
}