# A Batch-Parallel GPU Multirotor Simulator with Physically-Grounded Dynamics

Harley Lara  
Earth Observation Lab (EOLab), Faculty of Communication and Environment, Hochschule Rhein-Waal, 47475 Kamp-Lintfort, Germany  

*Latin American Summer School on Robotics (LACORO), 9–13 December 2025, Rancagua, Chile*

## Abstract

We present a batch-parallel GPU multirotor simulator that combines physically-grounded dynamics with massive parallelism. Implemented in Taichi-lang, the simulator achieves high-performance GPU execution while avoiding vendor lock-in. Our approach enables the simulation of thousands of independent drones in real time, with average step times of ~0.150 ms for the range from 1,000 and 10,000 vehicles. Performance analysis shows a small GPU kernel launch overhead at small batch sizes, but scalability quickly stabilizes, allowing efficient large-scale execution.

## Keywords

Simulator, Drones, GPU, Parallel simulation, dynamics.

## 1. Introduction

The simulation of multirotor aerial vehicles has become an essential tool for robotics research, control design, and autonomous systems. Accurate simulators allow researchers to prototype novel control algorithms, evaluate robustness under diverse conditions, and explore large-scale scenarios without the cost and risk of physical experiments. However, existing simulation tools often trade off between physical fidelity, computational efficiency, and scalability. High-fidelity simulators rooted in physics-based models are typically computationally demanding, while lightweight game-engine–based simulators prioritize visual realism over accurate dynamics.

Several popular simulators highlight these trade-offs. AirSim [@shahAirSimHighFidelityVisual2017], developed by Microsoft, provides realistic rendering and sensor simulation but is primarily designed for visual perception research, with limited scalability for large numbers of vehicles. The Aerial Gym Simulator [@kulkarniAerialGymSimulator2025], built on top of NVIDIA Isaac Gym, leverages GPU acceleration for reinforcement learning but is tightly coupled to the CUDA ecosystem, limiting portability across heterogeneous hardware platforms. General-purpose physics engines such as Gazebo and PyBullet [@coumans2021] are widely used in robotics, but they are primarily CPU-based, which constrains their ability to scale to thousands of aerial robots evolving in parallel.

In this work, we present a batch-parallel GPU multirotor simulator that combines physically-grounded dynamics with massive parallelism. By leveraging the Taichi programming language (Taichi-lang) [@huTaichiLanguageHighperformance2019], we are able to achieve high-performance GPU acceleration while remaining independent of specific vendor toolchains. This design choice avoids the constraints of CUDA- or vendor-specific implementations, ensuring broader portability across heterogeneous computing platforms. The result is a simulator that can evolve thousands of independent multirotor instances in parallel and in real time. This capability enables applications such as large-scale reinforcement learning pipeline, validation of control schemes which are infeasible with traditional CPU-bound simulators.


## 2. Methodology

### 2.1 Frame, State and Notation

- World reference frame: $$\mathcal{W}$$  
- Body frame fixed to the vehicle: $$\mathcal{B}$$  

State definition:

$$
\mathcal{X} = (\mathbf{x}, \mathbf{v}, R, \boldsymbol{\omega})
\in \mathbb{R}^3 \times \mathbb{R}^3 \times SO(3) \times \mathbb{R}^3
$$

Where:

- $\mathbf{x} \in \mathbb{R}^3$ is the position vector  
- $\mathbf{v} = \dot{\mathbf{x}} \in \mathbb{R}^3$ is the velocity vector  
- $R \in SO(3)$ is the rotation matrix  
- $\boldsymbol{\omega} \in \mathbb{R}^3$ is the angular velocity vector  

### 2.2 Rigid-Body Dynamics

Let $\mathbf{e}_3$ be the canonical basis vector. Total thrust vector in world coordinates is given by:

$$
T^{\mathcal{W}} = R_{\mathcal{W}\mathcal{B}} \mathbf{e}_{3}^{\mathcal{B}}
$$

Model:

$$
\begin{cases}
\dot{\mathbf{x}} = \mathbf{v} \\
\dot{\mathbf{v}} = -g \mathbf{e}_{3}^{\mathcal{B}} + \frac{T}{m}R_{\mathcal{W}\mathcal{B}}\mathbf{e}_{3}^{\mathcal{B}} + \frac{\mathbf{f}_{\mathrm{ext}}}{m} + \mathbf{a}_{\mathrm{frag}} \\
\dot{R} = R [\boldsymbol{\omega}]_{\mathsf{x}} \\
\dot{\boldsymbol{\omega}} = J^{-1}\left(\boldsymbol{\tau} - \boldsymbol{\omega} \times (J \boldsymbol{\omega}) + \boldsymbol{\tau}_{\mathrm{ext}}\right)
\end{cases}
$$

