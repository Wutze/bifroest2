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
rulename="UNUSED_FREE_IP"

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
## Source Host or Net (129-190)
current_object_s[$count]="192.168.104.128/26"
## Destination Host or Net
current_object_d[$count]="0.0.0.0/0"
########################################################


$FW -A $rulename -i $DEV_INTERN -o $DEV_DMZ1 -j ACCEPT
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -j ACCEPT
$FW -A $rulename -i $DEV_INTERN -o $DEV_LAN1 -j ACCEPT

#$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.129 -p tcp -m multiport --dport 80,443 -j ACCEPT ## Discourse Board

$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.131 -p tcp -m multiport --dport 80,443 -j ACCEPT	## Tina Phone
#$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.131 -p udp -m multiport --dport 53 -j ACCEPT		##
#$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.131 -p tcp -m multiport --dport 53 -j ACCEPT		##

$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.137 -p tcp -m multiport --dport 80,443,993 -j ACCEPT	## iPAD
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.137 -p udp -m multiport --dport 53 -j ACCEPT		##
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.137 -p tcp -m multiport --dport 53 -j ACCEPT		##

$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.140 -p tcp -m multiport --dport 80,443 -j ACCEPT	## GalaxyPAD
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.140 -p udp -m multiport --dport 53 -j ACCEPT		##
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.140 -p tcp -m multiport --dport 53 -j ACCEPT		##

$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.147 -p tcp -m multiport --dport 80,443 -j ACCEPT	## PetraNotebook
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.147 -p udp -m multiport --dport 53 -j ACCEPT		##
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.147 -p tcp -m multiport --dport 53 -j ACCEPT		##
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.148 -p tcp -m multiport --dport 80,443 -j ACCEPT	## PetraNotebook
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.148 -p udp -m multiport --dport 53 -j ACCEPT		##
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.148 -p tcp -m multiport --dport 53 -j ACCEPT		##
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.149 -p tcp -m multiport --dport 80,443 -j ACCEPT	## PetraNotebook
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.149 -p udp -m multiport --dport 53 -j ACCEPT		##
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.149 -p tcp -m multiport --dport 53 -j ACCEPT		##

## Ports 4244,5222,5223,5228 für Whatsapp
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.150 -p tcp -m multiport --dport 80,443,4244,5222,5223,5224,5228 -j ACCEPT	## JanPhone
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.150 -p udp -m multiport --dport 53 -j ACCEPT		##
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.150 -p tcp -m multiport --dport 53 -j ACCEPT		##
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.151 -p tcp -m multiport --dport 80,443,993,4244,5222,5223,5228 -j ACCEPT	## AndiPhone
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.151 -p udp -m multiport --dport 53 -j ACCEPT		##
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.151 -p tcp -m multiport --dport 53 -j ACCEPT		##
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.152 -p tcp -m multiport --dport 80,443,4244,5222,5223,5224,5228 -j ACCEPT	## JanPhone
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.152 -p udp -m multiport --dport 53 -j ACCEPT		##
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.152 -p tcp -m multiport --dport 53 -j ACCEPT		##

