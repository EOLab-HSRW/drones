# Platypus

## Specs

|                                                        |                                        |
|--------------------------------------------------------|----------------------------------------|
| Airframe configuration                                 | Octorotor Coaxial                      |
| Wheelbase diameter                                     | 0.9 m                                  |
| Dry weight*                                            | 4 kg                                   |
| Payload Capacity                                       | 6 kg                                   |
| Number of motors                                       | 8                                      |
| Recommended thrust (at 6S, Prop 17*5.5, 100% throttle) | 12.8 kgf (calculated from motors spec) |
| Total thrust (at 6S, Prop 18*4, 100% throttle)         | 23.6 kfg (calculated from motors spec) |
| Number of batteris                                     | 1                                      |
| Battery voltage                                        | 6S                                     |
| Battery capacity                                       | 11000 mAh                              |
| Individual battery weight                              | 1.35 kg                                |
| Max. flight time**                                     | 14 min                                 |

*: Drone's weight without battery or payloads <br>
**: Without payload and hovering

## Components

| Component   | Model               | Ref Link                                                                                                                                       | Documentation                                                                                                                                                     |
|-------------|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| FMU         | Hex Cube Black      | [link](https://docs.px4.io/main/en/flight_controller/pixhawk-2.html)                                                                           | [The Cube Module Overview](https://docs.cubepilot.org/user-guides/autopilot/the-cube-module-overview)                                                             |
| Motor       | LDPOWER S5008-300KV | [link](https://web.archive.org/web/20241109090913/https://www.rc-terminal.de/S5008-300KV-O58mm-Brushless-Motor-fuer-Multirotor-Copter-S-Serie) | No Documentation.                                                                                                                                                 |
| Rangefinder | TeraRanger Evo 60m  | [link](https://www.mouser.de/ProductDetail/Terabee/TR-EVO-60M-I2C?qs=OTrKUuiFdkY40qKbhIyQcg%3D%3D)                                             | [Datasheet](www.mouser.com/datasheet/2/944/TeraRanger-Evo-60m-Specification-sheet-3-1729032.pdf?srsltid=AfmBOooiM_KfYHpyFWsls1JjCFZPLYq4AXBM0fgi5hAVWOufjQF-uBx1) |

## Acknowledgment

*This drone was a joint development (in 2019) between [Drone4Agro](https://drone4agro.com/en) (Winfried Rijssenbeek) and [EOLab](https://www.eolab.de/) (part of [Lab3](https://www.hochschule-rhein-waal.de/en/faculties/communication-and-environment/laboratories/lab3)) at [Hochschule Rhein-Waal (HSRW)](https://www.hochschule-rhein-waal.de) within the framework of the [Spectors](https://spectors.eu/wordpress) project, funded by the [Interreg Germany-Netherlands](https://deutschland-nederland.eu/en/) programme. See [Big drones for future farming - Blog](https://spectors.eu/wordpress/big-drones-for-future-farming/) for a short description of the project objective.*
