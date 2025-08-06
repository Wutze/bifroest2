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

rulename="SRV-INT"
count=$(( $count + 1 ))
forwardrule[$count]="$rulename"
## Container"$rulename" definieren
$FW -N $rulename
########################################################
current_object_s[$count]="192.168.104.0/26"
current_object_d[$count]="0.0.0.0/0"

# Dinge die innerhalb des Inranets umfassend erlaubt sind
$FW -A $rulename -i $DEV_INTERN -o $DEV_DMZ1 -p tcp -m multiport --dport 22,80,443 -j ACCEPT	## HHTP/S, SSH -> DMZ1
$FW -A $rulename -i $DEV_INTERN -o $DEV_DMZ1 -p icmp -j ACCEPT		## icmp
$FW -A $rulename -i $DEV_INTERN -o $DEV_LAN1 -p tcp -m multiport --dport 22,53,80,443 -j ACCEPT	## HHTP/S, SSH -> LAN1
$FW -A $rulename -i $DEV_INTERN -o $DEV_LAN1 -p icmp -j ACCEPT		## icmp
$FW -A $rulename -i $DEV_INTERN -o $DEV_LAN1 -p udp -m multiport --dport 53 -j ACCEPT	## zu DNS3
$FW -A $rulename -i $DEV_INTERN -o $DEV_LAN2 -p tcp -m multiport --dport 22,80,443 -j ACCEPT	## HHTP/S, SSH -> LAN2
$FW -A $rulename -i $DEV_INTERN -o $DEV_LAN2 -p icmp -j ACCEPT		## icmp
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -p tcp -m multiport --dport 22,80,443 -j ACCEPT	## HHTP/S, SSH -> INTERN
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -p icmp -j ACCEPT		## icmp

$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.9 -p tcp -m multiport --dport 80,443,9418 -j ACCEPT	## Neuer Router
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.9 -p udp -m multiport --dport 53 -j ACCEPT		##
$FW -A $rulename -i $DEV_INTERN -o $DEV_INTERN -s 192.168.104.9 -p tcp -m multiport --dport 53 -j ACCEPT		##

$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.11 -d $DNS1 -p tcp -m multiport --dport 53 -j ACCEPT            ## DNS1
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.11 -d $DNS2 -p tcp -m multiport --dport 53 -j ACCEPT            ## DNS1
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.11 -d $DNS3 -p tcp -m multiport --dport 53 -j ACCEPT            ## DNS1
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.11 -d $DNS1 -p udp -m multiport --dport 53 -j ACCEPT            ## DNS1
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.11 -d $DNS2 -p udp -m multiport --dport 53 -j ACCEPT            ## DNS1
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.11 -d $DNS3 -p udp -m multiport --dport 53 -j ACCEPT            ## DNS1

$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.15 -p udp -m multiport --dport 123 -j ACCEPT            ## NTP-Server


## Proxmox
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.15 -p tcp -m multiport --dport 80,443 -j ACCEPT          ## proxmox updates

## für die Updates des Servers
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.11 -p tcp -m multiport --dport 80,443 -j ACCEPT          ## midgard.home
## 11371 - keyserver?
$FW -A $rulename -i $DEV_INTERN -o $DEV_EXTERN -s 192.168.104.12 -p tcp -m multiport --dport 80,443,11371 -j ACCEPT          ## wlan0.raspi.home

## VPN
$FW -A $rulename -i $DEV_INTERN -d $NET_VPN0 -j ACCEPT		# VPN

## Route in die DMZ
$FW -A $rulename -i $DEV_INTERN -o $DEV_DMZ1 -d 172.16.16.0/24 -j ACCEPT		## udp

## Route ins LAN1
$FW -A $rulename -i $DEV_INTERN -o $DEV_LAN1 -s 192.168.104.11 -j ACCEPT		##

########################################################
