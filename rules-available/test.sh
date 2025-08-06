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

#
# Simple Firewall-Script with iptables
# only IPv4
# Your private Description

rulename="TEST"
count=$(( $count + 1 ))
forwardrule[$count]="$rulename"
$FW -N $rulename
current_object_s[$count]="192.168.100.10/32"
current_object_d[$count]=""
