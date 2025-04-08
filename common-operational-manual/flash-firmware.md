# How to Flash Firmware

In order to provide reliable, tested and stable firmware, we auto generate the latest firmware version of all our drones, so you just have to flash it in the flight controller. 

1. **Download the latest firmware**: Based on your drone name, get the latest available firmware from our [releases](https://github.com/EOLab-HSRW/drones-fw/releases). *For example*: `platypus`, download the `platypus_VERSION.px4` firmware file:

![releases](/assets/releases.png)

> [!NOTE]
> Side note: the releases only contain the latest version of the firmwares, as we do not want to offer older versions to avoid inconsistencies and always enforce the latest version with patches and calibrations.

2. Open [QGroundControl](https://qgroundcontrol.com/) by clicking on the upper left corner on the letter "Q" and select "Vehicle Setup".

![QGroundControl Home](/assets/qgroundcontrol-home.png)

3. Select the "Firmware" menu.

![Firmware Menu](/assets/qgroundcontrol-firmware-menu.png)

4. **Flash the firmware**: Connect the flight controller to your computer using USB cable and select "Advanced settings", from the dropdown menu pick "Custom firmware file" and upload the custom firmware downloaded from step (1).

![Flash Custom Firmware](/assets/qgroundcontrol-firmware.png)

5. **RESTART** QGroundControl.

6. Open the "Vehicle Setup" (as described in step 2) and go to menu "Airframe" and depending the drone frame configuration select your drone name on the list of frames, and finally click on the button "Apply and Restart". *For example*: `platypus` is a "Octorotor Coaxial", select the frame group for "Octorotor Coaxial" and from the dropdown menu select "EOLab Platypus".

![Select airframe](/assets/qgroundcontrol-select-airframe.png)

Done.
