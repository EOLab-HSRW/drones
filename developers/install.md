# Install

Our core system is under [`drones-ros2`](https://github.com/EOLab-HSRW/drones-ros2) and is design to help you easily bootstrap all the components required for developement.

Install system level dependencies:

```
sudo apt install -y python3 git tmux
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
