# InfluxDB2.x nutzen

## Debian Versionsunterschiede

Während die Firewall unter allen Debian Versionen problemlos funktioniert, gibt es wesentliche Unterschiede im Aufbau der Logfiles, welches einen Unterschiedlichen Aufbau der Scripte notwendig macht.

Unter Debian 11 funktioniert das Script **php-live-influx.php**

Mit Debian 12 kann nur das Script **php-live-influx-d12.php** genutzt werden.

Als **todo** steht derzeit Debian 13 auf meiner Liste, das folgt dann in den nächsten Wochen.

Die Scripte sind nur mit InfluxDB2.x getestet.

Voraussetzung:
 * Betriebsbereiter InfluxDB2 Server
 * php cli auf dem Router/Firewall installiert
 * zum Auswerten eine funktionierende Grafana Instanz, die auf den InfluxDB2 Server zugreifen kann

## Einrichten systemd

Du musst natürlich den Pfad zur php-live-influx.php anpassen, bevor du auf der Shell den neuen Dienst einfügen und einschalten kannst.

````bash
sudo tee /etc/systemd/system/firewall-influx.service > /dev/null << 'EOF'
[Unit]
Description=Firewall Log to InfluxDB
After=network.target

[Service]
ExecStart=/usr/bin/php /usr/local/bin/php-live-influx-d12.php
Restart=always
RestartSec=5
User=root
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
````
Danach nur noch die nachfolgenden Zeilen ausführen und der Dienst sollte starten.

````conf
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now firewall-influx.service


systemctl status firewall-influx.service
journalctl -u firewall-influx.service
````

## InfluxDB

Die hier angeführten Auszüge sind die jeweiligen Script-Daten, welche in der Umgebung innerhalb des Webfrontends zur Abfrage der InfluxDB benutzt werden können.

````conf
from(bucket: "iptables")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) =>
    r._measurement == "firewall_log" and
    r._field == "count"
  )
  |> aggregateWindow(every: 1m, fn: sum, createEmpty: true)
  |> group(columns: ["action"])
  |> yield(name: "action_per_hour")
````

````conf
from(bucket: "iptables")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) =>
    r._measurement == "firewall_log" and
    r._field == "count"
  )
  |> group(columns: ["proto"])
  |> aggregateWindow(every: 5m, fn: sum, createEmpty: false)
  |> yield(name: "blocked_ports")
````

## PieChart Grafana

````conf
from(bucket: "iptables")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) =>
    r._measurement == "firewall_log" and
    r._field == "count"
  )
  |> group(columns: ["proto"])
  |> aggregateWindow(every: 5m, fn: sum, createEmpty: false)
  |> yield(name: "blocked_ports")
````

## Time Series Grafana

````conf
from(bucket: "iptables")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) =>
    r._measurement == "firewall_log" and
    r._field == "count"
  )
  |> group(columns: ["proto"])
  |> aggregateWindow(every: 5m, fn: sum, createEmpty: false)
  |> yield(name: "blocked_ports")
````
