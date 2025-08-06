#!/usr/bin/env bash
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

# Main-Rules for the Router
# The router is only supposed to transport packets (transport).
# Exceptions may be incoming (input) requests for ping,
# which it may also answer (output).
# Important! The firewall also blocks the communication to itself,
# i.e. localhost, and must therefore also be specified!

# Der Router soll eigentlich nur Pakete transportieren (FORWARD).
# Ausnahmen sind unter Umständen eingehende (Input) Anfragen
# nach Ping, die er auch beantworten darf (Output).
# Wichtig! Die Firewall blockiert auch die Kommunikation mit sich selbst,
# also localhost und muss demnach ebenfalls angegeben werden!

## Allen lokalen Diensten erlauben irgend wo hin zu gehen (Updates z.B.)
$FW -A OUTPUT -o lo -j ACCEPT
## Du darfst auch selbst rumpingen .... ;o)
$FW -A OUTPUT -p icmp -j ACCEPT                                         # ping

# Der Router muss auch selbst kommunizieren dürfen
$FW -A OUTPUT -p tcp -o $DEV_EXTERN -m multiport --dport 80,443,9418 -j ACCEPT		## http, https, git -> Internet/Updates

$FW -A OUTPUT -p udp --dport 53 -d $DNS_INTERN1 -j ACCEPT		## DNS Serverabfrage zulassen nur intern
$FW -A OUTPUT -o $DEV_INTERN -d $DNS_INTERN1 -p udp -m multiport --dport 67,68 -j ACCEPT	# DHCP
$FW -A OUTPUT -o $DEV_INTERN -p udp -m multiport --dport 123 -j ACCEPT	# NTP

# Spezialfall proxy_pass mit Nginx und Zugriff auf Webserver in der DMZ
$FW -A OUTPUT -p tcp -o $DEV_INTERN -m multiport --dport 25,80,3000 -j ACCEPT		## Proxy-Weiterleitungen, Mail

## Tor Netzwerk
$FW -A OUTPUT -p tcp -o $DEV_EXTERN -m multiport --dport 9001 -j ACCEPT		## Tor
$FW -A OUTPUT -p tcp -o $DEV_INTERN -m multiport --dport 6100 -j ACCEPT		## Tor


## Alles was einmal rausgelassen wurde, darf auch zurück antworten
$FW -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
## Alles was falsch läuft loggen
$FW -A OUTPUT $LOG_LIMITER -j LOG --log-prefix "[FW] DENY-OUTPUT-ACCESS "
## und verwerfen
$FW -A OUTPUT -j DROP
