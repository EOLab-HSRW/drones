# Developers

This section of the documentation is intended for those who want to develop what we will from now on call "smart missions". This term "smart mission" will be used in the documentation to simply refer to missions that require additional capabilities beyond the flight controller capabilities on its own, which we will call "bare missions". 

For example, "bare mission" can be a mission programmed with QGroundControl where the drone follows a route or survey a certain area, so "bare mission" is any mission that uses the capabilities embedded in the flight controller, however in some use-cases these missions may lack more advanced capabilities such as detecting invasive plants and applying herbicide in a targeted manner, or performing autonomous navigation requiring depth and lidar processing. All of these examples cannot be executed on the flight controller directly, so a companion computer is needed to offload the processing of other types of sensors, this is where we refer to "smart missions" missions that can be orchestrated from the companion computer but at the same time are transparent to the flight controller and offer the ability to be composed into a mission that combines "bare" and "smart" functionalities.

## Brief Overview

| ![System Overview](./images/systems-overview-developer-developer.jpg) |
|-----------------------------------------------------------------------|
| Brief system overview                                                 |

> [!IMPORTANT]  
> Some of the components we depend on are under development or are in an experimental state and maintained by third parties. Collaboration and contribution to improve them is highly recommended.
