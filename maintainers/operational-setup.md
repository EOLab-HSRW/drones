# Operatinal Setup

How to get a new hardware operational

[[toc]]

## Mechanical Checks

- Frame integrity: No cracks or any other mechanical defect
- Structural Symmetry: check for arm symmetry, measure diagonals from motor to motor to ensure symmetrical geometry.
- Screw and Bolt Tightness: Make sure all the screw and bolts are fully thight
- Motor mount: check for no play on the motor mounts
- Landing gear
- Propeller Clearance
- Component Mounting (non-electrical): Brackets, antenna mounts, and accessory holders should be tight and aligned.

## Electrical Checks

## Flash Latest Firmware

In case that the drone is already in our [catalog](https://drones.eolab.de/#drones), make sure to flash the latest version of the firmware, you can follow the page [How to Flash Firmware](/common-operational-manual/flash-firmware.html) for more information.

If the plan is to integrate the drone into the catalog, the first step is to create the minimal functional set of file required to generate the firmware, please follow [Add a new firmware](https://github.com/EOLab-HSRW/drones-fw/blob/main/add.md) to integrade the drone into our pipeline.

Why building the firmware from source ?
- Granular control on the firmware generation
- enable drivers (mainly the CRSF driver for radio)
- custom version tracking
- custom airframe config; this allow for easy setup.

## Flight Controller Placement

Follow: *"as close as possible to the centre-of-gravity (CoG), top-side up, and oriented so that the heading mark arrow points towards the front of the vehicle"*

- Set the FMU position, see [`EKF2_IMU_POS_X`](https://docs.px4.io/main/en/advanced_config/parameter_reference.html#EKF2_IMU_POS_X)
- Set the FMU orientation, see [`SENS_BOARD_ROT`](https://docs.px4.io/main/en/advanced_config/parameter_reference.html#SENS_BOARD_ROT) or using QGC [Flight Controller/Sensor Orientation](https://docs.px4.io/main/en/config/flight_controller_orientation.html) (discourage)

## Motors Setup

- Motor distribution and placement based on the drone airframe, see [PX4 Airframe Reference](https://docs.px4.io/main/en/airframes/airframe_reference.html).
  - Set the right number of motors [`CA_ROTOR_COUNT`](https://docs.px4.io/main/en/advanced_config/parameter_reference.html#CA_ROTOR_COUNT)
  - Set motor geometry placement (w.r.t **center of mass**), see parameters:
    - [`CA_ROTORn_PX`](https://docs.px4.io/main/en/advanced_config/parameter_reference.html#CA_ROTOR0_PX)
    - [`CA_ROTORn_PY`](https://docs.px4.io/main/en/advanced_config/parameter_reference.html#CA_ROTOR0_PY)
    - [`CA_ROTORn_PZ`](https://docs.px4.io/main/en/advanced_config/parameter_reference.html#CA_ROTOR0_PZ)
    - [`CA_ROTORn_KM`](https://docs.px4.io/main/en/advanced_config/parameter_reference.html#CA_ROTOR0_KM)
  - Set flight controller output assignment, see [`PWM_MAIN_FUNCn`](https://docs.px4.io/main/en/advanced_config/parameter_reference.html#PWM_MAIN_FUNC1)
- ESCs Calibration values (only for PWM ESCs)
  - Motor `PWM_MAIN_MINn`. and `PWM_MAIN_MAXn`, see offical docs **from step 7 onwards** [https://docs.px4.io/main/en/advanced_config/esc_calibration.html](https://docs.px4.io/main/en/advanced_config/esc_calibration.html#steps)

Checks:
- Motor numbering and placement
- Motor sping rotation acording to the airframe

## Sensors Calibration

Magnetometer:
- [Mounting a Compass (or GNSS/Compass) ](https://docs.px4.io/main/en/assembly/mount_gps_compass.html)
- [for large drones](https://docs.px4.io/main/en/config/compass.html#large-vehicle-calibration)

## Battery Setup

## Sensors Setup

## Radio and Flight Modes

See the dedicate page [Radio Setup](/maintainers/radio-setup).

## Safety Configuration

## Tunning


[reference](https://docs.px4.io/main/en/advanced_config/)
