# 🛸 Autonomous UAV Line Following & Marker-Based Landing using MATLAB/Simulink

This repository contains the complete implementation of a **two-phase autonomous flight pipeline** for a drone using **MATLAB and Simulink**. The system uses **onboard vision for line following**, and then switches to **external camera-based marker tracking** for dynamic landing.

---
![Image Description]([https://your-https-link.com/image.png](https://raw.githubusercontent.com/Sjschhabra/uav-dynamic-landing-line-tracking/refs/heads/main/Screenshot%20(96).png))

---


---

## 🚦 Phase 1: Line Following using Onboard Vision

### 🎯 Goal

Use onboard camera video feed to **track a black line on a white surface** and follow it autonomously.

---

### 🧠 Vision Processing & Control Logic

1. **Binary Conversion**:
   - Video is first thresholded: black line is white in binary image, all else is black.
   - This makes the line detection independent of lighting variations.

2. **Sectional Analysis**:
   - Each binary image frame is divided into **7 equal horizontal sections**.
   - For each section (left to right: `vL`, `v1`, `v3`, `v5`, `vR`, `vE`, `center`), calculate the **sum of white pixels** as a percentage.

3. **Input Vector to Controller**:
   - A 6- or 8-element vector is passed to the Simulink controller:
     ```
     [vL, v1, v3, v5, vR, vE, cL, cR]
     ```
   - These represent pixel densities in different sections and help make directional decisions.

---

### 🧠 MATLAB Control Logic: `lineFollowerControl.m`

- **Initialization**:
  - `x`, `y`, `yaw`, and `z` represent the drone’s position and orientation.
  - Persistent variables track the state between simulation steps.

- **Start Delay**:
  - A 3-second delay allows the drone to stabilize after takeoff.

- **Line Tracking**:
  - Main center section (`v3`) is used for forward movement.
  - If left (`v1`) > right (`v5`), adjust yaw to the left and vice versa.
  - Forward distance is scaled based on average brightness and alignment.

- **Lost Line Detection**:
  - If `v3 < threshold` (line not visible), the drone enters **search mode**.
  - Compares weighted brightness between `vL` and `vR` using side coefficients `cL` and `cR`.
  - Starts rotating in the direction of higher confidence until line is reacquired.

- **Descent Trigger (State Transition)**:
  - If the line is weak in the center but both side sections are symmetric (`|vL - vR| < ε`), it’s assumed that the drone is above the end-of-line descent point.
  - Initiates a short forward movement, pauses for 2 seconds, and then hands over to **Phase 2**.

---

## 🛬 Phase 2: Marker-Based Landing Using External Camera

### 🎯 Goal

Use a **top-down external camera feed** to detect a marker on the ground and dynamically adjust drone movement to land on it.

---

### 🧠 Image Processing & Navigation Logic

#### 1. `markCentroid.m` – Marker Detection

- Detects white-colored region from a binary image.
- Returns `(centroid_x, centroid_y)` coordinates of the detected marker.
- If no marker is detected, returns a default position at the center `(80, 60)` to avoid NaN errors.

#### 2. `getDirectionAndMove.m` – Motion Planning Based on Centroid

- Takes in the detected marker centroid.
- Calculates:
  - `dx`, `dy`: displacement vector from current position to marker.
  - `angle`: direction to rotate (via `atan2(dy, dx)`).
  - `distance`: how far the drone is from the marker.

- Movement Logic:
  - The drone’s `(x, y)` coordinates are updated by a small scaled amount based on the angle.
  - Simulates physical movement towards the centroid by projecting the motion using:
    ```matlab
    x = x + length * cos(angle);
    y = y + length * sin(angle);
    ```
  - The longer the distance, the faster the drone moves.

- Altitude (`z`) remains constant during this phase.
  - **Landing condition (z = 1)** is triggered **only when the drone reaches very close to the marker (distance < 5 pixels)**.
  - At this point, control is handed off to the landing subsystem.

---

## 💻 Tools Used

- MATLAB R2023a+
- Simulink
- Simulink Support Package for Parrot Minidrones
- MATLAB Image Processing Toolbox

---

## 🎥 Video Demonstrations

Here are some **demo videos** demonstrating both the line-following and marker detection:

- **Final: Demonstration Video**  
  [Watch Line Following Demo on YouTube](https://www.youtube.com/watch?v=YOUR_VIDEO_LINK)

- **Phase 1 & 2: Matlab Video**  
  [Watch Marker Landing Demo on YouTube](https://www.youtube.com/watch?v=YOUR_VIDEO_LINK)

These videos show the drone autonomously following a line and landing on a marker in both simulated and real-world environments.

---

## 📸 System Diagram

Below is a simple diagram illustrating the flow of control between both phases:

![System Diagram Line Following]([docs/system_diagram.png](https://raw.githubusercontent.com/Sjschhabra/uav-dynamic-landing-line-tracking/refs/heads/main/Screenshot%20(95).png)
![System Diagram Patch Following]([docs/system_diagram.png](https://raw.githubusercontent.com/Sjschhabra/uav-dynamic-landing-line-tracking/refs/heads/main/Screenshot%20(94).png)

---

## 📈 Future Improvements

- Add state machine visualization using Simulink Stateflow.
- Use dynamic template matching for robust marker detection under rotation.
- Integrate with ROS or MAVROS for real-world drones.

---

## 👨‍💻 Author

**Sameerjeet Singh Chhabra**  
M.S. in Robotics and Autonomous Systems  
Arizona State University  
✉️ schhab18@asu.edu

---

## 📄 License

Licensed under the [MIT License](LICENSE).


