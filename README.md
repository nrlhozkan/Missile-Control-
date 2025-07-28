# Biased Proportional Navigation (BPN) – Simulink Implementation

This repository contains two Simulink models that implement the guidance law proposed in *“Biased proportional navigation with exponentially decaying error for impact angle control and path following”* (Erer et al., MED 2016). One model addresses **impact-angle control** against a stationary target; the other addresses **tail-chase/path-following** of a (virtual) moving target.

---
## Contents
```
impact_angle_control.slx            # Impact-angle scenario (stationary target)
tail_chase.slx                      # Path-following / tail-chase scenario (virtual target)
parameters_new.m                    # Parameters and initial conditions for both models
README.md                           # This file, describing the models and usage
all_three_scenario_for_impact.m     # Script to plot results from all three scenarios using out mat files
impact_angle_control_results.m      # Script to plot results from impact angle control scenarios
mat files (e.g., impact_angle_control_results_s1.mat) # Output data from simulations 
tail_chase_results.m                 # Script to plot results from tail chase scenario 
video files in video folder (e.g., impact_angle_control.mp4) # Simulation videos
video_writer.m                       # Script to generate videos from impact angle control output data
video_writer2.m                      # Script to generate videos from tail chase output data
```
---
## Quick Start
1. **Open parameters_new** file and set the `mode` variable to either `'impact_angle_control'` or `'tail_chase'` to select the desired scenario. 
2. **Open the desired model** (`impact_angle_control.slx` or `tail_chase.slx`).
3. **Run the simulation**. The model logs `a` (acceleration command), `e` (error), `lambda`, `lambdaDot`, `gamma`, `gammaT`, positions, etc., to the MATLAB workspace.
4. **View scopes** or post-process the logged data.

---
## Model Architecture at a Glance

Both models share the same logical structure:

- **/LOS, LOS Rate & Error**  (impact model)  
  **/LOS & Geometry** (tail-chase model)  
  Computes line-of-sight angle `λ`, its rate `λ̇`, and the error signal `e` defined in the paper.

- **/Guidance Main** (or **/Guidance**)  
  Implements the biased PN law: generates commanded lateral acceleration (or `γ̇`) from `λ̇`, `e`, and the bias `b = Kp·e + Ki∫e dt`.

- **/Guidance Ref1**  
  Implements the reference/benchmark law from Ryoo–Cho–Tahk (optimal guidance with angle constraint) used for comparison.

- **/MATLAB Function** blocks  
  Small helper functions (usually to switch between main/reference guidance, or to compute geometry inside a subsystem).

- **/Pursuer_Dynamics**  
  Integrates the pursuer kinematics/dynamics.

- **/Target**  
  Generates stationary target states (impact case) or virtual target motion (tail-chase case). For tail-chase, target speed is scheduled to maintain a tail-chase condition once reached.

- **Stop Simulation** blocks  
  Terminate the run when a condition is met (e.g., very small miss distance or minimum time).

---
## Running Each Scenario

### Impact-Angle Control (`impact_angle_control.slx`)
1. Set initial pursuer position, speed `vP`, and path angle `γ` in **/Pursuer_Dynamics**.
2. Choose desired final impact angle `γ_f` inside the LOS/geometry block or as a workspace variable.
3. Tune `N`, `Kp`, `Ki`, `e0` so that the error decays within the available time-to-go.
4. Run. Simulation ends when range `r` < 1 m (or another threshold).

### Tail-Chase / Path-Following (`tail_chase.slx`)
1. Define path via the virtual target in **/Target** (straight + circle in the provided file).
2. `r_min` and target speed logic are in the Target subsystem; adjust to trade tracking accuracy vs. control effort.
3. Adapt `N` between straight and curved segments if desired (as done in the paper/model).
4. Run until the virtual target completes the loop, or stop earlier.

---
## Parameters & Signals of Interest

- **Inputs / Tunables**: `N`, `Kp`, `Ki`, `e0`, `r_min`, segment switch times.
- **Logged Outputs** (`ToWorkspace` blocks): `a`, `e`, `λ`, `λ̇`, `γ`, `γ_T`, `xP`, `yP`, `xT`, `yT`, `vT`.
- **Scopes**: Quick visual check of error decay, acceleration histories, and path angles.

## Known Assumptions / Simplifications

- Constant pursuer speed (easy to relax: `γ̇ = a/v` still holds if `v` varies slowly, but update dynamics accordingly).
- No actuator saturation modeled (watch max `a` values; add saturation blocks if needed).
- Seeker/NAV signals assumed perfect (LOS and rate come directly from geometry).

---

## Simulation Results

### Impact-Angle Control

![Error e](Mission-Control-\impact_angle_control_results_scenario12025_07_28_112427\impact_angle_control_error.png)

![Pursuer Trajectory](.\impact_angle_control_results_scenario12025_07_28_112427\impact_angle_control_trajectory.png)

![Flight-path Angle](.\impact_angle_control_results_scenario12025_07_28_112427\impact_angle_control_flight_path_angle.png)

![Acceleration History](.\impact_angle_control_results_scenario12025_07_28_112427\impact_angle_control_acceleration.png)

**Video:**

<video src="./videos/impact_angle_control_90_degrees.mp4" width="640" controls></video>

### Path-Following / Tail-Chase

![Pursuer vs Virtual Target Trajectory](.\tail_chase_results_2025_07_28_113113\trajectory_path_following.png)

![Flight-path Angle (Path-Following)](.\tail_chase_results_2025_07_28_113113\flight_path_angle_path_following.png)

![Acceleration (Path-Following)](.\tail_chase_results_2025_07_28_113113\acceleration_path_following.png)

![Error e (Path-Following)](.\tail_chase_results_2025_07_28_113113\error_path_following.png)

**Video:**

<video src=".\videos\tail_chase.mp4" width="640" controls></video>

### Merged Impact Angle Control Results
![Error e](.\merged_all_results_for_impact_angle_control_2025_07_28_113632\error.png)

![Pursuer Trajectory](.\merged_all_results_for_impact_angle_control_2025_07_28_113632\trajectory.png)

![Flight-path Angle](.\merged_all_results_for_impact_angle_control_2025_07_28_113632\flight_path_angle.png)

![Acceleration History](.\merged_all_results_for_impact_angle_control_2025_07_28_113632\acceleration.png)

### Impact Angle Control 45 Degrees Results
![Error e](.\impact_angle_45_control_results_scenario12025_07_28_115042\impact_angle_control_error.png)

![Pursuer Trajectory](.\impact_angle_45_control_results_scenario12025_07_28_115042\impact_angle_control_trajectory.png)

![Flight-path Angle](.\impact_angle_45_control_results_scenario12025_07_28_115042\impact_angle_control_flight_path_angle.png)

![Acceleration History](.\impact_angle_45_control_results_scenario12025_07_28_115042\impact_angle_control_acceleration.png)

**Video:**

<video src="./videos/impact_angle_control_45_degrees.mp4" width="640" controls></video>

---

## Additional Notes
- The models are designed for educational purposes and may require adjustments for specific applications. This project for just a demonstration of the paper results to learn the concepts of biased proportional navigation and impact angle control.
