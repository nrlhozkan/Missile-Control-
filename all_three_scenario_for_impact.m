%------------------------------------------------------------------
% Overlay Plots from Multiple MAT-Files
%   → Uses each file’s own time-vector, datetime timestamp, and
%     thicker/brighter lines
%------------------------------------------------------------------
clc; clear; close all;

% 1) Your files, styles & labels
matFiles   = {'impact_angle_control_s1.mat', ...
              'impact_angle_control_s2.mat', ...
              'impact_angle_control_s3.mat'};
% only line-styles here; colors defined separately
lineStyles = {'-',':','-.'};
legLabels  = {'Paper','Ref 1','k = 0'};

% 2) Load data and pull each time-vector from its file
N     = numel(matFiles);
outs  = cell(1,N);
t_all = cell(1,N);
for i = 1:N
    tmp = load(matFiles{i});
    assert(isfield(tmp,'out'), ...
           'File "%s" must contain a struct named "out".', matFiles{i});
    o = tmp.out;
    outs{i} = o;
    % assume each MAT saved its own time vector in o.tout
    t_all{i} = o.tout;
end

% 3) Create a datetime‐based timestamped folder
timestamp = char(datetime('now','Format','yyyy_MM_dd_HHmmss'));
outputDir = fullfile(pwd, ['merged_all_results_for_impact_angle_control_' timestamp]);
mkdir(outputDir);

% 4) Plot settings: bigger line width, explicit bright colors
figW       = 800;
figH       = 600;
fs         = 14;
lw         = 3;     % thicker lines
dpi        = 300;
% bright RGB colors for each dataset
colors     = [ ...
    0.0, 0.5, 1.0;   % bright blue
    1.0, 0.2, 0.2;   % bright red
    0.2, 0.8, 0.2    % bright green
];

%% Figure 1: Trajectory
fig = figure('Units','points','Position',[100,100,figW,figH],'Color','w');
hold on
hTraj = gobjects(1,N);
for k = 1:N
    hTraj(k) = plot( ...
        outs{k}.xP_out, outs{k}.yP_out, ...
        'LineStyle',   lineStyles{k}, ...
        'Color',       colors(k,:), ...
        'LineWidth',   lw ...
    );
end
hold off
axis equal; grid on
xlabel('Downrange (m)','FontSize',fs)
ylabel('Altitude (m)','FontSize',fs)
title('Impact-Angle Control: Pursuer Trajectory','FontSize',fs)
legend(hTraj, legLabels, 'Location','best','FontSize',fs)
drawnow
exportgraphics(fig, fullfile(outputDir,'trajectory.png'),'Resolution',dpi)

%% Figure 2: Error vs Time
fig = figure('Units','points','Position',[100,100,figW,figH],'Color','w');
hold on
hErr = gobjects(1,N);
for k = 1:N
    hErr(k) = plot( ...
        t_all{k}, outs{k}.e_out, ...
        'LineStyle',   lineStyles{k}, ...
        'Color',       colors(k,:), ...
        'LineWidth',   lw ...
    );
end
hold off
grid on
xlabel('Time (s)','FontSize',fs)
ylabel('Error e','FontSize',fs)
title('Error (Impact-Angle Control)','FontSize',fs)
legend(hErr, legLabels, 'Location','best','FontSize',fs)
drawnow
exportgraphics(fig, fullfile(outputDir,'error.png'),'Resolution',dpi)

%% Figure 3: Acceleration vs Time
fig = figure('Units','points','Position',[100,100,figW,figH],'Color','w');
hold on
hAcc = gobjects(1,N);
for k = 1:N
    hAcc(k) = plot( ...
        t_all{k}, outs{k}.a_out, ...
        'LineStyle',   lineStyles{k}, ...
        'Color',       colors(k,:), ...
        'LineWidth',   lw ...
    );
end
hold off
grid on
xlabel('Time (s)','FontSize',fs)
ylabel('a (m/s^2)','FontSize',fs)
title('Acceleration History (Impact-Angle Control)','FontSize',fs)
legend(hAcc, legLabels, 'Location','best','FontSize',fs)
drawnow
exportgraphics(fig, fullfile(outputDir,'acceleration.png'),'Resolution',dpi)

%% Figure 4: Flight-path Angle vs Time
fig = figure('Units','points','Position',[100,100,figW,figH],'Color','w');
hold on
hGam = gobjects(1,N);
for k = 1:N
    gamma_deg = rad2deg(outs{k}.gamma_out);
    hGam(k) = plot( ...
        t_all{k}, gamma_deg, ...
        'LineStyle',   lineStyles{k}, ...
        'Color',       colors(k,:), ...
        'LineWidth',   lw ...
    );
end
hold off
grid on
xlabel('Time (s)','FontSize',fs)
ylabel('\Flight-path Angle (deg)','FontSize',fs)
title('Flight-path Angle (Impact-Angle Control)','FontSize',fs)
legend(hGam, legLabels, 'Location','best','FontSize',fs)
drawnow
exportgraphics(fig, fullfile(outputDir,'flight_path_angle.png'),'Resolution',dpi)

fprintf('All figures saved into:\n%s\n', outputDir)
