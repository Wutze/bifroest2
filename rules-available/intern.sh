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

rulename="INTERN"

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
current_object_s[$count]="192.168.104.64/26"
## 64 -127
## Destination Host or Net
current_object_d[$count]="0.0.0.0/0"
########################################################

## Intern darf alles
$FW -A $rulename -i $DEV_INTERN -o $DEV_DMZ1 -j ACCEPT
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -j ACCEPT
$FW -A $rulename -i $DEV_INTERN -o $DEV_LAN1 -j ACCEPT

$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -d 8.8.8.8 -j DROP
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -p udp -m multiport --dport 53 -j DROP		## DNS extern
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -p tcp -m multiport --dport 53 -j DROP		## DNS extern

$FW -A $rulename -i $DEV_INTERN -o $DEV_DMZ1 -p tcp -m multiport --dport 22,80,443 -j ACCEPT	## HTTP/S, SSH -> DMZ
$FW -A $rulename -i $DEV_INTERN -o $DEV_LAN1 -p tcp -m multiport --dport 22,53,80,443,1880 -j ACCEPT	## HHTP/S, SSH -> LAN1
$FW -A $rulename -i $DEV_INTERN -o $DEV_LAN1 -p udp -m multiport --dport 53 -j ACCEPT	## DNS zu DNS3

$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -p udp -m multiport --dport 123 -j DROP		##



########################################################
