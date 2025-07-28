%------------------------------------------------------------------
% Impact-Angle Control Plots (High-Quality Export into Timestamped Folder)
%------------------------------------------------------------------
close all
% Create timestamped output folder
timestamp  = datestr(now, 'yyyy_mm_dd_HHMMSS');
outputDir  = fullfile(pwd, ['impact_angle_45_control_results_scenario1' timestamp]);
% outputDir  = fullfile(pwd, ['impact_angle_control_results_scenario2_k_0' timestamp]);
% outputDir  = fullfile(pwd, ['impact_angle_control_results_scenario3_ref_1_' timestamp]);
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Discard the last element of each output vector
out.xP_out = out.xP_out(1:end-3);
out.yP_out = out.yP_out(1:end-3);
out.e_out   = out.e_out(1:end-3);
out.a_out   = out.a_out(1:end-3);
out.gamma_out = out.gamma_out(1:end-3);
out.gammaT_out = out.gammaT_out(1:end-3);
out.xT_out = out.xT_out(1:end-3);
out.yT_out = out.yT_out(1:end-3);
out.lambda = out.lambda(1:end-3);
out.tout = out.tout(1:end-3);
out.lambdaDot = out.lambdaDot(1:end-3);

% out.xP_out = out.xP_out(1:end-1);
% out.yP_out = out.yP_out(1:end-1);
% out.e_out   = out.e_out(1:end-1);
% out.a_out   = out.a_out(1:end-1);
% out.gamma_out = out.gamma_out(1:end-1);
% out.gammaT_out = out.gammaT_out(1:end-1);
% out.xT_out = out.xT_out(1:end-1);
% out.yT_out = out.yT_out(1:end-1);
% out.lambda = out.lambda(1:end-1);
% out.tout = out.tout(1:end-1);
% out.lambdaDot = out.lambdaDot(1:end-1);

% Create time vector
simulation_time = (length(out.xP_out))/100
t = linspace(0, simulation_time, numel(out.xP_out));

% Common figure settings
figWidth  = 800;   % points
figHeight = 600;   % points
fontSize  = 14;    % pt
lineW     = 1.5;   % line width
dpi       = 300;   % output resolution

%% 1) Trajectory (Fig. 4)
fig = figure('Units','points','Position',[100,100,figWidth,figHeight], ...
             'Color','w','InvertHardcopy','off');
plot(out.xP_out, out.yP_out, 'b', 'LineWidth', lineW);
axis equal; grid on;
xlabel('Downrange (m)', 'FontSize', fontSize);
ylabel('Altitude (m)', 'FontSize', fontSize);
title('Impact-Angle Control: Pursuer Trajectory', 'FontSize', fontSize);
set(gca, 'FontSize', fontSize);
drawnow;
exportgraphics(fig, fullfile(outputDir, 'impact_angle_control_trajectory.png'), ...
               'Resolution', dpi);

%% 2) Error vs. time (Fig. 5)
fig = figure('Units','points','Position',[100,100,figWidth,figHeight], ...
             'Color','w','InvertHardcopy','off');
plot(t, out.e_out, 'b', 'LineWidth', lineW);
grid on;
xlabel('Time (s)', 'FontSize', fontSize);
ylabel('Error (rad)',   'FontSize', fontSize);
title('Error (Impact-Angle Control)', 'FontSize', fontSize);
set(gca, 'FontSize', fontSize);
drawnow;
exportgraphics(fig, fullfile(outputDir, 'impact_angle_control_error.png'), ...
               'Resolution', dpi);

%% 3) Acceleration vs. time (Fig. 6)
fig = figure('Units','points','Position',[100,100,figWidth,figHeight], ...
             'Color','w','InvertHardcopy','off');
plot(t, out.a_out, 'b', 'LineWidth', lineW);
grid on;
xlabel('Time (s)',     'FontSize', fontSize);
ylabel('a (m/s^2)',  'FontSize', fontSize);
title('Acceleration History (Impact-Angle Control)', 'FontSize', fontSize);
set(gca, 'FontSize', fontSize);
drawnow;
exportgraphics(fig, fullfile(outputDir, 'impact_angle_control_acceleration.png'), ...
               'Resolution', dpi);

%% 4) Flight-path angle vs. time (Fig. 7)
fig = figure('Units','points','Position',[100,100,figWidth,figHeight], ...
             'Color','w','InvertHardcopy','off');
plot(t, rad2deg(out.gamma_out), 'b', 'LineWidth', lineW);
grid on;
xlabel('Time (s)',       'FontSize', fontSize);
ylabel('\Path Angle (deg)', 'FontSize', fontSize);
title('Flight-path Angle (Impact-Angle Control)', 'FontSize', fontSize);
set(gca, 'FontSize', fontSize);
drawnow;
exportgraphics(fig, fullfile(outputDir, 'impact_angle_control_flight_path_angle.png'), ...
               'Resolution', dpi);

fprintf('All Impact-Angle Control figures saved to:\n%s\n', outputDir);
