# Condor

## Specs

- Payload: 20 Kg
- Wheelbase diameter: 161 cm
- Total thrust by all the motors: 91734 g (15289 g per motor 12S 100% throttle)
- Dry weight: ?? (Drone's weight without battery)


## Components

| Component   | Model                                                                          | Documentation                                                                                                    |
|-------------|--------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------|
| FMU         | [Hex Cube Black](https://docs.px4.io/main/en/flight_controller/pixhawk-2.html) | [The Cube Module Overview](https://docs.cubepilot.org/user-guides/autopilot/the-cube-module-overview)            |
| Motor       | [Hobbywing X8](https://www.hobbywing.com/en/products/xrotor-x8108)             | [User Manual](https://robu.in/wp-content/uploads/2023/08/x8-manual.pdf)                                          |
| ESC         | Integrated as part of the motor. See motor user manual for more info.          | [User Manual](https://robu.in/wp-content/uploads/2023/08/x8-manual.pdf)                                          |
| Props       | 29 Inch foldable prop                                                          | [User Manual](https://robu.in/wp-content/uploads/2023/08/x8-manual.pdf)                                          |
| Rangefinder | [SF11/C](https://lightwarelidar.com/shop/sf11-c-100-m/) up to 100 meter range  | [Product Manual](https://www.documents.lightware.co.za/SF11%20-%20Laser%20Altimeter%20Manual%20-%20Rev%2010.pdf) |

## Batteries

| ID                | Status         | Vendor/Model                                                                                                                                            | Voltage | Capacity  | C Rating (Discharge) |
|-------------------|----------------|---------------------------------------------------------------------------------------------------------------------------------------------------------|---------|-----------|----------------------|
| `CONDOR-BATT-001` | 🟢 Operational | [Tattu Plus 1.0](https://genstattu.com/ta-plus1-0-15c-16000-12s1p-c-xt90.html)<br> - [User Manual](https://www.genstattu.com/content/TAA16KP12S15X.pdf) | 12S     | 16000 mAh | 15C                  |
| `CONDOR-BATT-002` | 🟢 Operational | [Tattu Plus 1.0](https://genstattu.com/ta-plus1-0-15c-16000-12s1p-c-xt90.html)<br> - [User Manual](https://www.genstattu.com/content/TAA16KP12S15X.pdf) | 12S     | 16000 mAh | 15C                  |
