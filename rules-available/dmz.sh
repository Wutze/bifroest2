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


