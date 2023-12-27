function SS_calc_SIMW(h)
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
% Calculate splitting parameters (and errors) for concatenated SIMW waveforms
% using the rotation-correlation (RC) and Silver & Chan (SC) methods, for
% details see the SplitLab functions splitRotCorr.m & splitSilverChan.m
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

global config SIMW_temp

%############################################################################################
% check if more than one phase per event is selected by comparing different
% event basic information

if h.checkmultiSIMW==1 % for h.checkmultiSIMW, see function SS_prep_SIMW.m

    % disp dialog if SIMW procedure should be continued or aborted
    ask4multi=questdlg(['Your selection contains different phases/filters ' ...
        'of the same event! Do you want to continue?'], ...
        'Multiple result selection','No','Yes','No');

    if strcmp(ask4multi,'No') % set all buttons to visible off since SIMW is aborted

        set(h.push(5),'enable','off'); % INVERSION button
        set(h.panel(6),'visible','off'); % Waveforms panel

        % remove blue dots on world map when no option is selected
        find_bluedot=findobj(h.EQstatsax,'type','line');

         if length(find_bluedot) > 4
             set(find_bluedot(1:end-4),'Visible','off')
             delete(find_bluedot(1))
         end

        return

    else % although more than one result per event, SIMW continues
        set(h.panel(6),'visible','on');
    end

else % if not more than one result per event, DEFAULT case
    set(h.panel(6),'visible','on');
end
%############################################################################################
% check if non-nulls and nulls are mixed

if h.checkmultiSIMW2==1 % for h.checkmultiSIMW2, see function SS_prep_SIMW.m

    % disp dialog if SIMW procedure should be continued or aborted
    ask4multi2=questdlg(['Your selection contains splits and nulls! ' ...
        'Mixing both types is not reasonable! Do you want to continue?'], ...
        'Splits and nulls selection','No','Yes','No');

    if strcmp(ask4multi2,'No') % set all buttons to visible off since SIMW is aborted

        set(h.push(5),'enable','off'); % INVERSION button
        set(h.panel(6),'visible','off'); % Waveforms panel

        % remove blue dots on world map when no option is selected
        find_bluedot=findobj(h.EQstatsax,'type','line');

         if length(find_bluedot) > 4
             set(find_bluedot(1:end-4),'Visible','off')
             delete(find_bluedot(1))
         end

        return

    else % although more than one result per event, SIMW continues
        set(h.panel(6),'visible','on');
    end

else % if not more than one result per event, DEFAULT case
    set(h.panel(6),'visible','on');
end
%############################################################################################
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate splitting parameters using SIMW from currently visible merged
% waveforms

% inversion settings, same like for the single event analysis
option=config.splitoption;
inipoloption=config.inipoloption;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% waveform settings
pickwin=h.pickwin;

Q=h.merged_Q;
T=h.merged_T;
L=h.merged_L;

N=h.merged_N;
E=h.merged_E;

bazi=h.merged_BAZ;
dist=h.merged_dist;
inipol=h.merged_inipol;

inc=h.merged_inc;
inc=mean(inc);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Emap settings
sampling=h.EMAP_sampling;
maxtime=h.EMAP_maxtime;

%############################################################################################
% maximum diff of used bazis and dists
max_bazi=max(bazi);
min_bazi=min(bazi);
max_dist=max(dist);
min_dist=min(dist);
max_inipol=max(inipol);
min_inipol=min(inipol);

bazi_int=[min_bazi max_bazi];
dist_int=[min_dist max_dist];

diffbazi=abs(max_bazi-min_bazi);
diffdist=abs(max_dist-min_dist);
diffinipol=abs(max_inipol-min_inipol);

if ~ischar(config.SS_maxbaz)
    if diffbazi > config.SS_maxbaz && ~strcmp(config.SS_maxbaz,'none')
        h.warn_diffbazi=warndlg({['BAZ difference (' num2str(diffbazi,'%2.1f') '°) exceeds'],...
            ;['    selected maximum (' num2str(config.SS_maxbaz) '°)!']},'BAZ difference');
        return
    end
end

