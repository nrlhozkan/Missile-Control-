%------------------------------------------------------------------
% Path-Following Plots (High-Quality Export into Timestamped Folder)
%------------------------------------------------------------------

close all;

% 1) Create a timestamped output folder
timestamp  = datestr(now, 'yyyy_mm_dd_HHMMSS');
% outputDir  = fullfile(pwd, ['ref_9(ode4)_path_following_results_' timestamp]);
outputDir  = fullfile(pwd, ['tail_chase_results_' timestamp]);
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Time vector
simulation_time = (length(out.xP_out))/100
t = linspace(0, simulation_time, numel(out.xP_out));

% Common figure settings
figWidth  = 800;   % points
figHeight = 600;   % points
fontSize  = 14;    % pt
lineW     = 1.5;   % line width
dpi       = 300;   % output resolution

%% 1) Trajectory (Fig. 8)
fig = figure('Units','points','Position',[100,100,figWidth,figHeight], ...
             'Color','w','InvertHardcopy','off');
plot(out.xP_out, out.yP_out, 'b',  'LineWidth', lineW);
hold on;
plot(out.xT_out, out.yT_out, 'k--','LineWidth',1);
hold off;
axis equal; grid on;
xlabel('Downrange (m)', 'FontSize', fontSize);
ylabel('Crossrange (m)', 'FontSize', fontSize);
title('Path-Following: Pursuer vs. Virtual Target', 'FontSize', fontSize);
set(gca, 'FontSize', fontSize);
drawnow;
exportgraphics(fig, fullfile(outputDir, 'trajectory_path_following.png'), 'Resolution', dpi);

%% 2) Error vs. time (Fig. 9)
fig = figure('Units','points','Position',[100,100,figWidth,figHeight], ...
             'Color','w','InvertHardcopy','off');
plot(t, out.e_out, 'b', 'LineWidth', lineW);
grid on;
xlabel('Time (s)', 'FontSize', fontSize);
ylabel('Error e',   'FontSize', fontSize);
title('Error (Path-Following)', 'FontSize', fontSize);
set(gca, 'FontSize', fontSize);
drawnow;
exportgraphics(fig, fullfile(outputDir, 'error_path_following.png'), 'Resolution', dpi);

%% 3) Acceleration vs. time (Fig. 10)
fig = figure('Units','points','Position',[100,100,figWidth,figHeight], ...
             'Color','w','InvertHardcopy','off');
plot(t, out.a_out, 'b', 'LineWidth', lineW);
grid on;
xlabel('Time (s)',    'FontSize', fontSize);
ylabel('a (m/s^2)', 'FontSize', fontSize);
title('Acceleration (Path-Following)', 'FontSize', fontSize);
set(gca, 'FontSize', fontSize);
drawnow;
exportgraphics(fig, fullfile(outputDir, 'acceleration_path_following.png'), 'Resolution', dpi);

%% 4) Flight-path angle vs. time (Fig. 11)
fig = figure('Units','points','Position',[100,100,figWidth,figHeight], ...
             'Color','w','InvertHardcopy','off');
plot(t, rad2deg(out.gamma_out),  'b', 'LineWidth', lineW);
hold on;
plot(t, rad2deg(out.gammaT_out), 'r', 'LineWidth', lineW);
hold off;
grid on;
xlabel('Time (s)',        'FontSize', fontSize);
ylabel('\gamma_P (deg)', 'FontSize', fontSize);
title('Flight-path Angle (Path-Following)', 'FontSize', fontSize);
legend('Pursuer','Virtual Target', 'FontSize', fontSize, 'Location','best');
set(gca, 'FontSize', fontSize);
drawnow;
exportgraphics(fig, fullfile(outputDir, 'flight_path_angle_path_following.png'), 'Resolution', dpi);

fprintf('All figures saved to folder:\n%s\n', outputDir);
