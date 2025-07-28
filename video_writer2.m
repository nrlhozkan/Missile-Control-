clc; clear all; close all

%% 0) Load path‐following results
load('tail_chase_s1.mat','out');
tf = out.tout(end);

%% 1) Build time vector
t = linspace(0, tf, numel(out.xP_out));

%% 2) Prepare output directory
outputDir = fullfile(pwd,'videos');
if ~exist(outputDir,'dir'), mkdir(outputDir); end

%% 3) Animation parameters
fps         = 30;               % real‐time
skip        = 2;                % decimate frames
trailDecim  = 5;                % show every 5th trail point
figPos      = [100 100 900 650];
textFont    = 12;

% collect spans
allX   = [out.xP_out; out.xT_out];
spanX  = max(allX) - min(allX);

% missile dims
mslLen = 0.05 * spanX;
mslWid = mslLen / 6;

% arrow scales
accScale     = 0.1 * spanX / max(abs(out.a_out));  % accel →10% span
speedP       = 25;                                 % pursuer speed
arrowScaleP  = 0.1 * spanX / speedP;               % →10% span
% get target speed vector
if isfield(out,'vT_out')
    vT_out = out.vT_out;
else
    dt      = out.tout(2)-out.tout(1);
    vT_out  = [hypot(diff(out.xT_out),diff(out.yT_out))/dt; 0];
end
arrowScaleT = 0.1 * spanX / max(vT_out);            % →10% span

initialGammaP = rad2deg(out.gamma_out(1));
initialGammaT = rad2deg(out.gammaT_out(1));

%% 4) VideoWriter (real‐time)
frameIdx = 1:skip:numel(t);
if frameIdx(end)~=numel(t), frameIdx(end+1)=numel(t); end
numFrames = numel(frameIdx);

videoFile = fullfile(outputDir,'path_following_missiles.mp4');
vw        = VideoWriter(videoFile,'MPEG-4');
vw.FrameRate = numFrames / tf;
open(vw);

%% 5) Figure & fixed axes
hFig = figure('Units','pixels','Position',figPos,'Color','w');
hAx  = axes('Parent',hFig); hold(hAx,'on');
axis(hAx,'equal'); grid(hAx,'on');
xlabel('Downrange (m)','FontSize',textFont);
ylabel('Crossrange (m)','FontSize',textFont);
title('Path‐Following: Pursuer & Moving Target','FontSize',textFont);

xlim(hAx,[min(allX)-10, max(allX)+50]);
ylim(hAx,[min([out.yP_out; out.yT_out])-10, max([out.yP_out; out.yT_out])+50]);

% text layout
xLim = get(hAx,'XLim'); yLim = get(hAx,'YLim');
mX   = 0.05*diff(xLim); mY = 0.05*diff(yLim);
xL   = xLim(1)+mX;      y0 = yLim(2)-mY;
yStep= 1.2*textFont;
xR   = xLim(2)-mX;

%% 6) Initialize graphics handles
hTrailP = plot(hAx, NaN,NaN,'b-','LineWidth',1.5);
hTrailT = plot(hAx, NaN,NaN,'k--','LineWidth',1);

% missile body (nose at origin)
bodyX = [0, .8*mslLen, .8*mslLen, 0] - mslLen;
bodyY = [mslWid, mslWid, -mslWid, -mslWid];
noseX = [.8*mslLen, mslLen, .8*mslLen] - mslLen;
noseY = [mslWid,     0,      -mslWid];

% pursuer missile (red)
hBodyP = patch('XData',bodyX,'YData',bodyY,'FaceColor','r','EdgeColor','k','Parent',hAx);
hNoseP = patch('XData',noseX,'YData',noseY,'FaceColor','r','EdgeColor','k','Parent',hAx);
% target missile (blue)
hBodyT = patch('XData',bodyX,'YData',bodyY,'FaceColor','b','EdgeColor','k','Parent',hAx);
hNoseT = patch('XData',noseX,'YData',noseY,'FaceColor','b','EdgeColor','k','Parent',hAx);

% arrows
hAccP = quiver(hAx, NaN,NaN,NaN,NaN,'g','LineWidth',1.5,'MaxHeadSize',2);
hVelP = quiver(hAx, NaN,NaN,NaN,NaN,'c','LineWidth',1.5,'MaxHeadSize',2);
hVelT = quiver(hAx, NaN,NaN,NaN,NaN,'m','LineWidth',1.5,'MaxHeadSize',2);

