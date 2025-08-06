#!/bin/bash
#
# Simple Firewall-Script with iptables
# only IPv4
#
# (c) by Wutze 2006-25 Version 4.0 as bifroest2
#
# This file is copyright under the latest version of the EUPL.
# Please see LICENSE file for your rights under this license.
# Version 1.x
#
# Twitter -> @HuWutze
# Repo: github

# Datei wertet das am Monatsende angelegte Logfile aus
# und zeigt auf der Konsole die Top 20 bzw. Top 10 an
# zudem die verwendeten Ports und die Aktionen, die du in deinen Regeln definiert hast

LOGFILE="/var/log/iptables.log.1"  # Passe den Pfad ggf. an

echo "Top 20 Quell-IPs:"
grep -oP 'SRC=\K[\d.]+' "$LOGFILE" | sort | uniq -c | sort -nr | head -20

echo ""
echo "Top 20 Ziel-IPs:"
grep -oP 'DST=\K[\d.]+' "$LOGFILE" | sort | uniq -c | sort -nr | head -20

echo ""
echo "Top 20 Ziel-Ports:"
grep -oP 'DPT=\K\d+' "$LOGFILE" | sort | uniq -c | sort -nr | head -20

echo ""
echo "Verwendete Protokolle:"
grep -oP 'PROTO=\K\w+' "$LOGFILE" | sort | uniq -c | sort -nr

echo ""
echo "Firewall Chains (ACTIONs):"
grep -oP '\[FW\] \K[A-Z_-]+' "$LOGFILE" | sort | uniq -c | sort -nr

## Kurzerklärung für unbekannte Protokolle
## Diese Zahl ist ein Eintrag aus der offiziellen IANA-Protokollnummerntabelle
# 4     IP-in-IP (IPv4 encapsulation)
# 41	IPv6 encapsulation
# 47	GRE (Generic Routing Encapsulation)
# 78	MTP (Multicast Transport Protocol) (veraltet, kaum genutzt)
# 0	    HOPOPT (IPv6 hop-by-hop option, selten)

## entweder - oder verwenden
## der obere Teil gibt es nur auf der Konsole aus
## der untere Teil wird dann nur als Mail versendet
## klar, du kannst auch beides haben ;o)

( 
    printf "\nTop 20 Quell-IPs:\n\n"
    grep -oP 'SRC=\K[\d.]+' "$LOGFILE" | sort | uniq -c | sort -nr | head -20

    printf "\nTop 20 Ziel-IPs:"
    grep -oP 'DST=\K[\d.]+' "$LOGFILE" | sort | uniq -c | sort -nr | head -20


    printf "\nTop 20 Ziel-Ports:"
    grep -oP 'DPT=\K\d+' "$LOGFILE" | sort | uniq -c | sort -nr | head -20

    printf "\nVerwendete Protokolle:"
    grep -oP 'PROTO=\K\w+' "$LOGFILE" | sort | uniq -c | sort -nr

    printf "\nFirewall Chains (ACTIONs):"
    grep -oP '\[FW\] \K[A-Z_-]+' "$LOGFILE" | sort | uniq -c | sort -nr

) | mail -s "Top 20 - Iptables Bericht" micro@mail.home






