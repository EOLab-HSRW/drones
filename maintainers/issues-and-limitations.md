# Know Issues and Limitations

## PX4 and ROS msgs Sync

## PX4 and Gazebo

The [PX4 Gazebo-bridge module](https://github.com/PX4/PX4-Autopilot/tree/v1.16.0/src/modules/simulation/gz_bridge) was introduce in PX4 v1.15.0 to connect PX4 directly to Gazebo API.

The current limitation is that the bridge was design for [Gazebo Harmonic](https://gazebosim.org/docs/harmonic/getstarted/) onwards, which is target for Ubuntu 24.04 Noble and is the recommended version to play along side with `ROS 2 Jazzy`. But our system target Ubuntu 22.04 and ROS Humble, which ships [Gazebo Fortress](https://gazebosim.org/docs/fortress/install_ubuntu/) if you install ROS using the debian package [`ros-humble-desktop`](https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debs.html#install-ros-2-packages) (as we do) theres naturaly a missmatch of the expected Gazebo by PX4 and the Gazebo installed by default, this is visible went you try to launch the `eolab_bringup`, you get message complaying about `Unknown message type`, this happends because the message names change from Gazebo Fortress to Gazebo Harmonic, and Gazebo as a project switch from a `ign` namespace for the whole project to `gz`.

```
$ ros2 launch eolab_bringup start.launch.py
...
[create-2] Unknown message type [9].
[create-2] Unknown message type [9].
[create-2] Unknown message type [9].
[create-2] Unknown message type [9].
[create-2] Unknown message type [9].
```

**How to fix this?**

To fix this you need to add the OSRF gazebo debian package repository to pull gazebo harmonic:

```
sudo apt update
sudo apt install -y curl lsb-release gnupg # Install tools
curl -s https://packages.osrfoundation.org/gazebo.gpg | sudo gpg --dearmor -o /usr/share/keyrings/osrf-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/osrf-archive-keyring.gpg] packages.osrfoundation.org $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/gazebo-archive.list
sudo apt update
sudo apt install ros-humble-ros-gzharmonic
```

