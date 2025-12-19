# Pixhawk (Hardware) and ROS2 (Software)

An key part of the development ecosystem to enable the **deployment** of "smart" missions throught custom flight modes. An important clarification is the term deployment, which implies a user-centric perspective of usability.

Developers produce a set of "composable" building blocks and execution sequences that combine standard flight modes with custom flight mode, so that operators can use them to create missions tailored to their needs, without having to implement or depend on the underlying implementation details.

For example, in autonomous search and rescue operations, an operator can combine pre-built navigation, object detection, and obstacle avoidance modules to execute a mission without writing low-level code.

## Requeriments

1. Add custom flight modes
  - Aurdupilot: [Adding a New Flight Mode to Copter](https://ardupilot.org/dev/docs/apmcopter-adding-a-new-flight-mode.html)
2. Avoid offboard mode

## Standard Interfaces

We consider **Standard Interface** from the flight controller perspective.

### MAVLink

Raw MAVlink, or a MAVLink library generator like [mavgen](https://github.com/ArduPilot/pymavlink/tree/master/generator)
- [pymavlink](https://github.com/ArduPilot/pymavlink) (generated with mavgen)
- [MAVSDK](https://github.com/mavlink/MAVSDK): Personally, if I had to choose a MAVLink library, I'd go with this one, since its clients — C++ and Python, to name a few — have a more idiomatic and semantic API (compare to the mavgen counterparts), while still exposing enough control to interface with MAVLink at a lower level. MAVSDK achieves a more semantic interface by using what the project refers to as Plugins—modules that encapsulate and simplify low-level MAVLink operations.

### Non-Standard

No native to the flight controller ecosystem.
- MAVROS: Although MAVROS provides what could be considered a somewhat standard interface for communicating with MAVLink flight controllers, in reality this standardization exists only from the perspective of the ROS ecosystem. Nevertheless, it is a necessary abstraction to connect high-level functions like SLAM and VIO with the low-level functionalities of the flight controllers exposed via MAVLink.
- [PX4 ROS 2 Interface Library](https://docs.px4.io/main/en/ros2/px4_ros2_interface_lib)
  - make use of PX4 [ModeManagement](https://github.com/PX4/PX4-Autopilot/blob/main/src/modules/commander/ModeManagement.cpp) commander module to register custom flight modes at runtime.
  - See Official docs on [Internal vs External Modes - PX4 Docs](https://docs.px4.io/main/en/concept/flight_modes#px4-internal-modes) this get powerup thanks to the Autodiscovery of flight_modes enable by [MAVLink - Standard Modes Protocol](https://mavlink.io/en/services/standard_modes.html) that allow automatic enumeration of flight_modes by the flight controller.
  - [Neural Network Module: System Integration](https://docs.px4.io/main/en/advanced/nn_module_utilities)


## Liminations

- The huge downside of `px4_ros2_interface_lib` is that the code produced with this is especific for PX4-centric firmware leaving completly out of frame ArduPilot-based flight stacks.
- The current implementation of `px4_ros2_interface_lib` depends on the uORB topics exposed throught the [uXRCE-DDS Bridge](https://docs.px4.io/main/en/middleware/uxrce_dds) the requires a `uXRCE-DDS client`in the flight controller. The problem is that this client requires to be compilet with the set of topics and message info at the firmware level, this implies that exposing new topics or adding/chaging message definitions requires re-compilation of the firmware. Addionally the `uXRCE-DDS agent` running in the companion computer that requires MATCHING MESSAGE DEFINITION between PX4 uORB topics (baked into the firmware uXRCE-DDS client) and ROS messages and services interfaces.

Alternative in the future. Zehon as the communication middleware between PX4 and ROS2. See [Zenoh (PX4 ROS 2 rmw_zenoh)](https://docs.px4.io/main/en/middleware/zenoh). The `PX4 ROS 2 Interface Library` is agnostic to this change but the ROS ecosystem is not, at least not yet (at the time of writing Nov. 2025) you need to change the middleware in ros [Zenoh - ROS2 Humble](https://docs.ros.org/en/humble/Installation/RMW-Implementations/Non-DDS-Implementations/Working-with-Zenoh.html). We need to way for `rmw_zenoh` to be stable and ideally the default RMW
- ROS 2 Kilted Kaiju: Zenoh was made a [Tier‑1 middleware implementation](https://www.ros.org/reps/rep-2000.html#id51)
- We got [rmw_zenoh binaries for Rolling, Jazzy and Humble](https://discourse.openrobotics.org/t/rmw-zenoh-binaries-for-rolling-jazzy-and-humble/41395). Does this implies Tier-1 support of these distributions? not explicit mention on this.
