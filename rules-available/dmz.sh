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

## Zwingend einzutragen
## Eintrag sollte unique sein!
rulename="DMZ"

## nicht verändern
## Diese beiden Zeilen erzeugen ein Array, welches in der "ende.sh" eingelesen und
## und entsprechend verarbeitet wird.
count=$(( $count + 1 ))
forwardrule[$count]="$rulename"
## Container"$rulename" definieren
$FW -N $rulename
########################################################
## Angabe ob das Regelset für ein Netzwerk zuständig sein soll oder nur für einen Host
## Wird diese Variable nicht gesetzt oder ist nicht vorhanden, wird das Script
## zwar ordentlich funktionieren, das Logging aber wird nicht korrekt angezeigt,
## da die Firewall sonst nicht nach den einzelnen Netzwerken unterscheiden kann
## Zudem wird "current_object_s" für das definieren der Rückrouten benötigt,
## damit der Router weiß, wohin die Antwortpakete gesendet werden dürfen.
## "current_object_d" kann jedoch leer bleiben.
######
## Source Host or Net
current_object_s[$count]="172.16.16.0/24"
## Destination Host or Net
current_object_d[$count]="0.0.0.0/0"
########################################################

## Diese Einträge sind ausschließlich für die Update- bzw. Installationsfunktionen der 
## einzelnen Virtuellen Maschinen gedacht! Anpassungen sind daher noch notwendig
## wie das Ziel beispielsweise.
#$FW -A $rulename -p tcp -i $DEV_DMZ1 -o $DEV_INTERN -m multiport --dport 53,80,443 -j ACCEPT ## DNS,HTTP/S
#$FW -A $rulename -p udp -i $DEV_DMZ1 -o $DEV_INTERN -m multiport --dport 53 -j ACCEPT ## DNS

## Intern darf alles
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_DMZ1 -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_LAN1 -j ACCEPT

$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -p udp -m multiport --dport 123 -j ACCEPT		# NTP fürs Netz zulassen nach ntp.home

$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -d 192.168.104.11 -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_LAN1 -p udp -m multiport --dport 53 -j ACCEPT	## DNS zu DNS3

## Webserver DMZ
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_EXTERN -s 172.16.16.50 -p tcp -m multiport --dport 80,443 -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.50 -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_LAN1 -s 172.16.16.50 -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_LAN2 -s 172.16.16.50 -j ACCEPT

$FW -A OUTPUT -o $DEV_DMZ1 -d 172.16.16.50 -j ACCEPT	# Tor-Service

## Webserver2 DMZ
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_EXTERN -s 172.16.16.49 -p tcp -m multiport --dport 80,443 -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.49 -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_LAN1 -s 172.16.16.49 -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_LAN2 -s 172.16.16.49 -j ACCEPT

## Telefonanlage DMZ alt
#$FW -A $rulename -i $DEV_DMZ1 -o $DEV_EXTERN -s 172.16.16.57 -p udp -m multiport --dport 5060 -j ACCEPT		# SIP Telekom
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_EXTERN -s 172.16.16.57 -j ACCEPT		# SIP Telekom
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.57 -d 192.168.104.11  -j ACCEPT		# DNS
#$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.57 -d 192.168.104.13  -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.57 -d 192.168.104.2  -j ACCEPT		# PC Webconsole
#$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.57 -d 192.168.104.104 -j ACCEPT		# Telefon
$FW -A $rulename -i $DEV_DMZ1 -s 172.16.16.57 -d $NET_VPN0 -j ACCEPT		# Telefon -> VPN
$FW -A $rulename -i $DEV_DMZ1 -s 172.16.16.57 -d $NET_INTERN -j ACCEPT		# Telefon -> VPN

## Telefonanlage DMZ pbx.home neu
#$FW -A $rulename -i $DEV_DMZ1 -o $DEV_EXTERN -s 172.16.16.56 -p udp -m multiport --dport 5060 -j ACCEPT		# SIP Telekom
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_EXTERN -s 172.16.16.56 -j ACCEPT		# SIP Telekom
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.56 -d 192.168.104.11  -j ACCEPT		# DNS
#$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.56 -d 192.168.104.13  -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.56 -d 192.168.104.2  -j ACCEPT		# PC Webconsole
#$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.56 -d 192.168.104.104 -j ACCEPT		# Telefon
$FW -A $rulename -i $DEV_DMZ1 -s 172.16.16.56 -d $NET_VPN0 -j ACCEPT		# Telefon -> VPN
$FW -A $rulename -i $DEV_DMZ1 -s 172.16.16.56 -d $NET_INTERN -j ACCEPT		# Telefon -> VPN

