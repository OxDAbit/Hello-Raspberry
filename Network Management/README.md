<h1>&diams; WiFi Configurations TIPS</h1>

<h2> Connect to WiFi from terminal</h2>

- Scan WiFi ssid runing:
	```
	iwlist wlan0 scan | grep "ESSID"	
	```
- Configure `wpa_supplicant` adding the **ssid** and **password** parameters from WiFi AP
	```
	nano /etc/wpa_supplicant/wpa_supplicant.conf	
	```
- Establish WiFi connection runing
	```
	wpa_cli -i wlan0 reconfigure
	```

----------------------------------------------------------------------------------------------

<h2> Listen Open Ports </h2>

- Raspbian list open ports

```
netstat -lnt | grep LISTEN | awk '{ print ( $4 ) }' | awk 'BEGIN{FS=":"} { print $(NF) }' | sort -n | uniq	
```

----------------------------------------------------------------------------------------------

<h2> Change default SSH port </h2>

- Log in to the server as root using ssh from your computer
	```
	sudo ssh user@ip_address	
	sudo -s
	```
- Edit `sshd_config` file and save changes after locate. uncomment and edit line `#Port 22` with the desire SSH new port.
	```
	$nano /etc/ssh/sshd_config
	Port xxx	<- xxx is the new SHH port
	```
- Restart SSH service 
	```
	service ssh restart
	```
- Exit from SSH connection from server and try again using:
	```
	sudo ssh user@ip_address -p ssh_port
	```

----------------------------------------------------------------------------------------------

<h2> Static IP Address</h2>

- sudo nano **/etc/dhcpcd.conf**

- Insert at the end of the file:
	```
	interface wlan0
	static ip_address=192.168.68.60
	static routers=192.168.68.1
	static domain_name_servers=8.8.8.8
	``` 

----------------------------------------------------------------------------------------------

<h2> Check IP Address</h2>

- There're to many ways. Run some of this commands:
	```
	ip addr
	ip route get 1.2.3.4 | awk '{print $7}'
	hostname -I
	nmcli
	nmcli device show
	ifconfig
	ifconfig ens33 | grep -i inet
	```

----------------------------------------------------------------------------------------------

<h2> IP Address Config</h2>

How to use hostname instead of IP Address to stablish a SSH connection?
	
**Avahi** is installed by default in last raspbian versions but if isn't installed:
```
sudo apt-get install avahi-daemon
sudo update-rc.d avahi-daemon defaults
```

Create and config **avahi** config file:
	
- Open file to edit:
	```
	sudo nano /etc/avahi/services/multiple.service
	```

- Add this content inside file:
	```XML
	<?xml version="1.0" standalone='no'?>
	<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
	<service-group>
			<name replace-wildcards="yes">%h</name>
			<service>
					<type>_device-info._tcp</type>
					<port>0</port>
					<txt-record>model=RackMac</txt-record>
			</service>
			<service>
					<type>_ssh._tcp</type>
					<port>22</port>
			</service>
	</service-group>
	```

- Apply the new configuration:
	```
	sudo /etc/init.d/avahi-daemon restart
	```

Now you can connect to device via SSH using:
```
sudo ssh user_name@device_hostname.local
```
Ex: `sudo ssh pi@raspberrypi.local`
		

----------------------------------------------------------------------------------------------

<h2> Force WiFi interface to be a certain wlanX</h2>

- If you don't want use a MAC Address, cuz is so specific:
	- Create file **72-static-name.rules**
		```
		sudo nano /etc/udev/rules.d/72-static-name.rules
		```

	- Add in file:
		```
		ACTION=="add", SUBSYSTEM=="net", DRIVERS=="brcmfmac", NAME="wlan1"
		```

	:heavy_exclamation_mark: **NOTE**: _This allows allocate dongle in **wlan0** since the onboard interface is forced to **wlan1**_ :heavy_exclamation_mark:

- To set MAC Address:
	- Switch off this _predictable naming_ crap:
		```
		ln -s /dev/null /etc/systemd/network/99-default.link
		```
	- Create specific assignment on new file **72-static-name.rules**:
		- Create file:
			```
			sudo nano /etc/udev/rules.d/72-static-name.rules
			```

		- Add in file:
			```
			SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="et:ma:ca:dd:re:ss", NAME="eth0"
			SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="b8:27:eb:fc:6d:71", NAME="wlan1"
			SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="f4:f2:6d:1d:88:db", NAME="wlan0"
			```

