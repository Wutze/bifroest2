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

$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.100 -p tcp -m multiport --dport 80,443 -j ACCEPT	## GabiPhone
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.100 -p udp -m multiport --dport 53 -j ACCEPT		##
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.100 -p tcp -m multiport --dport 53 -j ACCEPT		##

$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.101 -p tcp -m multiport --dport 53,80,443,1935,8080,64738 -j ACCEPT	## MicroPhone
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.101 -p udp -m multiport --dport 53 -j ACCEPT		## dns
$FW -A $rulename -i $DEV_INTERN -o $DEV_DMZ1 -s 192.168.104.101 -d 172.16.16.57 -j ACCEPT		## pbx
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.101 -p udp -m multiport --dport 1194 -j ACCEPT	## vpn von innen aufbauen lassen

$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.102 -p tcp -m multiport --dport 80,443 -j ACCEPT	## AlexPhone
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.102 -p udp -m multiport --dport 53 -j ACCEPT		##
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.102 -p tcp -m multiport --dport 53 -j ACCEPT		##

$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.103 -p tcp -m multiport --dport 80,443 -j ACCEPT	## InaPhone
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.103 -p udp -m multiport --dport 53 -j ACCEPT		##
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.103 -p tcp -m multiport --dport 53 -j ACCEPT		##

$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.105 -p tcp -m multiport --dport 80,443 -j ACCEPT	## Medion Pad
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.105 -p udp -m multiport --dport 53,80,443,123 -j ACCEPT		##
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.105 -p tcp -m multiport --dport 53,80,443,123 -j ACCEPT		##

$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.106 -p tcp -m multiport --dport 80,443,1935 -j ACCEPT	## Monster Notebook
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.106 -p udp -m multiport --dport 53,80,443,123 -j ACCEPT		##
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.106 -p tcp -m multiport --dport 53,80,443,123 -j ACCEPT		##

$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.107 -p tcp -m multiport --dport 80,443 -j ACCEPT	## YazanPhone
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.107 -p udp -m multiport --dport 53 -j ACCEPT		##
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.107 -p tcp -m multiport --dport 53 -j ACCEPT		##

$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.108 -p tcp -m multiport --dport 80,443,993 -j ACCEPT	## mail.home 
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.108 -p udp -m multiport --dport 11335 -j ACCEPT	## mail.home rspamd 

########################################################
