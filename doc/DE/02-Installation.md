# Installation

## Die Grundinstallation im System ist denkbar einfach

Nachdem du das Projekt in einem von dir favorisierten Ordner gespeichert hast, sind noch einige Anpassungen zu machen.

* kopiere Datei /snipptes/rsyslog.d/iptables.conf nach /etc/rsyslog.d/iptables.conf

Hiermit erreichst du, dass alle Firewallbezogenen Meldungen nicht mehr ins Syslog geschrieben werden sondern in eine eigene Datei. Das erleichtert dir am Ende viel Arbeit und du kannst die Einträge problemlos auswerten. (siehe auch die Abschnitte influxdb2 und Grafana)

* kopiere Datei /snippets/init.d/microwall nach /etc/init.d/microwall

Damit kannst du nun auf altbekannte Weise die Firewall starten und stoppen. Du kannst der Datei auch jeden anderen Namen geben. Einzig der Pfad zum Script muss an deine Ordnerstruktur angepasst werden!

* kopiere Datei /logrotate.d/iptables nach /etc/logrotate.d/iptables

Das wird zum Monatsanfang eine neue iptables.log im Ordner /var/log/ anlegen, die alte sichern und packen. Die Einstellung ist so festgelegt, dass die Logdateien 12 Monate in gepackter Form aufbewahrt werden.
