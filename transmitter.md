# Mandatory Transmitter Settings

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


## Flight Modes

| (Physical) Switch Position | Mode                                                                  |
|:--------------------------:|-----------------------------------------------------------------------|
| 1                          | [Position](https://docs.px4.io/main/en/flight_modes_mc/position.html) |
| unassigned                 | [Offboard](https://docs.px4.io/main/en/flight_modes/offboard)         |

For more information check the PX4 documentation for [flight modes](https://docs.px4.io/main/en/flight_modes_mc/).
