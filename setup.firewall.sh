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

# Ziel-Datei überschreiben?
if [ -f "$TARGET" ]; then
    read -p "$TARGET existiert bereits. Überschreiben? [j/N]: " confirm
    [[ "$confirm" =~ ^[Jj]$ ]] || exit 1
fi

# Externe Schnittstelle automatisch ermitteln
DEFAULT_DEV_EXTERN=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i=="dev") print $(i+1)}' | head -n1)

# Funktion: Eingabe mit optionalem Default
ask() {
    local varname="$1"
    local prompt="$2"
    local default="$3"
    local input

    if [ -n "$default" ]; then
        read -p "$prompt [$default]: " input
        input="${input:-$default}"
    else
        read -p "$prompt: " input
    fi

    printf '%s="%s"\n' "$varname" "$input" >> "$TARGET"
}

# Beginn Konfig
echo "#!/usr/bin/env bash" > "$TARGET"
echo "# generiert am $(date)" >> "$TARGET"
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
ask DEV_INTERN   "Name der internen Schnittstelle (z. B. ens18)"
ask DEV_EXTERN   "Name der externen Schnittstelle (z.B. ppp0)" "$DEFAULT_DEV_EXTERN"
ask DEV_DMZ1     "Name der DMZ-Schnittstelle (z. B. ens20)"

# Netzwerke
ask NET_INTERN   "Internes Netz (CIDR, z. B. 192.168.104.0/24)"


# DNS
ask DNS1         "Primärer externer DNS (z. B. 1.1.1.1)"
ask DNS2         "Sekundärer externer DNS (z. B. 9.9.9.9)"
ask DNS3         "Optionaler externer DNS"
ask DNS_INTERN1  "Interner DNS1 (z. B. 192.168.104.11)"
ask DNS_INTERN2  "Interner DNS2 (optional)"

# Firewall-Tool
echo 'FW="iptables"' >> "$TARGET"

chmod +x "$TARGET"

echo
echo "Konfiguration gespeichert in $TARGET"