if ~ischar(config.SS_maxdist)
    if diffdist > config.SS_maxdist && ~strcmp(config.SS_maxdist,'none')
        h.warn_diffdist=warndlg({['Dist difference (' num2str(diffdist,'%2.1f') '°) exceeds'],...
            ;['     selected maximum (' num2str(config.SS_maxdist) '°)!']},'Dist difference');
        return
    end
end

if ~ischar(config.SS_maxpol)
    if diffinipol > config.SS_maxpol && ~strcmp(config.SS_maxpol,'none')
        h.warn_diffinipol=warndlg({['Inipol difference (' num2str(diffinipol,'%2.1f') '°) exceeds'],...
            ;['     selected maximum (' num2str(config.SS_maxpol) '°)!']},'Inipol difference');
        return
    end
end

% for SIMW the BAZ for the inversion is calculated here as simple mean out
% of all single event bazis
bazi_mean=mean(bazi);

%############################################################################################
% make inversion using SL routines

disp(' ')
disp('=== make INVERSION using SIMW ===')

tic

[phiSC, dtSC, phiEV, dtEV, inipol, Emap, correctFastSlow, corrected_QT, Eresult] =...
    splitSilverChan(Q, T,  bazi_mean, pickwin, sampling, maxtime, option, inipoloption);

[phiRC, dtRC, Cmap, correctFastSlowRC,corrected_QTRC,  Cresult] =...
    splitRotCorr(Q, T, bazi_mean, pickwin,maxtime, sampling);

compend=toc;

disp(' ')
disp(['=== INVERSION done (' num2str(compend) ' s) ==='])

w=pickwin;
extime=pickwin(1)*sampling;

[errbar_phiRC, errbar_tRC, LevelRC, ~] = geterrorbarsRC(T(w), Cmap, Cresult);
[errbar_phiSC, errbar_tSC, LevelSC, ~] = geterrorbars(T(w), Emap(:,:,1), Eresult(1));
[errbar_phiEV, errbar_tEV, LevelEV, ~] = geterrorbars(T(w), Emap(:,:,2), Eresult(2));

phiRC   = [errbar_phiRC(1)  phiRC   errbar_phiRC(2)];
dtRC    = [errbar_tRC(1)    dtRC    errbar_tRC(2)];
phiSC   = [errbar_phiSC(1)  phiSC   errbar_phiSC(2)];
dtSC    = [errbar_tSC(1)    dtSC    errbar_tSC(2)];
phiEV   = [errbar_phiEV(1)  phiEV   errbar_phiEV(2)];
dtEV    = [errbar_tEV(1)    dtEV    errbar_tEV(2)];

%############################################################################################
% save results to global
SIMW_temp=[];

SIMW_temp.phiRC=phiRC;
SIMW_temp.dtRC=dtRC;
SIMW_temp.phiSC=phiSC;
SIMW_temp.dtSC=dtSC;
SIMW_temp.phiEV=phiEV;
SIMW_temp.dtEV=dtEV;
SIMW_temp.bazi=bazi;
SIMW_temp.bazint=bazi_int;
SIMW_temp.dist=dist;
SIMW_temp.distint=dist_int;
SIMW_temp.bazi_mean=bazi_mean;
SIMW_temp.dist_mean=mean(dist);
SIMW_temp.noc=length(h.merged_BAZ); % number of concatenated wavelets

gettaper=cellstr(get(h.pop(1),'string')); % which taper
checkpop=get(h.pop(1),'value');
taper=str2double(cell2mat(gettaper(checkpop)));

if isnan(taper)
   taper='none';
end

SIMW_temp.taper=taper;

index=get(h.list,'value');
SIMW_temp.events=h.data(index);

SS_splitdiagnosticplot(Q, T, extime, L(w), E(w), N(w), inc, bazi_mean, sampling, maxtime, inipol,...
        phiRC, dtRC, Cmap,    correctFastSlowRC, corrected_QTRC,...
        phiSC, dtSC, Emap, correctFastSlow, corrected_QT,...
        phiEV, dtEV, LevelSC, LevelRC, LevelEV, option, bazi_int, dist_int, h);


% EOF