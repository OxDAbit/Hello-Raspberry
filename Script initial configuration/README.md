<h1>&diams; Automatic raspberry configuration &diams;</h1>

The goal of this paper is:
1. Create an automatic script that performs the initial configuration of the raspberry for ourself.

<h2> USB structure</h2>

The [script](https://github.com/OxDAbit/raspberry-auto_script_initial_config/tree/main/usb) will be located inside a USB with this structure:

```
OXUSB
  └── oxfirst-boot.sh                 # First boot configuration WITHOUT OverlayFS SFS
```

<h2> Mount USB</h2>

In **Raspbian lite** the USB isn't mounted automatically so need a manual mount process.

1. Connect keyboard and monitor to Rasberry Pi
2. Login as **pi** user
3. Login as **root** user (you don't need to use **sudo** at the begining of the commands)
    ```
    $ sudo -s 
    ```
4. Check USB information (USB is named `OXUSB`)
    ```
    $ blkid 
    ```
    :heavy_exclamation_mark: **NOTE**: _`blkid` command needs to be executed as root (using sudo) if isn't executed as root USB won't be listed._ :heavy_exclamation_mark:

    The information should look like this:

    ```
    /dev/sda2: LABEL_FATBOOT="OXUSB" LABEL="OXUSB" UUID="3EA3-1A09" TYPE="vfat" PARTUUID="asafasca-0asd-4asd2-9asdb0-05asdagatrdc1"
    ```

5. Create folder to mount USB
    ```
    $ mkdir -p /media/oxusb 
    ```
6. Mount USB in `/oxusb`
    ```
    $ mount /dev/sda2 /media/oxusb/
    ```
7. Check if USB is mounted 
    ```
    $ df /media/oxusb 
    ```
    The information should look like this:
    ```
    Filesystem     1K-blocks  Used Available Use% Mounted on
    /dev/sda2        7411556    44   7411512   1% /media/oxusb
    ```
    
    Another option is:
    ```
    $ mount | grep "/dev/sda2" 
    ```
    
    The information should look like this:
    ```
    ...
    /dev/sda2 on /media/oxusb type vfat (rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,errors=remount-ro)
    ...
    ```

    Or simply list the new directory:
    ```
    $ ls -lah /media/oxusb 
    ```

    The information should look like this:
    ```
    drwxr-xr-x 3 root root 4096 Nov 24 16:45 ..
    -rwxr-xr-x 1 root root 2418 Nov 16 19:39 oxfirst-boot.sh
    drwxr-xr-x 2 root root 4096 Nov  4 18:24 oxoverlay
    -rwxr-xr-x 1 root root 5504 Nov 23 18:38 oxoverlaySFS.sh
    drwxr-xr-x 2 root root 4096 Nov  4 18:23 oxsfs
    ```

<h2> Script time }:)</h2>

- What the config scirpt does:
    - keyboard (Spanish by default)
    - language (Spanish by default)
    - Enable SSH server
    - WiFi configuration
        - Add ssid
        - Add password
        - Connect to WiFi AP

- Run script:
    - Should edit script adding your **ssid** and **password**
        ```
        $ declare wifi_ssid="your_ssid"
        $ declare wifi_pswd="your_password"
        ```
    - Run _first option_ (`oxfirst-boot.sh`)
        ``` 
        $ /bin/bash /media/oxusb/oxfirst-boot.sh
        ```

----------------------------------------------------------------------------------------------

Contact
=======
- Twitter. [**@0xDA_bit**](https://twitter.com/0xDA_bit)
- Github. [**OxDAbit**](https://github.com/OxDAbit)
- Mail. **0xdabit@gmail.com**