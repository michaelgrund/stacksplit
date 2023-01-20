function splitdiagnosticplot(Q, T, extime, L, E, N, inc, bazi,sampling, maxtime, pol,...
    phiRC, dtRC, Cmatrix, corFSrc, QTcorRC,...
    phiSC, dtSC, Ematrix, corFSsc, QTcorSC,...
    phiEV, dtEV, LevelSC, LevelRC, LevelEV, splitoption)

% display the results of a rotation-correlation and a energy minimization
% splitting procedure in a single plot
% Inputs are expected in the following order:
%     Q, T
%     E, N
%     inclination, backazimuth, sampling [sec]
%     phiRC
%     dtRC
%     Cmatrix
%     corFastSlowparticleRC - corrected RC particle motion [F S]
%     phiSC
%     dtSC
%     pol: initial polarisation
%     Ematrix
%     sampling
%     corFastSlowparticleSC - corrected SC particle motion [F S]
%     Phi_errorSC   - SC fast axis estimation error interval
%     dt_errorSC    - SC delay time estimation error interval
%     Level         - confidence level for SC energy map

% Andreas Wüstefeld, 12.03.06

global thiseq config

Synfig = findobj('name', 'Diagnostic Viewer','type','figure');
if isempty(Synfig)
    S = get(0,'Screensize');
    Synfig = figure('name', 'Diagnostic Viewer',...
        'Renderer',        'painters',...
        'Color',           'w',...
        'NumberTitle',     'off',...
        'MenuBar',         'none',...
        'PaperType',       config.PaperType,...
        'PaperOrientation','landscape',...
        'PaperUnits',      'centimeter',...
        'position',        [.01*S(3) .1*S(4) .98*S(3) .75*S(4)]);
else
    figure(Synfig)
    clf
    set(Synfig,'PaperOrientation','landscape',...
        'PaperType',       config.PaperType)
end
orient landscape
colormap(gray)

fontsize = get(gcf,'DefaultAxesFontsize')-1;
titlefontsize = fontsize+2;

[axH, axRC, axSC, axSeis] = splitdiagnosticLayout(Synfig);
splitdiagnosticSetHeader(axH, phiRC, dtRC, phiSC, dtSC, phiEV, dtEV, pol, splitoption)

%=============================================================
% by RP and MG
% Save the misfit space:
thiseq.tmpresult.Cmatrix = Cmatrix;
thiseq.tmpresult.Ematrix = Ematrix(:,:,1);  % energymap for SC
thiseq.tmpresult.EVmatrix = Ematrix(:,:,2); % EVmap for SC depending on the selecting setting

%=============================================================

switch splitoption
    case 'Minimum Energy'
        Ematrix = Ematrix(:,:,1);
        optionstr ='Minimum Energy';
        phi = phiSC(2);
        dt  = dtSC(2);
        Level = LevelSC;
        Maptitle = 'Energy Map of T';
    case 'Eigenvalue: max(lambda1 / lambda2)'
        Ematrix = Ematrix(:,:,2);
        optionstr ='Maximum   \lambda_1 / \lambda_2';
        phi = phiEV(2);
        dt  = dtEV(2);
        Level =LevelEV;
        Maptitle = 'Map of Eigenvalues \lambda_1 / \lambda_2';
    case 'Eigenvalue: min(lambda2)'
        Ematrix = Ematrix(:,:,2);
        optionstr ='Minimum  \lambda_2';
        phi = phiEV(2);
        dt  = dtEV(2);
        Level =LevelEV;
        Maptitle = 'Map of Eigenvalue \lambda_2';
        
    case 'Eigenvalue: max(lambda1)'
        Ematrix = Ematrix(:,:,2);
        optionstr ='Maximum  \lambda_1';
        phi = phiEV(2);
        dt  = dtEV(2);
        Level =LevelEV;
        Maptitle = 'Map of Eigenvalue \lambda_1';

    case 'Eigenvalue: min(lambda1 * lambda2)'
        Ematrix = Ematrix(:,:,2);
        optionstr ='Minimum   \lambda_1 * \lambda_2';
        phi = phiEV(2);
        dt  = dtEV(2);
        Level =LevelEV;
        Maptitle = 'Map of Eigenvalues \lambda_1 * \lambda_2';
end


%% rotate seismograms for plots
% (backwards == counter-clockwise => use transposed matrix M)
M = rot3D(inc, bazi);

ZEN = M' *[L,  QTcorRC]';
Erc = ZEN(2,:); 
Nrc = ZEN(3,:);

ZEN = M' *[L,  QTcorSC]';
Esc = ZEN(2,:); 
Nsc = ZEN(3,:);

