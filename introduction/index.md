# Introduction

Welcome to the introduction. The purpose of this page is to clarify the scope of this documentation, as well as to serve as a starting point to start working with EOLab Drones.

This documentation is designed for three types of readers/users, and makes a **strong assumption** that everyone knows **the basics of drones**:
- **Operators/Pilots**: This user is primarily interested in performing manually operated missions, so the [Common Operational Manual](/common-operational-manual/README.html) section covers all the information necessary for an operator/pilot to use our self-built drones.
- **Developers (application layer)**: This user is interested in performing assisted or autonomous missions with our drones, so the [Developers](/developers/README) section provides relevant resources to develop autonomous applications.
- **Maintainers**: User in charge of maintaining the hardware and software infrastructure for the previous users as well as the documentation.

*What if you are not yet familiar with the basics of drones?* in that case you can visit the external link [Basic concepts - PX4 Docs](https://docs.px4.io/main/en/getting_started/px4_basic_concepts.html). For now there are no intentions to include educational material to start from zero on drones as this only increases the overhead of the documentation.

## The Cores

The following section is purely informative, and is intended to point out the projects that are at the core of our drones.

Operators/Pilots, Developers, and Maintainers should each be familiar with the following projects, with the expected depth of knowledge varying by the type of reader/user you are.

**Hardware core**: [Pixhawk](https://pixhawk.org/) is defined as an **open hardware standard**, “Pixhawk open standards provide readily available hardware specifications and guidelines for drone systems development.” In all of our self-built drones, the **flight controller** is either fully **Pixhawk compliant**—for example, the Holybro Pixhawk v6c in [Pegasus](/pegasus/)—or compatible with Pixhawk but not fully compliant. An example of the latter is [Protoflyer](/protoflyer/), which uses the “Cube Black by Hex” flight controller. This controller does not follow the ["Pixhawk Autopilot Bus (PAB) Standard (DS-010)"](https://github.com/pixhawk/Pixhawk-Standards/blob/master/DS-010%20Pixhawk%20Autopilot%20Bus%20Standard.pdf), making it vendor-locked to “The Cube” family produced by Hex.

**Software core**: [PX4](https://px4.io/), an **open-source autopilot**. Given the foundation of an open hardware standard, Pixhawk, the two popular options in this space are **PX4** and [**ArduPilot**](https://ardupilot.org/). We have an opinionated inclination toward PX4 (see [Autopilots](/maintainers/design/autopilots) for details); therefore, all of our self-built drones run PX4. However, we truly acknowledge and admire the ArduPilot ecosystem.

**Application core**, for developers and maintainers: [ROS](https://www.ros.org/), the **Robot Operating System**. ROS provides the application-layer framework used to build, integrate, and operate higher-level robotics software around the drone. While PX4 is responsible for low-level flight control, stabilization, and vehicle-specific behavior, ROS is used for application-level capabilities such as autonomy, perception, simulation and interaction with external systems. Developers and maintainers working on this layer should be fluent in the ROS ecosystem.
