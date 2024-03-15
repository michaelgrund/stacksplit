function SS_splitdiagnosticplot( ...
    Q, T, extime, L, E, N, inc, bazi,sampling, maxtime, pol,...
    phiRC, dtRC, Cmatrix, corFSrc, QTcorRC,...
    phiSC, dtSC, Ematrix, corFSsc, QTcorSC,...
    phiEV, dtEV, LevelSC, LevelRC, LevelEV, splitoption, bazi_int, dist_int, h ...
)
%==========================================================================
%##########################################################################
%#                                                                        #
%#  This function is part of StackSplit - a plugin for multi-event shear  #
%#  wave splitting analyses in SplitLab                                   #
%#                                                                        #
%##########################################################################
%==========================================================================
% FILE DESCRIPTION
%
% Generate diagnostic plot for SIMW analysis, this function is a modified
% version of the original SplitLab function < splitdiagnosticplot.m >
%
%==========================================================================
% LICENSE
%
% Copyright (C) 2016  Michael Grund, Karlsruhe Institute of Technology (KIT),
% GitHub: https://github.com/michaelgrund
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% TERMS OF USE
%
% StackSplit is provided "as is" and without any warranty. The author cannot be
% held responsible for anything that happens to you or your equipment. Use it
% at your own risk.
%==========================================================================

%==================================================================================================================================
%==================================================================================================================================

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

% Andreas Wüstefeld, 12.03.2006
global config % thiseq SIMW_temp % -> un-used global variables YF 2023-12-27

Synfig = findobj('name', 'SIMW Diagnostic Viewer','type','figure');

if isempty(Synfig)
    S = get(0,'Screensize');
    Synfig = figure('name', 'SIMW Diagnostic Viewer',...
        'Renderer',        'painters',...
        'Color',           'w',...
        'NumberTitle',     'off',...
        'MenuBar',         'none',...
        'PaperOrientation','landscape',...
        'PaperUnits',      'centimeter',...
        'position',        [.01*S(3) .1*S(4) .98*S(3) .75*S(4)]);
else
    figure(Synfig)
    clf
    set(Synfig,'PaperOrientation','landscape')
end
orient landscape
colormap(gray)

fontsize = get(gcf,'DefaultAxesFontsize')-1;
titlefontsize = fontsize+2;

[axH, axRC, axSC, axSeis,axwm] = SS_splitdiagnosticLayout(Synfig);
SS_splitdiagnosticSetHeader(axH, phiRC, dtRC, phiSC, dtSC, phiEV, dtEV, ...
    pol, splitoption, bazi_int, dist_int)

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

%% rotation-correlation method
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
title('corrected Fast (\color{blue}--\color{black}) & Slow (\color{red}-\color{black})', ...
    'FontSize',titlefontsize);
set(gca,'Ytick' , [-1 0 1])
ylabel('Rotation-Correlation','FontSize',titlefontsize)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% corrected seismograms
axes(axRC(2))
plot(t, QTcorRC(:,1),'b--',    t, QTcorRC(:,2) ,'r-','LineWidth',1);
title('corrected Q (\color{blue}--\color{black}) & T (\color{red}-\color{black})', ...
    'FontSize',titlefontsize);
xlim([t(1) t(end)])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% surface particle motion
axes(axRC(3))
plot(E, N, 'b--', Erc, Nrc,'r-','LineWidth',1);
xlabel('\leftarrowW - E\rightarrow', 'Fontsize',fontsize-1);
ylabel('\leftarrowS - N\rightarrow', 'Fontsize',fontsize-1);
title('Particle motion before (\color{blue}--\color{black}) & after (\color{red}-\color{black})', ...
    'FontSize',titlefontsize);
axis equal

tmp = max([abs(xlim) abs(ylim)]); % set [0 0] to centre of plot
set(gca, 'xlim', [-tmp tmp], 'ylim', [-tmp tmp], 'XtickLabel',[], 'YtickLabel',[])
set(gca, 'Ytick', get(gca,'Xtick'))
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

maxi = max(Cmatrix(:)); % always <=  1 since correlation coefficient (^5)
mini = min(Cmatrix(:)); % always >= -1
maxmin = abs(mini - maxi)/2; % always between 0 and 1

nb_contours = 12;floor((1 - maxmin)*9);
[~, h1] = contourf(ts,ps,-Cmatrix,-[LevelRC LevelRC]);
contour(ts, ps, Cmatrix, nb_contours);

