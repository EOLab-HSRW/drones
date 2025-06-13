# Install

## 📋 Requirements

- **Operative system**: [Ubuntu 22.04 Desktop](https://releases.ubuntu.com/jammy/)
- **Architecture**: amd64 or arm64
- **ROS2**: Humble - [How to install](https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debs.html)

The rationale behind these requirements:
1. The world of robotics runs essentially on GNU/Linux based operating systems, so if you want to develop in the field what better than start using GNU/Linux?
2. We want to enforce Tier 1 support. To minimize dependency problems with packages distributed as pre-compiled binaries we are going to stick to [REP-2000](https://www.ros.org/reps/rep-2000.html#humble-hawksbill-may-2022-may-2027) and only support the above mentioned operating system and architectures.

Comments in possible scenarios:
- Can I use dual-boot? yes.
- Can I use Windows? yes (but not recommended), as long as you use Ubuntu 22.04 with [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install) on Windows 11 with a version equal or higher than 22H2. This is important for rendering Ubuntu graphics applications (like the simulator) on your Windows desktop.
- Can I use a virtual machine? Technically yes but it is very problematic with the graphics drivers and you will experience problems with the simulations so it is not recommended to use virtual machine. But if you still want to try, go ahead and good luck.
- Can I use a Mac: No! 😅.

## Our System

Our core system is under [`drones-ros2`](https://github.com/EOLab-HSRW/drones-ros2) and is design to help you easily bootstrap all the components required for developement.

Install system level dependencies:

```
sudo apt install -y python3 python3-pip git tmux
```

Install our tool to hadled our drone catalog:

```
sudo pip install vcstool git+https://github.com/EOLab-HSRW/drones-fw.git@main#egg=eolab_drones
```

Setup the working workspace. Keep in mind that some step can take time to run just be patient.

```
mkdir -p ~/eolab_ws/src && cd ~/eolab_ws/src/
git clone https://github.com/EOLab-HSRW/drones-ros2.git && cd drones-ros2
vcs import < .repos
eolab_drones build --type sitl --drone protoflyer --msgs-output ./px4_msgs
cd ~/eolab_ws
rosdep install -i --from-path src --rosdistro $ROS_DISTRO -y
colcon build --symlink-install
source install/setup.bash
```
