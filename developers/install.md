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