----------------------------------------------------------------------------------------------

<h1> wlan0 as AP wlan1 as CLIENT</h1>

- The connection will be like this:

```
                             wifi
    device-01 <~.~.~.\       /                   wifi            wan
    device-02 <~.~.~.~.~> (wlan1)rspi(wlan0) <---------> router <---> INTERNET
    device-03 <~.~.~./       \                	 /           \            \
                        192.168.4.1/24      192.168.x.y    (dhcp)      192.168.x.x
```

- Update Raspbian kernel and firmware to avoid default kernel issue with this process and finally reboot system:
	```
	sudo apt-get update
	sudo apt-get full-upgrade
	sudo reboot
	```

- Login as root:
	```
	sudo -s
	```

<h2> 1. Configurate WiFi AP and Client using hostapd</h2>

- Install **hostapd** software package:
	```
	apt-get install hostapd	
	```
- Enable the wireless access point service and set it to raspberry boot it up
	```
	sudo systemctl unmask hostapd
	sudo systemctl enable hostapd	
	```
- In order to provide network management (DNS, DHCP) to wireless clients we should install **dnsmasq**
	```
	apt install dnsmasq	
	```
- Install **netfilter-persistent** and its plugin **iptables-persistent** to save firewall rules and restore them when the Raspberry Pi boots.
	```
	DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent iptables-persistent	
	```
- DHCP server requires static IP configuration for the wireless interface `wlan1`.
	```	
	nano /etc/dhcpcd.conf
	```
	- Go to the end of the file and add the following configuration where we assign IP address `192.168.4.1`.
		```
		# Static IP for AP
		interface wlan1
			static ip_address=192.168.4.1/24
			nohook wpa_supplicant	
		```
- Create backup from original _dnsmasq_ configuration
	```
	mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
	```
- Create new _dnsmasq_ configuration
	```
	nano /etc/dnsmasq.conf	
	```
	- Add the followgin configuration
		```
		# Listening interface
		interface=wlan1
		# Pool of IP addresses served via DHCP
		dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
		# Local wireless DNS domain
		domain=wlan
		# Local wireless DNS domain
		address=/gw.wlan/192.168.4.1
		```
- Ensure WiFi radio is not blocked on your Raspberry Pi run:
	```
	rfkill unblock wlan
	```
- Configure access point
	```
	nano /etc/hostapd/hostapd.conf	
	```
	- Add the following configuration:
		```
		country_code=ES
		interface=wlan1
		ssid=my_ssid
		hw_mode=g
		channel=7
		macaddr_acl=0
		auth_algs=1
		ignore_broadcast_ssid=0
		wpa=2
		wpa_passphrase=12345678
		wpa_key_mgmt=WPA-PSK
		wpa_pairwise=TKIP
		rsn_pairwise=CCMP				
		```
- Reboot time and test AP :beers:
	```
	systemctl reboot	
	```

<h2> Configurate WiFi AP and Client using wpa_supplicant</h2>

:heavy_exclamation_mark: **NOTE**: _This configuration can't config AP with WPA2_ :heavy_exclamation_mark:

- Disable classic networking:
	```
	systemctl mask networking.service dhcpcd.service
	mv /etc/network/interfaces /etc/network/interfaces~
	sed -i '1i resolvconf=NO' /etc/resolvconf.conf
	```
- Enable **systemd-networkd**:
	```
	systemctl enable systemd-networkd.service systemd-resolved.service
	ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
	```

- Set dongle (_wlan1_) as client and _wlan0_ as AP. This point is explained in **Force WiFi interface to be a certain wlanX** tutorial.

- Create **wpa_supplicant-wlan0.conf** (_as WiFi Client_):
	```
	nano /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
	```
	- Add in **wpa_supplicant-wlan0.conf**:
		```
		ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
		update_config=1
		country=ES

		network={
			ssid="ssid-name"
			psk="pswd-value"
		}
		```
- Updating privileges:
	```
	chmod 600 /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
	```

- Create **wpa_supplicant-wlan1.conf** (_as WiFi AP_):
	```
	nano /etc/wpa_supplicant/wpa_supplicant-wlan1.conf
	```
	- Add in **wpa_supplicant-wlan1.conf**:
		```
		ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
		update_config=1
		country=ES

		network={
			ssid="ap_ssid"
			mode=2
			frequency=2437
			key_mgmt=WPA-PSK
			proto=RSN WPA
			psk="ap_password"
		}
		```
