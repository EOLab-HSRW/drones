# EOLab's Drones System

EOLab's Drone System aims to provide a framework that serves as an umbrella to operate all our self-built drones. In this documentation you will find all the necessary resources for: specifications of our drones, 3D models for reference, operation manuals and general conventions used in all our platforms.

> [!IMPORTANT]
> If you are new, the best way to start is Reading the Friendly [Manual](./common-manual/README.md).

> The [EOLab](https://www.eolab.de/) (Earth Observation Lab) is a laboratory of the [Rhine-Waal University of Applied Sciences (HSRW)](https://www.hochschule-rhein-waal.de/de) in Germany. It is part of the [Faculty of Communication and Environment](https://www.hochschule-rhein-waal.de/de/fakultaeten/kommunikation-und-umwelt), Campus Kamp-Lintfort.

## Drones

| Drone Name                                                                                                                                       | Self-built | Quantity | Status               |
|--------------------------------------------------------------------------------------------------------------------------------------------------|:----------:|:--------:|----------------------|
| [SAR](./sar/README.md)                                                                                                                           | ✅         | 1        | 🟡 Under maintenance |
| [Platypus](./platypus/README.md)                                                                                                                 | ✅         | 1        | 🟡 Under maintenance |
| [Protoflyer](./protoflyer/README.md)                                                                                                             | ✅         | ?        | 🟡 Under maintenance |
| [Phoenix](./phoenix/README.md)                                                                                                                   | ✅         | 1        | 🟡 Under maintenance |
| Octopus                                                                                                                                          | ✅         | 1        | 🟡 Under maintenance |
| Mantis                                                                                                                                           | ✅         | 1        | 🟡 Under maintenance |
| Cargo Drone                                                                                                                                      | ✅         | 1        | 🟡 Under maintenance |
| DJI Tello EDU <br> - [User Manual](https://dl-cdn.ryzerobotics.com/downloads/Tello/Tello%20User%20Manual%20v1.4.pdf)                             |            | 2?       | 🟢 Operational       |
| DJI RoboMaster TT Tello Talent <br> - [User Manual](https://dl.djicdn.com/downloads/RoboMaster+TT/RoboMaster_TT_Tello_Talent_User_Manual_en.pdf) |            | ?        | 🟢 Operational       |
| DJI Phantom 4 Pro <br> - [User Manual](https://dl.djicdn.com/downloads/phantom_4_pro/Phantom+4+Pro+Pro+Plus+User+Manual+v1.0.pdf)                |            | 1        | 🟢 Operational       |
| DJI NEO <br> - [User Manual](https://dl.djicdn.com/downloads/neo/20240905/DJI_Neo_User_Manual_v1.0_en.pdf)                                       |            | 1        | 🟢 Operational       |
| DJI Mini 4 Pro <br> - [User Manual](https://dl.djicdn.com/downloads/DJI_Mini_4_Pro/DJI_Mini_4_Pro_User_Manual_EN.pdf)                            |            | 1        | 🟢 Operational       |
| DJI Avata <br> - [User Manual](https://www.foto.no/media/multicase/documents/dji/dji%20avata%20user%20manual%20v1.06.pdf)                        |            | 1        | 🟢 Operational       |
| DJI Mavic 3M <br> - [User Manual](https://dl.djicdn.com/downloads/DJI_Mavic_3_Enterprise/20221216/DJI_Mavic_3M_User_Manual-EN.pdf)               |            | 1        | 🟢 Operational       |
| AR Drone 2.0                                                                                                                                     |            | 2        | 🟢 Operational       |

## Components

In our system, a "component" can be any extra device like a RC Controller or a payload that interact with the our drones. Our system components are designed to be combinable, so that they can be interchanged with any of our self-built drones, all the necessary parameters to integrate the component(s) into the drone are added in the drone firmware.

| Component                                                                                                                                                                                                                           | Quantity | Compatibility      |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------:|--------------------|
| [Radiomaster TX16s (with ELRS radio module)](https://www.radiomasterrc.com/products/tx16s-mark-ii-radio-controller?variant=45864311685351)<br> - [User Manual](https://cdn.shopify.com/s/files/1/0609/8324/7079/files/TX16S_1.pdf)  | 1        | all (`self-built`) |
| [RP1 V2 Receiver (with external antenna)](https://www.radiomasterrc.com/products/rp1-expresslrs-2-4ghz-nano-receiver) <br> - [User Manual](https://cdn.shopify.com/s/files/1/0609/8324/7079/files/RP1_User_Manual.pdf?v=1722923320) | 2?       | all (`self-buil`)  |
| [RP2 V2 Receiver (with ceramic antenna)](https://www.radiomasterrc.com/products/rp2-expresslrs-2-4ghz-nano-receiver) <br> - [User Manual](https://cdn.shopify.com/s/files/1/0609/8324/7079/files/RP2_User_Manual.pdf?v=1722923303)  | 2?       | all (`self-buil`)  |

## Tutorials

The following is a set of tutorials that are common to all our drones, that means that all the steps and procedures described in these tutorials are applicable to all our drones platforms.
- [How to Flash Firmware](./firmware.md)
- [Mandatory Transmitter Settings](./transmitter.md)
