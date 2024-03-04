# Set up PiTFT Screen

## Installing Pip

Like many programming ecosystems Python has a sophisticated package management system - [Pip] is the Python package installer.

We will be using Pip extensively in this course.

Let's make sure we have Pip installed for Python3:

```bash
sudo apt install python3-pip
```

## Install the PiTFT

We are using Adafruit's 2.8" PiTFT display with capacitive touchscreen.  Here is a link to the particular part we are using, the [Adafruit PiTFT Plus 320x240 2.8" TFT + Capacitive Touchscreen](https://www.adafruit.com/product/2423).

> **COMPATIBILITY:** The PiTFT scripts are being updated to support newer hardware and newer versions of Raspberry PiOS - this is causing some issues.  For Spring '24 we are using a specific version of the repo with a git commit of `103b13388585fee0ab65b31c40aaef16d40af0c1`


```bash
cd ~
sudo pip3 install --upgrade adafruit-python-shell click
sudo apt-get install -y git
git clone https://github.com/adafruit/Raspberry-Pi-Installer-Scripts.git
cd Raspberry-Pi-Installer-Scripts
git checkout 103b13388585fee0ab65b31c40aaef16d40af0c1
```

We can run the following command to configure the kernel and system for our needs.  This will install the 2.8" Capacitive Display, rotated 180 degree (portrait) and configure FrameBuffer Copy (FBCP)

```bash
sudo python3 adafruit-pitft.py --display=28c --rotation=180 --install-type=fbcp
```

**NOTE: this will take several minutes to complete.**

Select `Y` when prompted to reboot.

Once the system reboots we'll chose a console font that reads better on the tiny screen. Run:

```bash
sudo dpkg-reconfigure console-setup
```

Select:

* **UTF-8**
* **Guess optimal character set**
* **Terminus** 
* **6x12 (framebuffer only)**.


Save and quit. Run `sudo reboot`.

Next up: go to [Hello, Kivy](../02.3_Hello_Kivy/README.md)

&copy; 2015-2024 LeanDog, Inc. and Nick Barendt