s = size(QTcorRC,1); % selection length


%% x-values for seismogram plots
t = (0:(s-1))*sampling;

%% rotation-correlation method% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fast/slow seismograms
axes(axRC(1))
sumFS1 = sum(abs( corFSrc(:,1) -corFSrc(:,2)));
sumFS2 = sum(abs(-corFSrc(:,1) -corFSrc(:,2)));
if ( sumFS1 < sumFS2 )
    sig = 1;
else
    sig = -1;
end
m1 = max(abs( corFSrc(:,1)));
m2 = max(abs( corFSrc(:,2)));
plot(t, corFSrc(:,1)/m1,'b--',   t,sig*corFSrc(:,2)/m2,'r-','LineWidth',1);
xlim([t(1) t(end)])
%title(['corrected Fast (' char([183 183]) ') & Slow(-)'],'FontSize',titlefontsize);
title('corrected Fast (\color{blue}--\color{black}) & Slow (\color{red}-\color{black})','FontSize',titlefontsize);
set(gca,'Ytick' , [-1 0 1])
ylabel('Rotation-Correlation','FontSize',titlefontsize)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% corrected seismograms
axes(axRC(2))
plot(t, QTcorRC(:,1),'b--',    t, QTcorRC(:,2) ,'r-','LineWidth',1);
%title([' corrected Q(' char([183 183]) ') & T(-)'],'FontSize',titlefontsize);
title('corrected Q (\color{blue}--\color{black}) & T (\color{red}-\color{black})','FontSize',titlefontsize);
xlim([t(1) t(end)])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% surface particle motion
axes(axRC(3))
plot(E, N, 'b--', Erc, Nrc,'r-','LineWidth',1);
xlabel('\leftarrowW - E\rightarrow', 'Fontsize',fontsize-1);
ylabel('\leftarrowS - N\rightarrow', 'Fontsize',fontsize-1);
%title(['Particle motion before (' char([183 183]) ') & after (-)'],'FontSize',titlefontsize);
title('Particle motion before (\color{blue}--\color{black}) & after (\color{red}-\color{black})','FontSize',titlefontsize);
axis equal

tmp = max([abs(xlim) abs(ylim)]); % set [0 0] to centre of plot
set(gca, 'xlim',[-tmp tmp], 'ylim',[-tmp tmp], 'XtickLabel',[], 'YtickLabel',[])
set(gca, 'Ytick',get(gca,'Xtick'))
hold on
X = sin(bazi/180*pi)*tmp;
Y = cos(bazi/180*pi)*tmp;
plot( [-X X], [-Y Y], 'k:' )
hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% correlation map
axes(axRC(4))
hold on
f  = size(Cmatrix);
ts = linspace(0,maxtime,f(2));
ps = linspace(-90,90,f(1));

maxi = max(Cmatrix(:)); % always <=  1 since correlation coeffcient (^5)
mini = min(Cmatrix(:)); % always >= -1
maxmin = abs(mini - maxi)/2; % always between 0 and 1

nb_contours = 12;floor((1 - maxmin)*9);
%[C, h] = contourf('v6',ts,ps,-Cmatrix,-[LevelRC LevelRC]); 
[C, h] = contourf(ts,ps,-Cmatrix,-[LevelRC LevelRC]);
contour(ts, ps, Cmatrix, nb_contours);



B = mod(bazi,90);
plot([0 0]+sampling, [B B-90],'k>','markersize',5,'linewidth',1,'MarkerFaceColor','k' )
plot([maxtime maxtime]-sampling, [B B-90],'k<','markersize',5,'linewidth',1,'MarkerFaceColor','k' )
line([dtRC(2) dtRC(2)],[-90 90],'Color',[0 0 1])
line([0 maxtime], [phiRC(2) phiRC(2)],'Color',[0 0 1])
title('Map of Correlation Coefficient','FontSize',titlefontsize);
xlabel('delay time / s', 'Fontsize',fontsize-1);
ylabel('fast axis', 'Fontsize',fontsize-1)
% label = ['0' sprintf('|%u',1:maxtime) 'sec'];
set(gca, 'Xtick',0:1:maxtime, 'Ytick',-90:30:90, 'xMinorTick','on', 'yminorTick','on')
axis([ts(1) ts(end) -90 90])
%set(h,'FaceColor',[1 1 1]*.90,'EdgeColor','k','linestyle','-','linewidth',1)
faceobjects = get(h,'Children');
set(faceobjects,'FaceColor',[1 1 1]*.90);
set(faceobjects,'EdgeColor','k');
set(faceobjects,'linestyle','-');
set(faceobjects,'linewidth',1);



