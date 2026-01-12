# Mesh Network

For testing [GL-MT3000 by GL-inet](https://www.gl-inet.com/products/gl-mt3000/). Nothing special about this router other them we have them laying around the lab and [OpenWRT](https://openwrt.org/) (open source linux-based firmware) supports it.

## Flash OpenWRT

If the router is running the factory firmware you have to flash OpenWRT into it.

1. Get the [Sysupgrade image](https://openwrt.org/toh/gl.inet/gl-mt3000#installation) from the OpenWRT website of this router.
2. Flash the image. Go to the admin dashboard under `192.168.8.1` and look the firmware upgrade page (typically System → Upgrade / Local upgrade) and upload the OpenWrt sysupgrade `.bin`. **IMPORTANT** Uncheck "Keep settings".
3. Done. Start the upgrade and let it reboot.

## First OpenWRT Boot

After flashing, OpenWrt is typically at `192.168.1.1` (so you may need to reconnect / renew DHCP).

1. Open LuCI by opening a broser and typing `192.168.1.1` then set a password immediately.
2. Wi-Fi may be disabled by default on fresh OpenWrt: go to Network → Wireless and enable/configure SSIDs.

## Setup (Basic) Mesh

802.11s mesh on (usually) 5 GHz as the backhaul between routers, and normal AP Wi-Fi on each router for your phones/laptops (clients don’t join 802.11s directly).

Install mesh related packages:

```
opkg update
opkg remove wpad-mini wpad-basic wpad-basic-wolfssl wpad-basic-openssl wpad-basic-mbedtls 2>/dev/null
opkg install wpad-mesh-openssl
```

Create the 802.11s mesh backhaul (both routers):
1. LuCI → Network → Wireless
2. On the 5 GHz radio: Add a new wireless network
  - Mode: 802.11s
  - Mesh ID: pick a name like `beryl-mesh`
  - Network: lan (this is what “bridges” the mesh into your LAN) 
  - Wireless security: set WPA3-SAE (or “SAE”) + a strong key 
  - Channel: set a fixed channel (same on both!) — don’t leave it on “auto”
3. Save & Apply

Now create your usual AP SSID(s) on each router (2.4 GHz and/or 5 GHz):
1. Same SSID name, same security, same password on both routers
2. Attach them to the LAN network

This is how phones/laptops connect — the 802.11s part is just the hidden backhaul.

> [!IMPORTANT]
> At this point the mesh network is not ready due to all router have the DHCP server enable and will produce problems.

## VRRP over Wi-Fi/mesh

Using VRRP we get:
- Router A management IP: 192.168.1.2
- Router B management IP: 192.168.1.3
- Router X management IP: 192.168.1.X
- Shared "floating" gateway IP (VIP): 192.168.1.1 and clients use 192.168.1.1 as gateway/DNS
- [keepalived](https://www.keepalived.org/) moves 192.168.1.1 between routers and runs a hook to start/stop DHCP.


1. Give each router a unique management IP on LAN
  - IPv4 address: 192.168.1.X
  - Netmask: 255.255.255.0
2. Install keepalived on all routers

```
opkg update
opkg install keepalived
opkg install luci-app-keepalived
```

3. Configure VRRP + the floating IP in `/etc/config/keepalived`

```
config globals 'globals'

# The floating IP object
config ipaddress 'vip_lan'
        option address '192.168.1.1/24'
        option device 'br-lan'
        option scope 'global'

# VRRP instance
config vrrp_instance 'lan_vrrp'
        option name 'LAN'
        option interface 'br-lan'
        list virtual_ipaddress 'vip_lan'
        option virtual_router_id '51'
        option advert_int '1'
        option nopreempt '1'
        option auth_type 'PASS'
        option auth_pass 'ChangeThisPassword' # CHANGE ME
        option state 'MASTER' # CHANGE ME
        option priority '120' # CHANGE ME
```

4. Make DHCP start only on the VRRP MASTER (OpenWrt hook). Edit the file `/etc/keepalived.user`

```
#!/bin/sh
# OpenWrt calls ONLY /etc/keepalived.user via hotplug on state changes.

act="${ACTION:-$1}"
act="$(echo "$act" | tr 'a-z' 'A-Z')"

case "$act" in
  NOTIFY_MASTER|MASTER)
    /etc/init.d/dnsmasq start
    [ -x /etc/init.d/odhcpd ] && /etc/init.d/odhcpd start
    ;;
  NOTIFY_BACKUP|NOTIFY_FAULT|NOTIFY_STOP|BACKUP|FAULT|STOP)
    /etc/init.d/dnsmasq stop
    [ -x /etc/init.d/odhcpd ] && /etc/init.d/odhcpd stop
    ;;
esac
```

```
chmod +x /etc/keepalived.user
```

5. Prevent DHCP accidentally starting at boot (all routers).

```
/etc/init.d/dnsmasq disable
# optional but recommended if you use IPv6 RA/DHCPv6:
[ -x /etc/init.d/odhcpd ] && /etc/init.d/odhcpd disable
```

6. Start/enable keepalived (all routers)

```
/etc/init.d/keepalived enable
/etc/init.d/keepalived restart
logread -e keepalived
```
## Experimental Setup

Metrics:
- curve like: distance → (RSSI/SNR, packet loss, throughput, jitter, failover time)
- Radio link metrics (RSSI, bitrate/MCS if available)
- Connectivity metrics (ping loss/latency)
- Throughput metrics (iperf3 up/down)

### Router Experimental Variables

Fix variables (all routers):
- Mesh band: 5 GHz (or 2.4)
- Fixed channel (same in all), fixed width (start 80 MHz; if flaky, test 40 MHz as a separate experiment)
- Fixed transmit power (don’t leave “auto” if your build exposes it)
- Disable extra clients during test (no phones connected, no scanning if you can avoid it)

Record routers settings:

```
uci show wireless | sed -n '1,200p'
iw dev
```

TBA: [Add more information....]

## External Reading Resources

- [High availability - OpenWRT User Guide](https://openwrt.org/docs/guide-user/network/high-availability)
- [batman-adv - OpenMesh](https://www.open-mesh.org/projects/batman-adv/wiki/Gateways)
- [keepalived](https://www.keepalived.org/)
