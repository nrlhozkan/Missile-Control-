clc; clear all; close all;

mode = 'impact_angle_control';  % 'impact_angle_control' or 'tail_chase'

damping_ratio = cos(pi/4);  % ksi
xP_initial = 0; yP_initial = 0; % initial position 
switch mode
    case 'impact_angle_control'
        scenarios_impact_angle_control = 1; % 1 (paper)  ---> k= -Kp/Ki , 2 -----> k=0 and 3----->(reference[1])
        if scenarios_impact_angle_control == 3
            N = 3;
        else
            N = 2;                         % navigation gain
        end
        vP = 250;                      % pursuer speed [m/s] 
        r0 = 5000;                     % stationary‑target range
        gamma0 = deg2rad(15);          % initial flight‑path angle of pursuer [rad]
        gammaf = -pi/4;                % final flight-path angle (vertical downwards)
        Ki = (0.2/damping_ratio)^2;    % integrator gain (impact angle control)
        Kp = 2*damping_ratio*sqrt(Ki); % proportional gain (impact angle control)
        xT0 = r0 ; yT0 = 0;           % position of the stationary target
        xP0 = xP_initial;              % initial position of the pursuer in x direction.
        yP0 = yP_initial;              % initial position of the pursuer in y direction.
        dx = xT0 - xP0;
        dy = yT0 - yP0;
        lambda0 = atan2(dy, dx);        % initial LOS rate
        e0 = lambda0*N - gamma0 - (N - 1)*gammaf; % initial error
        switch scenarios_impact_angle_control
            case 1
                k = -Kp/Ki;              % gain
                main_guidance = 1; % main guidance
                disp('Impact angle control with k = -Kp/Ki')
            case 2
                k = 0;                   % gain for k=0
                e0 =0
                main_guidance = 1; % main guidance
                disp('Impact angle control with k = 0')
            case 3
                k=0; % this is not important for reference 1
                main_guidance = 0; % no main guidance
                disp('Impact angle control with k = 0 for reference 1')
        end
        I0 = k*e0; 
        tf = 50 ;                     % for the paper (this is a dummy time, simulation is broken by r<1 m)
        
    case 'tail_chase'
        scanerios_tail_chase = 1; %1 ----> main paper and 2 -----> reference 9 
        switch scanerios_tail_chase
            case 1
                N = 1.25;                      % navigation gain
                main_guidance = 1;
                disp('Tail chase with N = 1.25 for the main paper')
            % case 2
            %     N = 3;                          % navigation gain
            %     main_guidance = 0;
            %     disp('Tail chase with N = 3 for reference 9')
        end
        x_switch = 200;                    % length of the straight segment (m)
        r_star      = 25;    % r* in eq. (25)
        vP = 25;     
        yLeadIn = 100;                 % height of the straight segment (m)
        xT0 = 0 ; yT0 = yLeadIn;       % initial position of the target
        xP0 = xP_initial;              % initial position of the pursuer in x direction.
        yP0 = yP_initial;              % initial position of the pursuer in y direction.
        dx = xT0 - xP0;
        dy = yT0 - yP0;
        r_0 = sqrt(dx^2 + dy^2);       % initial distance between pursuer and target
        vTy_0 = 0;                       % target speed in y direction (m/s)
        vTx_0 = r_star * vP/r_0;
        lambda0  = atan2(dy, dx);      % initial LOS angle
        Ki = (0.83/damping_ratio)^2;   % integrator gain (path following)
        Kp = 2*damping_ratio*sqrt(Ki); % proportional gain (path following)
        gamma0 = deg2rad(90);          % initial flight-path angle of pursuer [rad]
        gamma_T0 = atan2(vTy_0, vTx_0);    % target/path heading
        e0 = lambda0*N - gamma0 - (N - 1)*gamma_T0; % initial error
        % e0 = 1.570796326794897;
        k = -Kp/Ki;                    % gain
        I0 = k*e0;
        tf = 50;                             % tf is not important. 
        % tSwitch =11
        % R = 100
end