- Updating privileges:
	```
	chmod 600 /etc/wpa_supplicant/wpa_supplicant-wlan1.conf
	```

- Disable **wpa_supplicant** service:
	```
	systemctl disable wpa_supplicant.service
	```
- Enable **wpa_supplicant-wlan0** and **wpa_supplicant-wlan1** service:
	```
	systemctl enable wpa_supplicant@wlan0.servie
	systemctl enable wpa_supplicant@wlan1.servie
	```

- Configure interfaces:
	- We don't have a bridge, so we need two different subnets.
	Be aware that the static ip address for the access point wlan1 belongs to another subnet than that from wlan0.
	- Create file **04-wlan0.network**:
		```
		nano /etc/systemd/network/04-wlan0.network
		```
		- Add in **04-wlan0.network** this configuration fixing statis IP address:
			```
			[Match]
			Name=wlan0
			[Network]
			DHCP=yes
			IPForward=yes
			```
	- Create file **08-wlan1.network**:
		```
		nano /etc/systemd/network/08-wlan1.network
		```
		- Add in **08-wlan1.network** this configuration:
			```
			[Match]
			Name=wlan1
			[Network]
			Address=192.168.4.1/24
			IPMasquerade=yes
			DHCPServer=yes
			[DHCPServer]
			DNS=84.200.69.80 1.1.1.1
			```

- Reboot system and that's it ;)
	```
	reboot
	```

----------------------------------------------------------------------------------------------

<h2> Hostapd configuration to filter WiFi clients by MAC address</h2>
	
- Edit **hostapd.conf**:
	```
	sudo -s
	nano /etc/hostapd/hostapd.conf	
	```
	- Update `macaddr_acl` from 0 (explained in Configuration WiFi AP and Client using hostapd tutorial) to 1.
		- `macaddr_acl` documentation:
			- 0 = accept unless in deny list
			- 1 = deny unless in accept list
			- 2 = use external RADIUS server (accept/deny lists are searched first)
	- Add path where `hostapd.accept` will be located
		```
		accept_mac_file=/etc/hostapd/hostapd.accept	
		```
	- To sum up the `hostapd.conf` should look like this:
		```
		country_code=ES
		interface=wlan1
		ssid=your_ssid
		hw_mode=g
		channel=7
		macaddr_acl=1
		accept_mac_file=/etc/hostapd/hostapd.accept
		auth_algs=1
		ignore_broadcast_ssid=0
		wpa=2
		wpa_passphrase=your_password
		wpa_key_mgmt=WPA-PSK
		wpa_pairwise=TKIP
		rsn_pairwise=CCMP				
		```
- Create accept list.
	```
	nano /etc/hostapd/hostapd.accept
	```
	- Add inside `hostapd.accept` file the list of allow mac addresses (for example):
		```
		aa:bb:cc:dd:ee:ff
		aa:bb:cc:dd:ee:fa
		aa:bb:cc:dd:ee:fb
		aa:bb:cc:dd:ee:fc
		aa:bb:cc:dd:ee:fd
		```

----------------------------------------------------------------------------------------------

<h2> Change hostname</h2>
	
- Edit **hostame**:
	```
	sudo nano /etc/hostname
	```

- Modify file content deleting default _raspberrypi_ hostname and add the desired _hostname_

- Edit **hosts**:
	```
	sudo nano /etc/hosts
	```

- Modify file content removing default _raspberrypi_ hostname and add the desired _hostname_:
	
	_**NOTE**: The new hostname should be the same in both files_
	
	_Default file content_:
	```
	127.0.0.1	localhost
	::1			localhost ip6-localhost ip6-loopback
	ff02::1		ip6-allnodes
	ff02::2		ip6-allrouters

	127.0.1.1	raspberrypi
	```

	
	_Edited file content_:
	```
	127.0.0.1	localhost
	::1			localhost ip6-localhost ip6-loopback
	ff02::1		ip6-allnodes
	ff02::2		ip6-allrouters

	127.0.1.1	oxraspbian
	```

----------------------------------------------------------------------------------------------

Contact
=======
- Twitter. [**@0xDA_bit**](https://twitter.com/0xDA_bit)
- Github. [**OxDAbit**](https://github.com/OxDAbit)
- Mail. **0xdabit@gmail.com**