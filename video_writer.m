%% make_missile_to_target_with_annotations.m

clc; clear all; close all

%% 0) Load simulation results
load('impact_angle_45_control_s1.mat','out');    % out.xP_out, out.yP_out, out.gamma_out, out.a_out, out.tout
tf = out.tout(end);

%% 1) Build & trim at 1 m from target
t_full   = linspace(0, tf, numel(out.xP_out));
target_x = 5000; target_y = 0;
dist     = hypot(out.xP_out - target_x, out.yP_out - target_y);

% find closest approach or 1 m threshold
[minDist, minIdx] = min(dist);
if minDist <= 1
    idx_end = find(dist <= 1, 1);
else
    warning('Never within 1 m, closest = %.2f m, stopping there.', minDist);
    idx_end = minIdx;
end

t     = t_full(1:idx_end);
xP    = out.xP_out(1:idx_end);
yP    = out.yP_out(1:idx_end);
gamma = out.gamma_out(1:idx_end);
a_out = out.a_out(1:idx_end);

%% 2) Prepare output directory
outputDir = fullfile(pwd,'videos');
if ~exist(outputDir,'dir'), mkdir(outputDir); end

%% 3) Parameters
fps          = 60;                 % frames/s
skip         = 3;                  % show every 3rd sample
trailDecim   = 5;                  % plot trail every 5th point
figPos       = [100 100 900 650];  % window in pixels
textFont     = 12;                 % unified font size
initialSpeed = 250;                % m/s

spanX         = max(xP)-min(xP);
mslLen        = 0.05*spanX;        % missile length
mslWid        = mslLen/6;          % half‐width
arrowScale    = 0.1*spanX / max(abs(a_out));   % accel →10% span
arrowVelScale = 0.05*spanX / initialSpeed;     % speed →10% span

rTar = mslLen;                      % target radius
th   = linspace(0,2*pi,100);

initialAngleDeg = rad2deg(gamma(1));

%% 4) VideoWriter (real-time playback)
% build our frame index (you already have this in step 8, but we need it here first)
frameIdx = 1:skip:numel(t);
if frameIdx(end) ~= numel(t)
    frameIdx(end+1) = numel(t);
end

% compute how many frames and set FrameRate = frames / totalTime
numFrames = numel(frameIdx);
videoFile = fullfile(outputDir,'impact_angle_control_45_degree.mp4');
vw        = VideoWriter(videoFile,'MPEG-4');
vw.FrameRate = numFrames / tf;   % so video duration ≈ tf seconds
open(vw);

%% 5) Figure & fixed axes
hFig = figure('Units','pixels','Position',figPos,'Color','w');
hAx  = axes('Parent',hFig); hold(hAx,'on');
axis(hAx,'equal'); grid(hAx,'on');
xlim(hAx,[-250 5500]); ylim(hAx,[-250 2000]);
xlabel(hAx,'Downrange (m)','FontSize',textFont);
ylabel(hAx,'Altitude (m)','FontSize',textFont);
title(hAx,'Missile Flight to Target','FontSize',textFont);

% compute text positions
xLimits = get(hAx,'XLim'); yLimits = get(hAx,'YLim');

rangeX  = diff(xLimits); rangeY = diff(yLimits);
marginX = 0.05*rangeX; marginY = 0.05*rangeY;
xTextL  = 50;                                   % left side constant
yText0  = yLimits(2) - marginY;                 % top row y
yStep   = 13*textFont;                         % vertical spacing

xTextR  = xLimits(2) - marginX;                 % right side column

%% 6) Draw target at (5000,0)
plot(hAx, target_x + rTar*cos(th),  target_y + rTar*sin(th),  'k-', 'LineWidth',1.5);
plot(hAx, [target_x-rTar, target_x+rTar], [target_y, target_y],        'k-', 'LineWidth',1.5);
plot(hAx, [target_x, target_x],        [target_y-rTar, target_y+rTar], 'k-', 'LineWidth',1.5);

%% 7) Initialize graphics handles
hTrail = plot(hAx, NaN,NaN,'b-','LineWidth',1.5);