## Reserve Telefonanlage DMZ pbx.home
#$FW -A $rulename -i $DEV_DMZ1 -o $DEV_EXTERN -s 172.16.16.56 -p udp -m multiport --dport 5060 -j ACCEPT		# SIP Telekom
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_EXTERN -s 172.16.16.48 -j ACCEPT		# SIP Telekom
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.48 -d 192.168.104.11  -j ACCEPT		# DNS
#$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.56 -d 192.168.104.13  -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.48 -d 192.168.104.2  -j ACCEPT		# PC Webconsole
#$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.56 -d 192.168.104.104 -j ACCEPT		# Telefon
$FW -A $rulename -i $DEV_DMZ1 -s 172.16.16.48 -d $NET_VPN0 -j ACCEPT		# Telefon -> VPN
$FW -A $rulename -i $DEV_DMZ1 -s 172.16.16.48 -d $NET_INTERN -j ACCEPT		# Telefon -> VPN

$FW -A $rulename -i $DEV_INTERN -o $DEV_DMZ1 -d 172.16.16.25 -j ACCEPT		## gitlab2
$FW -A $rulename -o $DEV_INTERN -i $DEV_DMZ1 -s 172.16.16.25 -j ACCEPT		## gitlab2

## Leaks DMZ
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_EXTERN -s 172.16.16.23 -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.23 -j ACCEPT
#$FW -A $rulename -i $DEV_DMZ1 -o $DEV_LAN1 -s 172.16.16.50 -j ACCEPT
#$FW -A $rulename -i $DEV_DMZ1 -o $DEV_LAN2 -s 172.16.16.50 -j ACCEPT

## mail2 (neuer Maislerver)
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_EXTERN -s 172.16.16.24 -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.24 -j ACCEPT

## Windows 7
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.133 -j ACCEPT
#$FW -A $rulename -i $DEV_DMZ1 -o $DEV_EXTERN -s 172.16.16.133 -j ACCEPT ## temporär zulassen wegen iPad

## Shop DMZ
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_EXTERN -s 172.16.16.138 -p tcp -m multiport --dport 80,443 -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.138 -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_LAN1 -s 172.16.16.138 -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_LAN2 -s 172.16.16.138 -j ACCEPT

## Shop2 DMZ
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_EXTERN -s 172.16.16.8 -p tcp -m multiport --dport 80,443 -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.8 -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_LAN1 -s 172.16.16.8 -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_LAN2 -s 172.16.16.8 -j ACCEPT

## VPN-Server innerhalb DMZ - VPN2
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_EXTERN -s 172.16.16.108 -p tcp -m multiport --dport 80,443 -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_INTERN -s 172.16.16.108 -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_LAN1 -s 172.16.16.108 -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_LAN2 -s 172.16.16.108 -j ACCEPT
$FW -A $rulename -i $DEV_DMZ1 -o $DEV_EXTERN -s 172.16.16.108 -p udp --dport 10000:20000 -j ACCEPT # RTP Scheiße
#$FW -A $rulename -i $DEV_DMZ1 -o $DEV_EXTERN -s 172.16.16.108 -p udp --dport 10000:20000 -j ACCEPT # RTP Scheiße

## temp SSH
#$FW -t nat -I PREROUTING -p tcp -i $DEV_EXTERN --dport 5555 -j DNAT --to 172.16.16.50:22	##
#$FW -t nat -I PREROUTING -p tcp -i $DEV_DMZ --dport 5555 -j DNAT --to 172.16.16.50:22	##
#$FW -I FORWARD -i $DEV_EXTERN -d 172.16.16.50 -j ACCEPT

#$FW -A FORWARD -i $DEV_EXTERN -p tcp --sport 5555 -d 172.16.16.50 -m state --state NEW -j ACCEPT
#$FW -t nat -A PREROUTING -i $DEV_EXTERN -p tcp --dport 5555 -j DNAT --to-destination 172.16.11.50:22
#$FW -A FORWARD -i $DEV_EXTERN -p tcp --sport ICMP -d 172.16.16.50 -m state --state NEW -j ACCEPT

#$FW -I FORWARD -i $DEV_EXTERN -d 172.16.16.50 -j ACCEPT
