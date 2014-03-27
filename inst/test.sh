echo -1 >/sys/module/usbcore/parameters/autosuspend
echo Y > /sys/module/usbcore/parameters/old_scheme_first
dpkg-reconfigure linux-image-3.11.0-18-generic