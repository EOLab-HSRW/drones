# Radio Setup

## Update Firmware Transmitter

> [!IMPORTANT]
> Make sure the firmware version of the radio is at least the EdgeTX Centurion `v2.10.6`.

To make sure you have the correct drivers to do a DFU (Direct Firmware Update) of the radio download and install the [STM32CubeProgrammer](https://www.st.com/en/development-tools/stm32cubeprog.html)

Using **Google Chrome** (only Google Chrome!!) follow the tutorial [Update from an earlier version of EdgeTX using EdgeTX Buddy](https://manual.edgetx.org/installing-and-updating-edgetx/update-from-opentx-to-edgetx-1)

## Setup Transmitter

By default the transmitter does not have the necessary configurations as theme, models and general settings we use, and in general configuring everything from scratch is possible but tedious, for that reason we keep a copy of the microSD memory of the radio in github [drones-rc](https://github.com/EOLab-HSRW/drones-rc) that you can just copy and paste into the radio's microSD card to have our configurations.

this configuration include:
- Our theme
- Out default model to control our drones `EOLab Default`
- RC channels mapping according to our conventions. See section [Channels Mapping](#channels-mapping).
- CRSF/ELRS config

## Bind Radio Transmitter and Receiver

....

[Unique Phrase](https://www.expresslrs.org/quick-start/binding/)

## CRSF/ELRS Setup

The folloeing image shows our setup for CRSF/ELRS radio settings in the radio transmitter.

![ELRS lua script](/assets/elrs-script-screen.bmp)

## Channels Mapping

> [!IMPORTANT]
> The radio transmitter must be set to `Mode 2`. For more information on the differences between `Mode 1` and `Mode 2` see [Types of Remote Controllers - PX4 Docs](https://docs.px4.io/main/en/getting_started/rc_transmitter_receiver.html#types-of-remote-controllers)

| RC Channel | Function           | Description                                                        |
|:----------:|--------------------|--------------------------------------------------------------------|
| 1          | Roll               | Manual control                                                     |
| 2          | Pitch              | Manual control                                                     |
| 3          | Throttle           | Manual control                                                     |
| 4          | Yaw                | Manual control                                                     |
| 5          | Offboard Mode      | Enables Offboard Mode on the flight controller                     |
| 6          | Flight mode switch | Changes the flight mode. Only for manual flights.                  |
| 7          | reserved           | reserved                                                           |
| 8          | Kill Switch        | ⚠️ Emergency Stop. The drone can fall from the sky if you use this. |

## Flight Modes Mapping

| (Physical) Switch Position | Mode                                                                                 |
|:--------------------------:|--------------------------------------------------------------------------------------|
| 1                          | [Position Slow Mode](https://docs.px4.io/main/en/flight_modes_mc/position_slow.html) |
| 2                          | [Position](https://docs.px4.io/main/en/flight_modes_mc/position.html)                |
| unassigned                 | [Offboard](https://docs.px4.io/main/en/flight_modes/offboard)                        |

For more information check the PX4 documentation for [flight modes](https://docs.px4.io/main/en/flight_modes_mc/).

## Setup FMU Radio Settings

From the FMU (Flight Management Unit) perspective all the necessary radio configurations are integrated directly into the firmware of our drones so no changes are necessary. You can find the radio configuration in the file [`rc.radiomaster_tx16s`](https://github.com/EOLab-HSRW/drones-fw/blob/main/ROMFS/px4fmu_common/init.d/rc.radiomaster_tx16s), this configuration is common for all our drones.

## External Resources

- [Installing and Updating EdgeTX](https://manual.edgetx.org/installing-and-updating-edgetx)
- [Understanding and Using the Lua Script](https://www.expresslrs.org/quick-start/transmitters/lua-howto/#understanding-and-using-the-lua-script)