% dynamic texts (left)
hTxtTime = text(hAx,xL,y0,        '', 'FontSize',textFont,'Color','k');
hTxtGP   = text(hAx,xL,y0-yStep,  '', 'FontSize',textFont,'Color','r');
hTxtGT   = text(hAx,xL,y0-2*yStep,'', 'FontSize',textFont,'Color','b');
hTxtVT   = text(hAx,xL,y0-3*yStep,'', 'FontSize',textFont,'Color','m'); % target speed

% static texts (right)
text(hAx,xR,y0,       sprintf('\\gamma_{P0}=%.1f°',initialGammaP),...
     'FontSize',textFont,'HorizontalAlignment','right','Color','r');
text(hAx,xR,y0-yStep, sprintf('\\gamma_{T0}=%.1f°',initialGammaT),...
     'FontSize',textFont,'HorizontalAlignment','right','Color','b');
text(hAx,xR,y0-2*yStep,sprintf('v_P= %d m/s',speedP),...
     'FontSize',textFont,'HorizontalAlignment','right','Color','c');

drawnow;

%% 7) Animate & write
for ii = 1:numFrames
    k = frameIdx(ii);

    % trails
    set(hTrailP,'XData',out.xP_out(1:trailDecim:k),'YData',out.yP_out(1:trailDecim:k));
    set(hTrailT,'XData',out.xT_out(1:trailDecim:k),'YData',out.yT_out(1:trailDecim:k));

    % pursuer pose
    gP = out.gamma_out(k);
    RP = [cos(gP) -sin(gP); sin(gP) cos(gP)];
    bP = RP*[bodyX;bodyY]; nP = RP*[noseX;noseY];
    xPp= out.xP_out(k); yPp = out.yP_out(k);
    set(hBodyP,'XData',bP(1,:)+xPp,'YData',bP(2,:)+yPp);
    set(hNoseP,'XData',nP(1,:)+xPp,'YData',nP(2,:)+yPp);

    % target pose
    gT = out.gammaT_out(k);
    RT = [cos(gT) -sin(gT); sin(gT) cos(gT)];
    bT = RT*[bodyX;bodyY]; nT = RT*[noseX;noseY];
    xT = out.xT_out(k); yT = out.yT_out(k);
    set(hBodyT,'XData',bT(1,:)+xT,'YData',bT(2,:)+yT);
    set(hNoseT,'XData',nT(1,:)+xT,'YData',nT(2,:)+yT);

    % pursuer accel arrow
    nHatP = [-sin(gP); cos(gP)];
    accP  = out.a_out(k) * accScale * nHatP;
    set(hAccP,'XData',xPp,'YData',yPp,'UData',accP(1),'VData',accP(2));

    % pursuer speed arrow (constant 25 m/s)
    vHatP = [cos(gP); sin(gP)];
    velP  = speedP * arrowScaleP * vHatP;
    set(hVelP,'XData',xPp,'YData',yPp,'UData',velP(1),'VData',velP(2));

    % target speed arrow (from vT_out)
    vHatT = [cos(gT); sin(gT)];
    velT  = vT_out(k) * arrowScaleT * vHatT;
    set(hVelT,'XData',xT,'YData',yT,'UData',velT(1),'VData',velT(2));

    % dynamic texts
    set(hTxtTime,'String',sprintf('t = %.2f s', t(k)));
    set(hTxtGP,  'String',sprintf('\\gamma_P = %.1f°', rad2deg(gP)));
    set(hTxtGT,  'String',sprintf('\\gamma_T = %.1f°', rad2deg(gT)));
    set(hTxtVT,  'String',sprintf('v_T = %.1f m/s', vT_out(k)));

    drawnow limitrate;
    writeVideo(vw,getframe(hFig));
end

%% 8) Hold last frame for 2 s
extraSec    = 2;
extraFrames = round(extraSec * vw.FrameRate);
lastFrame   = getframe(hFig);
for i = 1:extraFrames
    writeVideo(vw,lastFrame);
end

close(vw);
fprintf('Animation saved to:\n%s\n', videoFile);