hold off



%%  Silver & Chan
% fast/slow seismograms
axes(axSC(1))
sumFS1 = sum(abs( corFSsc(:,1) -corFSsc(:,2)));
sumFS2 = sum(abs(-corFSsc(:,1) -corFSsc(:,2)));
if ( sumFS1 < sumFS2 )
    sig = 1;
else
    sig = -1;
end
m1 = max(abs( corFSsc(:,1)));
m2 = max(abs( corFSsc(:,2)));
plot(  t, corFSsc(:,1)/m1,'b--',    t, sig*corFSsc(:,2)/m2 ,'r-','LineWidth',1);
xlim([t(1) t(end)])
ylim([-1 1])
%title(['corrected Fast (' char([183 183]) ') & Slow(-)'],'FontSize',titlefontsize);
title('corrected Fast (\color{blue}--\color{black}) & Slow (\color{red}-\color{black})','FontSize',titlefontsize);
set(gca,'Ytick' , [-1 0 1])
ylabel(optionstr,'FontSize',titlefontsize)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% corrected seismograms (in ray system)
axes(axSC(2))
plot(t, QTcorSC(:,1),'b--',    t, QTcorSC(:,2) ,'r-','LineWidth',1);
%title([' corrected Q(' char([183 183]) ') & T(-)'],'FontSize',titlefontsize);
title('corrected Q (\color{blue}--\color{black}) & T (\color{red}-\color{black})', 'FontSize',titlefontsize);
xlim([t(1) t(end)])



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% surface particle motion
axes(axSC(3))
hold on
plot(E, N, 'b--', Esc, Nsc,'r-','LineWidth',1);
xlabel('\leftarrowW - E\rightarrow', 'Fontsize',fontsize-1);
ylabel('\leftarrowS - N\rightarrow', 'Fontsize',fontsize-1);
%title(['Particle motion before (' char([183 183]) ') & after (-)'],'FontSize',titlefontsize);
title('Particle motion before (\color{blue}--\color{black}) & after (\color{red}-\color{black})','FontSize',titlefontsize);
axis equal

tmp = max([abs(xlim) abs(ylim)]); % set [0 0] to centre of plot
set(gca, 'xlim',[-tmp tmp], 'ylim',[-tmp tmp], 'XtickLabel',[], 'YtickLabel',[])
set(gca, 'Ytick',get(gca,'Xtick'))
hold on
X = sin(bazi/180*pi)*tmp;
Y = cos(bazi/180*pi)*tmp;
plot( [-X X], [-Y Y], 'k:' )
hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% energy map
axes(axSC(4))
hold on
f  = size(Ematrix);
ts = linspace(0,maxtime,f(2));
ps = linspace(-90,90,f(1));


maxi = max(abs(Ematrix(:)));
mini = min(abs(Ematrix(:)));
nb_contours = floor((1 - mini/maxi)*10);
%[C, h] = contourf('v6',ts,ps,-Ematrix,-[Level Level]); 
[C, h] = contourf(ts,ps,-Ematrix,-[Level Level]);
contour(ts, ps, Ematrix, nb_contours);




B = mod(bazi,90); % backazimuth lines
plot([0 0]+sampling, [B B-90],'k>','markersize',5,'linewidth',1,'MarkerFaceColor','k' )
plot([maxtime maxtime]-sampling, [B B-90],'k<','markersize',5,'linewidth',1,'MarkerFaceColor','k' )
line([0 maxtime], [phi phi],'Color',[0 0 1])
line([dt dt],[-90 90],'Color',[0 0 1])



hold off
axis([0 maxtime -90 90])
set(gca, 'Xtick',0:1:maxtime, 'Ytick',-90:30:90, 'xMinorTick','on', 'yminorTick','on')
xlabel('delay time / s', 'Fontsize',fontsize-1);
ylabel('fast axis', 'Fontsize',fontsize-1)
title(Maptitle,'FontSize',titlefontsize);
%set(h,'FaceColor',[1 1 1]*.90,'EdgeColor','k','linestyle','-','linewidth',1)
set(faceobjects,'FaceColor',[1 1 1]*.90);
set(faceobjects,'EdgeColor','k');
set(faceobjects,'linestyle','-');
set(faceobjects,'linewidth',1);



%% plot initial seismograms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axes(axSeis(1))
t2 = (0:length(Q)-1)*sampling - extime;
xx  = [0 0 s s]*sampling;
yy  = [0 0 1 1 ];
tmp = fill(xx, yy, [1 1 1]*.90, 'EdgeColor','None'); % selection marker

