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

# ================================
# Ncurses-basiertes Setup-Skript
# für firewall.conf
# ================================

TARGET="firewall.conf"
SAMPLE="firewall.conf.sample"
TMPFILE=$(mktemp)

if [ -f "$TARGET" ]; then
    dialog --yesno "$TARGET existiert bereits. Überschreiben?" 8 40 || exit 1
fi

# Externe Schnittstelle automatisch ermitteln
DEFAULT_DEV_EXTERN=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i=="dev") print $(i+1)}' | head -n1)

# Funktion: Dialog für Eingabe mit Default
ask() {
    local varname="$1"
    local prompt="$2"
    local default="$3"

    dialog --inputbox "$prompt" 8 60 "$default" 2> "$TMPFILE"
    local result=$(<"$TMPFILE")
    if [ -n "$result" ]; then
        printf '%s="%s"\n' "$varname" "$result" >> "$TARGET"
    fi
}

# Beginn Konfig
echo "#!/usr/bin/env bash" > "$TARGET"
echo "# generiert mit dialog am $(date)" >> "$TARGET"
echo >> "$TARGET"

echo 'DEFAULT_STATUS="DROP"' >> "$TARGET"
echo 'DEBUG_FW=1' >> "$TARGET"

cat >> "$TARGET" <<EOF

case \$DEBUG_FW in
    0) LOG_LIMITER="-m limit";;
    1) LOG_LIMITER="";;
esac

EOF

# Netzwerkgeräte
ask DEV_INTERN   "Name der internen Schnittstelle (z. B. ens18):"
ask DEV_EXTERN   "Name der externen Schnittstelle:" "$DEFAULT_DEV_EXTERN"
ask DEV_DMZ1     "Name der DMZ-Schnittstelle (z. B. ens20):"
ask DEV_LAN1     "Name der LAN1-Schnittstelle:"
ask DEV_LAN2     "LAN2 (optional):"
ask DEV_LAN3     "LAN3 (optional):"

# Netzwerke
ask NET_INTERN   "Internes Netz (CIDR, z. B. 192.168.104.0/24):"
ask NET_LAN1     "LAN1 Netz (z. B. 10.10.10.0/24):"
ask NET_LAN2     "LAN2 Netz (optional):"
ask NET_LAN3     "LAN3 Netz (optional):"
ask NET_DMZ1     "DMZ Netz (z. B. 172.16.16.0/24):"
ask NET_VPN0     "VPN Netz (z. B. 10.8.0.0/24):"

# VPN-User
ask PRIVATE_VPN1 "OpenVPN User-IP (z. B. 10.8.0.6):"
ask PRIVATE_VPN2 "OpenVPN User-IP 2 (optional):"
ask PRIVATE_VPN3 "OpenVPN User-IP 3 (optional):"
ask PRIVATE_VPN4 "OpenVPN User-IP 4 (optional):"

# DNS
ask DNS1         "Primärer externer DNS (z. B. 1.1.1.1):"
ask DNS2         "Sekundärer externer DNS (z. B. 9.9.9.9):"
ask DNS3         "Optionaler externer DNS:"
ask DNS_INTERN1  "Interner DNS1 (z. B. 192.168.104.11):"
ask DNS_INTERN2  "Interner DNS2 (optional):"

# Firewall-Tool
echo 'FW="iptables"' >> "$TARGET"

chmod +x "$TARGET"
dialog --msgbox "Konfiguration gespeichert in $TARGET" 7 40
clear