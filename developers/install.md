# Install

## 📋 Requirements

- **Operative system**: [Ubuntu 22.04 Desktop](https://releases.ubuntu.com/jammy/)
- **Architecture**: amd64 or arm64

Comments in possible scenarios:
- Can I use dual-boot? yes.
- Can I use Windows? yes (but not recommended), as long as you use Ubuntu 22.04 with [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install) on Windows 11 with a version equal or higher than 22H2. This is important for rendering Ubuntu graphics applications (like the simulator) on your Windows desktop.
- Can I use a virtual machine? Technically yes but it is very problematic with the graphics drivers and you will experience problems with the simulations so it is not recommended to use virtual machine. But if you still want to try, go ahead and good luck.
- Can I use a Mac: No! 😅.

## Auto-Install (Recommended)

Our core system is under [`drones-ros2`](https://github.com/EOLab-HSRW/drones-ros2) and is design to help you easily bootstrap all the components required for developement.

> [!CAUTION]
> Be aware: Running commands like the following **is extremely dangerous**, it is a gateway to running malicious code on your computer. You should never copy and paste commands you see on the internet without first inspecting them carefully and making sure you know what they do.


```
curl -fsSL https://raw.githubusercontent.com/EOLab-HSRW/drones-ros2/refs/heads/main/install.sh | sh
```

Done. You should be able to enter the container with the following command:

```
cd ~/eolab_ws/src/drones-ros2/ && apptainer run eolab.sif
```

## Manual Install (Experimental)

```
sudo apt install -y curl
curl -fsSL https://eolab-hsrw.github.io/drones-ppa/helper/add-ppa.sh | bash
```



## Manual Install

1. Install ROS 2 Humble. Follow: [Install ROS Humble in Ubuntu 22.04](https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debs.html)

2. Install QGroundControl. See []()

3. Install dependencies:

```
sudo apt-get update && apt-get install -y curl git python3 python3-vcstoopython3-pip software-properties-common

python3 -m pip install pip==22.0.2

EASY_PX4_INSTALL_DEPS=false EASY_PX4_CLONE_PX4=false pip install git+https://github.com/EOLab-HSRW/drones-fw.git@main#egg=eolab_drones
```

4. Make a workspace:

```
mkdir -p ~/eolab_ws/src && cd ~/eolab_ws/src/
```

5. Git clone our repo

```
git clone https://github.com/EOLab-HSRW/drones-ros2.git
cd drones-ros2
git clone https://github.com/EOLab-HSRW/px4_msgs.git --branch protoflyer
```

```
source /opt/ros/humble/setup.bash && cd ~/eolab_ws/src/drones-ros2/ && vcs import < .repos
```

6. Build image:

```
apptainer build eolab.sif eolab.def # later I'll change this with a pull operation from a container registry
apptainer exec eolab.sif bash -c "source /opt/ros/humble/setup.bash && cd ~/eolab_ws/src/drones-ros2/ && vcs import < .repos"
# apptainer exec eolab.sif bash -c "eolab_drones build --type sitl --drone protoflyer --msgs-output ~/eolab_ws/src/drones-ros2/px4_msgs"
apptainer exec eolab.sif bash -c "source /opt/ros/humble/setup.bash && cd ~/eolab_ws/ && colcon build --symlink-install"
```
