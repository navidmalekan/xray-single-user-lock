#!/usr/bin/env bash
set -euo pipefail

NFT_FILE="/etc/nftables.d/xray-concurrency.nft"
SYNC_SCRIPT="/usr/local/sbin/xray-listenports-sync.sh"
SERVICE="/etc/systemd/system/xray-listenports-sync.service"
TIMER="/etc/systemd/system/xray-listenports-sync.timer"

print_menu() {
  clear
  echo "====================================="
  echo " Xray nftables Port Lock Manager"
  echo "====================================="
  echo "1) Install / Reinstall"
  echo "2) Verify Status"
  echo "3) Monitoring"
  echo "4) Enable Auto Sync"
  echo "5) Disable Auto Sync"
  echo "6) Uninstall All"
  echo "0) Exit"
  echo
}

install_all() {

echo "[+] Installing nftables rule..."

mkdir -p /etc/nftables.d

cat > "$NFT_FILE" <<'EOF'
table inet xray_concurrency {

  set listen_ports {
    type inet_service
    flags dynamic
  }

  set taken_ports {
    type inet_service
    flags dynamic,timeout
    timeout 2m
  }

  set owner4 {
    type inet_service . ipv4_addr
    flags dynamic,timeout
    timeout 2m
  }

  chain input {
    type filter hook input priority filter; policy accept;

    ct state established,related accept
    ct state invalid drop

    iif "lo" tcp dport 10000-65535 accept

    tcp flags & (syn|ack) == syn ct state new tcp dport @listen_ports \
      tcp dport . ip saddr @owner4 \
      update @taken_ports { tcp dport } \
      update @owner4 { tcp dport . ip saddr } \
      accept

    tcp flags & (syn|ack) == syn ct state new tcp dport @listen_ports \
      tcp dport @taken_ports \
      counter reject with tcp reset

    tcp flags & (syn|ack) == syn ct state new tcp dport @listen_ports \
      add @taken_ports { tcp dport } \
      add @owner4 { tcp dport . ip saddr } \
      accept
  }
}
EOF

echo "[+] Creating sync script..."

cat > "$SYNC_SCRIPT" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

FROM=10000
TO=65535

ports="$(
  ss -H -ltn 2>/dev/null \
  | awk '{print $4}' \
  | sed -nE 's/.*:([0-9]+)$/\1/p' \
  | awk -v a="$FROM" -v b="$TO" '$1>=a && $1<=b' \
  | sort -n | uniq
)"

if ! nft list set inet xray_concurrency listen_ports >/dev/null 2>&1; then
  exit 0
fi

nft flush set inet xray_concurrency listen_ports || true

[[ -z "$ports" ]] && exit 0

elems="$(echo "$ports" | paste -sd, -)"
nft add element inet xray_concurrency listen_ports "{ $elems }"
EOF

chmod +x "$SYNC_SCRIPT"

echo "[+] Creating systemd timer..."

cat > "$SERVICE" <<EOF
[Unit]
Description=Xray listen ports sync

[Service]
Type=oneshot
ExecStart=$SYNC_SCRIPT
EOF

cat > "$TIMER" <<EOF
[Unit]
Description=Run Xray port sync every 15s

[Timer]
OnBootSec=10s
OnUnitActiveSec=15s

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now xray-listenports-sync.timer

echo "[+] Applying nftables..."

grep -q nftables.d /etc/nftables.conf || \
echo 'include "/etc/nftables.d/*.nft"' >> /etc/nftables.conf

nft -c -f /etc/nftables.conf
nft -f /etc/nftables.conf
systemctl restart nftables

echo "✓ Installation completed."
}

verify_status() {
#echo "---- nftables table ----"
#nft list table inet xray_concurrency || true

#echo
#echo "---- listen_ports ----"
#nft list set inet xray_concurrency listen_ports || true

echo
echo "---- owner4 ----"
nft list set inet xray_concurrency owner4 || true
}

monitoring() {
echo "Active locked ports:"
nft list set inet xray_concurrency owner4 | wc -l || true
echo

echo "Listening ports:"
ss -ltn | grep -E '10000|[1-6][0-9]{4}' || true
echo

echo "Conntrack count:"
conntrack -C 2>/dev/null || echo "conntrack not installed"
}

enable_timer() {
systemctl enable --now xray-listenports-sync.timer
echo "✓ Auto sync enabled"
}

disable_timer() {
systemctl disable --now xray-listenports-sync.timer
echo "✓ Auto sync disabled"
}

uninstall_all() {
systemctl disable --now xray-listenports-sync.timer 2>/dev/null || true
rm -f "$SERVICE" "$TIMER" "$SYNC_SCRIPT"
systemctl daemon-reload

nft delete table inet xray_concurrency 2>/dev/null || true
rm -f "$NFT_FILE"

nft -f /etc/nftables.conf
systemctl restart nftables

echo "✓ Fully removed."
}

while true; do
print_menu
read -rp "Select option: " opt

case "$opt" in
1) install_all ;;
2) verify_status ;;
3) monitoring ;;
4) enable_timer ;;
5) disable_timer ;;
6) uninstall_all ;;
0) exit 0 ;;
*) echo "Invalid option";;
esac

read -rp "Press enter..."
done