### 2.3 Thrust and Torque Allocation

Each motor $k$ has RPM $\Omega_{k}$ and produces thrust:

$$
f_k = k_f \Omega^{2}_{k}
$$

along body $+\mathbf{e}_{3}$. Reaction torque about $+\mathbf{e}_{3}$ has magnitude:

$$
q_k = k_q \Omega^2_{k}
$$

with sign set by spin direction.

$$
\begin{bmatrix}
\tau_x^{\mathcal{B}} \\
\tau_y^{\mathcal{B}} \\
\tau_z^{\mathcal{B}} \\
T^{\mathcal{B}}
\end{bmatrix}
=
\mathbf{A}\,\mathbf{\Omega}^{\odot 2},
\qquad
\mathbf{\Omega}^{\odot 2} =
\begin{bmatrix}
\Omega_1^{2} & \cdots & \Omega_N^{2}
\end{bmatrix}^{\mathsf{T}}
$$

To account for actuator imperfections, each commanded motor speed was perturbed with both a deterministic bias and a small stochastic jitter. The bias represents manufacturing tolerances between motors and was assigned as a fixed multiplicative factor on the squared rotor speed. In addition, a white-noise term was injected at every update step, producing a random fluctuation of approximately $$\pm 1\%$$ in the effective command. Together these effects model the noisy, imperfect tracking of motor commands that occurs on real hardware and prevent the simulator from being unrealistically ideal.

The vehicle dynamics were integrated using the classical fourth-order Runge–Kutta (RK4) method. This scheme evaluates the system derivatives at four intermediate stages within each time step and combines them into a weighted average. RK4 offers a good trade-off between computational cost and accuracy: it reduces local truncation error to order $$O(\Delta t^5)$$ while remaining explicit and simple to parallelize across a large batch of vehicles.

Since floating-point drift during numerical integration gradually degrades the orthonormality of the rotation matrix, a re-projection step was enforced at every integration cycle. Specifically, the rotation matrix was re-orthonormalized using a Gram–Schmidt procedure applied to its columns. This process ensures that the matrix remains a valid element of the special orthogonal group $$SO(3)$$, thereby preserving a physically consistent attitude representation over long simulations.


## 3. Results

To evaluate the performance of the proposed batch-parallel GPU multirotor simulator, we measured the average per-step simulation time for different batch sizes (Figure below). Each trial consisted of evolving the full system dynamics over 10,000 timesteps, with batch sizes ranging from 1 to 10,000 multirotors. All experiments were performed on a consumer-grade NVIDIA GeForce RTX 4060 Laptop GPU with 8GB dedicated memory.

For a batch of 1,000 multirotors, the simulator achieves an average step time of 0.142 ms, corresponding to more than ~7,000 simulation steps per second. Scaling up to 10,000 multirotors, the simulator maintains an average step time of ≈0.151 ms per step, demonstrating good scalability of the batch-parallel formulation. This corresponds to simulating the equivalent of 10,000 physically-grounded drones evolving in parallel, faster than real time, with no significant degradation in performance.

For a batch of $$< 1{,}000$$ multirotors, the simulator shows some peaks, which can be due to the effect of GPU kernel launch overhead at relatively small problem sizes: the GPU cannot be fully saturated, and fixed overhead dominates execution time.

![Average simulation step time for a set of 50 trials per batch.](images/performance_runtime.png)


## 4. Conclusion

We presented a batch-parallel GPU multirotor simulator with physically-grounded dynamics, implemented using the Taichi programming language. Our experiments demonstrate that the framework can evolve thousands of multirotors in real time, with step times as low as 0.150 ms per update, independent of batch size beyond a modest threshold. While kernel launch overhead slightly affects very small simulations, the simulator exhibits near-constant performance for larger batches, enabling efficient execution of 10,000+ drones in parallel.

The choice of Taichi-lang as the implementation framework provides high-performance GPU acceleration while avoiding vendor lock-in, ensuring portability across different hardware platforms. Together with its integrated 3D visualization and interactive controls, the simulator provides a flexible and open research tool suitable for diverse applications.

This work lays the foundation for future directions, including integration with reinforcement learning pipelines, coupling with realistic sensing and communication models, and extension to multi-vehicle interaction dynamics. Ultimately, the proposed simulator demonstrates that physically accurate, massively parallel, and vendor-neutral simulation is not only feasible but also practical for the next generation of robotics research and large-scale autonomy studies.

## References

- Shah et al. (2017). AirSim.  
- Kulkarni et al. (2025). Aerial Gym Simulator.  
- Coumans (2021). PyBullet.  
- Hu et al. (2019). Taichi-lang.  
