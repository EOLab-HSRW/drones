# Operatinal Setup

How to get a new hardware operational

[[toc]]

## Create New Firmware Config

The first step is to create the minimal functional set of file required to generate the firmware, please follow [Add a new firmware](https://github.com/EOLab-HSRW/drones-fw/blob/main/add.md) to integrade the drone into our pipeline.

Why building the firmware from source ?
- Granular control on the firmware generation
- enable drivers (mainly the CRSF driver for radio)
- custom version tracking
- custom airframe config; this allow for easy setup.

## Flight Controller Placement

Follow: *"as close as possible to the centre-of-gravity (CoG), top-side up, and oriented so that the heading mark arrow points towards the front of the vehicle"*

- Set the FMU position, see [`EKF2_IMU_POS_X`](https://docs.px4.io/main/en/advanced_config/parameter_reference.html#EKF2_IMU_POS_X)
- Set the FMU orientation, see [Flight Controller/Sensor Orientation](https://docs.px4.io/main/en/config/flight_controller_orientation.html) (only using GUI in QGC)

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
  - TBA (parameters)

  Checks:
- Motor numbering and placement
- Motor sping rotation acording to the airframe
- Motor min. and max. spin values, see **from step 7 onwards** [https://docs.px4.io/main/en/advanced_config/esc_calibration.html](https://docs.px4.io/main/en/advanced_config/esc_calibration.html#steps)

## Sensors Calibration

Magnetometer:
- [Mounting a Compass (or GNSS/Compass) ](https://docs.px4.io/main/en/assembly/mount_gps_compass.html)
- [for large drones](https://docs.px4.io/main/en/config/compass.html#large-vehicle-calibration)

## Battery Setup

## Sensors Setup

## Radio and Flight Modes

## Safety Configuration

## Tunning


[reference](https://docs.px4.io/main/en/advanced_config/)