% missile shape (nose at local origin)
bodyX = [0,0.8*mslLen,0.8*mslLen,0] - mslLen;
bodyY = [ mslWid, mslWid,-mslWid,-mslWid];
noseX = [0.8*mslLen,mslLen,0.8*mslLen] - mslLen;
noseY = [ mslWid,     0,     -mslWid];

hBody = patch('XData',bodyX,'YData',bodyY, 'FaceColor','r','EdgeColor','k','Parent',hAx);
hNose = patch('XData',noseX,'YData',noseY, 'FaceColor','r','EdgeColor','k','Parent',hAx);

hAcc = quiver(hAx, NaN,NaN,NaN,NaN,'Color','g','LineWidth',1.5,'MaxHeadSize',2);
hVel = quiver(hAx, NaN,NaN,NaN,NaN,'Color','m','LineWidth',1.5,'MaxHeadSize',2);

% dynamic texts (left)
hTextT = text(hAx, xTextL,       yText0,         '', 'FontSize',textFont,'HorizontalAlignment','left');
hTextG = text(hAx, xTextL,       yText0-yStep,   '', 'FontSize',textFont,'HorizontalAlignment','left');
hTextP = text(hAx, xTextL,       yText0-2*yStep, '', 'FontSize',textFont,'HorizontalAlignment','left');

% static texts (right)
text(hAx, xTextR, yText0,             sprintf('\\gamma_{0} = %.1f°', initialAngleDeg), ...
     'FontSize',textFont,'HorizontalAlignment','right');
text(hAx, xTextR, yText0-yStep,       sprintf('Speed = %d m/s', initialSpeed),       ...
     'FontSize',textFont,'HorizontalAlignment','right');

drawnow;

%% 8) Prepare frame indices to include final point
frameIdx = 1:skip:numel(t);
if frameIdx(end) ~= numel(t)
    frameIdx(end+1) = numel(t);
end

%% 9) Loop over frames and write
for ii = 1:numel(frameIdx)
    k = frameIdx(ii);

    % update trail
    idxs = 1:trailDecim:k;
    set(hTrail,'XData',xP(idxs),'YData',yP(idxs));
    
    % missile pose
    gk  = gamma(k);
    Rk  = [cos(gk) -sin(gk); sin(gk) cos(gk)];
    bpk = Rk*[bodyX;bodyY]; npk = Rk*[noseX;noseY];
    xk  = xP(k); yk = yP(k);
    set(hBody,'XData',bpk(1,:)+xk,'YData',bpk(2,:)+yk);
    set(hNose,'XData',npk(1,:)+xk,'YData',npk(2,:)+yk);
    
    % perpendicular accel arrow
    nHat = [-sin(gk); cos(gk)];
    acc  = a_out(k)*arrowScale * nHat;
    set(hAcc,'XData',xk,'YData',yk,'UData',acc(1),'VData',acc(2));
    
    % fixed speed arrow
    tHat = [cos(gk); sin(gk)];
    vel  = initialSpeed*arrowVelScale * tHat;
    set(hVel,'XData',xk,'YData',yk,'UData',vel(1),'VData',vel(2));
    
    % update dynamic texts
    set(hTextT,'String',sprintf('t = %.2f s',      t(k)));
    set(hTextG,'String',sprintf('\\gamma = %.1f°', rad2deg(gk)));
    set(hTextP,'String',sprintf('pos = [%.2f, %.2f] m', xk, yk));
    
    drawnow limitrate;
    writeVideo(vw, getframe(hFig));
end

%% 10) Clean up
% How many extra seconds to hold the final image?
extraSec     = 2;  
% Calculate how many frames that is at your video frame rate:
extraFrames  = round(extraSec * vw.FrameRate);

% Grab the last frame
lastFrame = getframe(hFig);

% Write it extraFrames times
for i = 1:extraFrames
    writeVideo(vw, lastFrame);
end

% --- now close ---
close(vw);
fprintf('Video saved to:\n%s\n', videoFile);