B = mod(bazi,90);
plot([0 0]+sampling, [B B-90],'k>','markersize',5,'linewidth',1,'MarkerFaceColor','k' )
plot([maxtime maxtime]-sampling, [B B-90],'k<','markersize',5,'linewidth',1,'MarkerFaceColor','k' )
line([dtRC(2) dtRC(2)],[-90 90],'Color',[0 0 1])
line([0 maxtime], [phiRC(2) phiRC(2)],'Color',[0 0 1])
title('Map of Correlation Coefficient','FontSize',titlefontsize);
xlabel('delay time in s', 'Fontsize',fontsize-1)
ylabel('fast axis in N°E', 'Fontsize',fontsize-1)

%label = ['0' sprintf('|%u',1:maxtime) 'sec'];
set(gca, 'Xtick',0:1:maxtime, 'Ytick',-90:30:90, ...
    'XtickLabel',0:1:maxtime, 'xMinorTick','on', 'yminorTick','on')
axis([ts(1) ts(end) -90 90])
set(h1,'FaceColor',[1 1 1]*.90,'EdgeColor','k','linestyle','-','linewidth',1)

hold off

%% Silver & Chan method
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
title('corrected Fast (\color{blue}--\color{black}) & Slow (\color{red}-\color{black})', ...
    'FontSize',titlefontsize);
set(gca,'Ytick' , [-1 0 1])
ylabel(optionstr,'FontSize',titlefontsize)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% corrected seismograms (in ray system)
axes(axSC(2))
plot(t, QTcorSC(:,1),'b--',    t, QTcorSC(:,2) ,'r-','LineWidth',1);
title('corrected Q (\color{blue}--\color{black}) & T (\color{red}-\color{black})', ...
    'FontSize',titlefontsize);
xlim([t(1) t(end)])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% surface particle motion
axes(axSC(3))
hold on
plot(E, N, 'b--', Esc, Nsc,'r-','LineWidth',1);
xlabel('\leftarrowW - E\rightarrow', 'Fontsize',fontsize-1);
ylabel('\leftarrowS - N\rightarrow', 'Fontsize',fontsize-1);
title('Particle motion before (\color{blue}--\color{black}) & after (\color{red}-\color{black})', ...
    'FontSize',titlefontsize);
axis equal

tmp = max([abs(xlim) abs(ylim)]); % set [0 0] to centre of plot
set(gca, 'xlim', [-tmp tmp], 'ylim', [-tmp tmp], 'XtickLabel',[], 'YtickLabel',[])
set(gca, 'Ytick', get(gca,'Xtick'))
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
[~, h1] = contourf(ts,ps,-Ematrix,-[Level Level]);
contour(ts, ps, Ematrix, nb_contours);

B = mod(bazi,90); % backazimuth lines
plot([0 0]+sampling, [B B-90],'k>','markersize',5,'linewidth',1,'MarkerFaceColor','k' )
plot([maxtime maxtime]-sampling, [B B-90],'k<','markersize',5,'linewidth',1,'MarkerFaceColor','k' )
line([0 maxtime], [phi phi],'Color',[0 0 1])
line([dt dt],[-90 90],'Color',[0 0 1])

hold off
axis([0 maxtime -90 90])
set(gca, 'Xtick',0:1:maxtime, 'Ytick',-90:30:90, ...
    'XtickLabel', 0:1:maxtime, 'xMinorTick','on', 'yminorTick','on')
xlabel('delay time in s', 'Fontsize',fontsize-1)
ylabel('fast axis in N°E', 'Fontsize',fontsize-1)
title(Maptitle,'FontSize',titlefontsize);
set(h1,'FaceColor',[1 1 1]*.90,'EdgeColor','k','linestyle','-','linewidth',1)

%% plot initial seismograms

% Q

axes(axSeis(1))
t2 = (0:length(Q)-1)*sampling - extime;
xx  = [0 0 s s]*sampling;
yy  = [0 0 1 1 ];
tmp = fill(xx, yy, [1 1 1]*.90, 'EdgeColor','None'); % selection marker

hold on
plot(t2, Q, 'b--','LineWidth',1)
plot(t2, T, 'r-','LineWidth',1)
hold off

xlim([t2(1) t2(end)])
yy = [ylim fliplr(ylim)];
set(tmp,'yData',yy)
set(axSeis,'Layer','Top')

%% plot world map with selected events used for SIMW

axes(axwm)

% get objects from world map plot
H2=findall(h.EQstatsax);

if config.maptool==1

    copyobj(H2(2:end),axwm);

	axis equal
	axis off

    findtext=findobj(gca,'type','text');
    set(findtext,'fontsize',6)

    findtext=findobj(gca,'type','line');
    set(findtext,'markersize',6)

else

    copyobj(H2([2 5:end]),axwm);

    axis off

end
%% EOF %%