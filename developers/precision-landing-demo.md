# Precision Landing Demo

Start the simulation

```
ros2 launch eolab_bringup start.launch.py world:=aruco
```

Don't forget to start the detection of the [arUco](https://docs.opencv.org/4.x/d5/dae/tutorial_aruco_detection.html) markers:

```
ros2 run eolab_precision_landing detector --ros-args -r __ns:=/protoflyer
```
