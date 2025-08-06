<?php
$logfile = '/var/log/iptables.log';
//$logfile = '/var/log/testlog.log';

$bucket = 'iptables';
//$bucket = 'firewall';
$org = 'xVPN';
$token = 'vMVROfvqDd5RHc8gLSXS3YrzqZgDUEhltrXs3DKo4KvF5hXu7pWL4BrGXn4f-LwyBBYhkOjRdlRj6ehdWRlNWg==';


// Konfiguration
$influxUrl = 'http://db2.home:8086/api/v2/write?org=' . urlencode($org) . '&bucket=' . urlencode($bucket) . '&precision=s';
$influxUrl = 'http://db2.home:8086/api/v2/write?org=' . urlencode($org) . '&bucket=' . urlencode($bucket) . '';

$handle = fopen($logfile, 'r');
if (!$handle) {
    die("Kann Logdatei nicht öffnen: $logfile\n");
}

function influx_escape_tag($value) {
    return str_replace(
        ['\\', ' ', ',', '='],
        ['\\\\', '\\ ', '\\,', '\\='],
        $value
    );
}

function influx_escape_field_string($value) {
    // Feldwerte (Strings) in doppelte Anführungszeichen, Escapen von " mit \"
    $escaped = str_replace(['\\', '"'], ['\\\\', '\\"'], $value);
    return "\"$escaped\"";
}



while (($line = fgets($handle)) !== false) {
    // Beispiel: Parsing mit Regex
if (preg_match('/^([A-Z][a-z]{2})\s+(\d{1,2})\s+(\d{2}:\d{2}:\d{2})\s+\S+\s+kernel:.*\[FW\]\s+([^\s]+).*IN=([^\s]*) OUT=([^\s]*) .*SRC=([^\s]+) DST=([^\s]+).*PROTO=([^\s]+) SPT=(\d+) DPT=(\d+)/', $line, $m)) {
    [$full, $mon, $day, $timeStr, $action, $in, $out, $src, $dst, $proto, $sport, $dport] = $m;
    $monthNum = ['Jan'=>1, 'Feb'=>2, 'Mar'=>3, 'Apr'=>4, 'May'=>5, 'Jun'=>6, 'Jul'=>7, 'Aug'=>8, 'Sep'=>9, 'Oct'=>10, 'Nov'=>11, 'Dec'=>12][$mon];
    $year = date('Y'); // Optional: Logjahr dynamisch bestimmen
    $timestamp = strtotime(sprintf('%04d-%02d-%02d %s', $year, $monthNum, (int)$day, $timeStr));

    $timestamp = $timestamp * 1000000000;


$action = influx_escape_tag($action);
$proto = influx_escape_tag($proto);
$in = influx_escape_tag($in);
$out = influx_escape_tag($out);
$src = influx_escape_field_string($src);
$dst = influx_escape_field_string($dst);
$sport = (int)$sport;
$dport = (int)$dport;
$count = 1;

// Tags bauen
$tags = [
    "action=$action",
    "proto=$proto",
];


$false="false";
if (!empty($out)) {
    $tags[] = "out_if=$out";
}else{
    $tags[] = "out_if=$false";
}

if (!empty($in)) {
    $tags[] = "in_if=$in";
}else{

    $tags[] = "in_if=$false";
}

//print_r($tags);
//exit;



$tagString = implode(",", $tags);
$fieldString = "src=$src,dst=$dst,src_port=$sport,dst_port=$dport,count=1";

$line = "firewall_log,$tagString $fieldString $timestamp";


    // Line Protocol
//    $lineProtocol = "firewall_log,action=$action,proto=$proto,in_if=$in,out_if=$out,src=$src,dst=$dst,src_port=$sport,dst_port=$dport $timestamp";
    $lineProtocol = "firewall_log,$tagString src=$src,dst=$dst,src_port=$sport,dst_port=$dport,count=1 $timestamp";

//echo $lineProtocol."\n";
//$lineProtocol = $line;
//echo $lineProtocol."\n";
//exit;


       // An Influx senden
        $ch = curl_init($influxUrl);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Token ' . $token,
            'Content-Type: text/plain',
        ]);
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $lineProtocol);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        $response = curl_exec($ch);
        if (curl_errno($ch)) {
            echo "Fehler beim Senden: " . curl_error($ch) . "\n";
        } 
//else {
//    echo "Influx-Antwort: " . $response . "\n";
//}

        curl_close($ch);
    }
}

fclose($handle);
