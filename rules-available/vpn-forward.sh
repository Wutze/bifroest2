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
rulename="VPN-FORWARD"

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
current_object_s[$count]="10.8.0.0/24"
## Destination Host or Net
current_object_d[$count]="0.0.0.0/0"
########################################################

####### VPN Zugriffe
$FW -A $rulename -i $DEV_INTERN -d $NET_VPN0 -j ACCEPT		##
$FW -A $rulename -o $DEV_EXTERN -s $NET_VPN0 -j ACCEPT		##

$FW -A $rulename -s $NET_VPN0 -o $DEV_DMZ1 -j ACCEPT
$FW -A $rulename -s $NET_VPN0 -o $DEV_LAN1 -j ACCEPT

## VPN DMZ - läuft
$FW -t nat -I PREROUTING -p udp -i $DEV_EXTERN --dport 1194 -j DNAT --to 172.16.16.108	##
$FW -t nat -I PREROUTING -p udp -i $DEV_DMZ1 --dport 1194 -j DNAT --to 172.16.16.108	##
$FW -I FORWARD -i $DEV_EXTERN -d 172.16.16.108 -j ACCEPT