hold on
plot(t2, Q/max(abs(Q)), 'b--', t2, T/max(abs(T)), 'r-','LineWidth',1)

tt = thiseq.phase.ttimes;
A  = thiseq.a-extime;
F  = thiseq.f+extime;
tt = tt(A<=tt& tt<=F); % phase arrival within selection
T  = [tt;tt];
T  = T-thiseq.a;
yy = repmat(ylim',size(tt));
plot(T,yy,'k:')

hold off

% title({['Before correction: Q(' char([183 183]) ') & T(-)']},'FontSize',fontsize);
xlim([t2(1) t2(end)])
yy = [ylim fliplr(ylim)];
set(tmp,'yData',yy)
set(axSeis,'Layer','Top')

%% plot stereoplot of current measurement %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%,'EraseMode','Xor'
if license('checkout', 'MAP_Toolbox')
    axes(axSeis(2))
    b = repmat(bazi,1,3);
    I = repmat(thiseq.tmpInclination,1,3);
    [h, m] = stereoplot(b, I , [phiRC(2) phiSC(2) phiEV(2)], [dtRC(2) dtSC(2) dtEV(2)]);
    set(h(1), 'Color',[0 .6 0])
    set(h(2), 'Color',[1 0 0])
    set(h(3), 'Color',[0 0 1])
    L = axis;

    text(0, L(4),['  Inc = \bf' num2str(thiseq.tmpInclination,'%4.1f') char(186)], ...
        'Fontname','Fixedwidth', 'VerticalAlignment','top','HorizontalAlignment','center')
else
    %delete(axSeis(2))
    % manually adding a rough stereo net
    axes(axSeis(2))
    % location defined by the back-azimuth and the inclination
    % Plot a vector in the measured directions (phi) with length determined
    % by dt
    % We want a little line with its center at the baz/inc coordinate
    % We can break up the phi/dt vector into i,j coordinates and plot as
    % deviation
    % Also plot polar axes at constant inclination for guide
    
    % Location of measurement in inclination-backazimuth space
    x0 = thiseq.tmpInclination * cos((90-bazi)*(pi/180));
    y0 = thiseq.tmpInclination * sin((90-bazi)*(pi/180));
    
    % RC coordinates
    x1RC = x0-(2*dtRC(2) * cos((90-phiRC(2))*pi/180))/2;
    y1RC = y0-(2*dtRC(2) * sin((90-phiRC(2))*pi/180))/2;
    x2RC = x0+(2*dtRC(2) * cos((90-phiRC(2))*pi/180))/2;
    y2RC = y0+(2*dtRC(2) * sin((90-phiRC(2))*pi/180))/2;
    
    % SC coordinates
    x1SC = x0-(2*dtSC(2) * cos((90-phiSC(2))*pi/180))/2;
    y1SC = y0-(2*dtSC(2) * sin((90-phiSC(2))*pi/180))/2;
    x2SC = x0+(2*dtSC(2) * cos((90-phiSC(2))*pi/180))/2;
    y2SC = y0+(2*dtSC(2) * sin((90-phiSC(2))*pi/180))/2;
    
    % EV coordinates
    x1EV = x0-(2*dtEV(2) * cos((90-phiEV(2))*pi/180))/2;
    y1EV = y0-(2*dtEV(2) * sin((90-phiEV(2))*pi/180))/2;
    x2EV = x0+(2*dtEV(2) * cos((90-phiEV(2))*pi/180))/2;
    y2EV = y0+(2*dtEV(2) * sin((90-phiEV(2))*pi/180))/2;
    
    hold on
    % Plot background info
    axis([-10 10 -10 10]);  % Hope this covers the possible inclination space!
    plot(5*cos(0:0.1:2*pi),5*sin(0:0.1:2*pi),'k-')
    plot(10*cos(0:0.1:2*pi),10*sin(0:0.1:2*pi),'k-')
    plot(20*cos(0:0.1:2*pi),20*sin(0:0.1:2*pi),'k-')
    % Plot location
    plot(x0,y0,'k*');
    
    % Plot splits
    plot([x1RC, x2RC], [y1RC, y2RC],'g');
    plot([x1SC, x2SC], [y1SC, y2SC],'r');
    plot([x1EV, x2EV], [y1EV, y2EV],'b');
    
    
    L = axis;
    text(0, L(4),['  Inc = \bf' num2str(thiseq.tmpInclination,'%4.1f') char(186)], ...
        'Fontname','Fixedwidth', 'VerticalAlignment','top','HorizontalAlignment','center')
    
end
%% EOF %%