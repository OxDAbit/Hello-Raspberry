<h1>&diams; Raspberry Pi SSD instalation</h1>

The goal of this paper is:
1. Use SSD in Raspberry Pi.
2. Boot Raspbian OS from SSD and stop using SD card on Raspberry Pi.
3. Configuration for Raspberry Pi 3
4. Configuration for Raspberry Pi 4

----------------------------------------------------------------------------------------------

<h2> Raspberry Pi 3 SSD configuration </h2>

**NOTE:** _For this examples, I've used a Raspbian OS (32-bit) Lite (Debian Buster)._

1. First of all, burn Raspbian Lite image in SD card.
    - I've used a **Raspberry Pi Imager** to burn the image. Simply select the operating system, SD card and write the image into the SD card.

    ![Raspberry Pi Image](https://github.com/OxDAbit/raspberry-ssd_configuration/blob/main/image/raspberry_pi_imager.png?raw=true)

2. Connect your raspberry Pi with the SD card inserted and boot it up, after that make sure the raspbian is fully updated runing:
    ```
    $ sudo apt-get update
    $ sudo apt-get upgrade -y

    # Reboot Raspberry after update process
    $ sudo reboot
    ```

3. To make possible that the Rapsberry Pi boot it up from SSD (or USB) we need to set one bit of the Raspberry Pi one-time programmable memory. 
    Type the command:
    ```
    $ vcgencmd otp_dump | grep 17
    ```

    Thi command will show us the value we have when we start:
    ```
    17:1020000a
    ```

4. Now is time to edit **config.txt** file, located in **/boot** where we make possible boot the Raspberry Pi from SSD:
    ```
    $ sudo nano /boot/config.txt 
    ```
    Add the command **program_usb_boot_mode=1** at the end of the file

5. Reboot Raspberry Pi to make that everythings is OK and nothing is broken };)
6. Now run again the command:
    ``` 
    $ vcgencmd otp_dump | grep 17
    ```

    This time the result should be different:
    ```
    17:3020000a
    ```
    Thats means that the Raspberry Pi is ready to boot from SSD or USB device.

7. Edit **config.txt** again and remove or comment the last line that we added before. 
    ```
    $ sudo nano /boot/config.txt
    ```
    **NOTE**: _If we wanna comment this line simple add **#** at the beginning of the command_

8. Shutdown Raspberry Pi
    ```
    $ sudo shutdown -h now
    ```

9. Burn Raspbian Lite image in SSD.
    - Open a **Balena Etcher**, select image, SSD and burn the image.

    ![balena Etcher](https://github.com/OxDAbit/raspberry-ssd_configuration/blob/main/image/etcher.png?raw=true)

10. Remove SD card and connect SSD to Raspberry Pi, after that boot it up!
11. After that the Raspberry Pi is runing from SSD :smile: 

----------------------------------------------------------------------------------------------

<h2> Raspberry Pi 4 SSD configuration </h2>

**NOTE:** _For this examples, I've used a Raspbian OS (32-bit) Lite (Debian Buster)._

1. Burn Raspbian Lite image in SSD.
    - Open a **Balena Etcher**, select image, SSD and burn the image.

    ![balena Etcher](https://github.com/OxDAbit/raspberry-ssd_configuration/blob/main/image/etcher.png?raw=true)

2. Connect SSD to Raspberry Pi 4
3. Turn ON Raspberry Pi 4
4. That's it 

----------------------------------------------------------------------------------------------

Contact
=======
- Twitter. [**@0xDA_bit**](https://twitter.com/0xDA_bit)
- Github. [**OxDAbit**](https://github.com/OxDAbit)
- Mail. **0xdabit@gmail.com**