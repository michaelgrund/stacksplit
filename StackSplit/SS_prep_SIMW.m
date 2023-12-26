function h = SS_prep_SIMW(h)
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
% prepare waveforms of selected events for application of SIMW
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

global config

% initial settings

lwwaveform=1;

set(h.push(1),'visible','off');
set(h.push(2),'visible','off');
set(h.push(3),'visible','off');
set(h.push(5),'visible','on');

set(h.push(1),'enable','off');
set(h.push(2),'enable','off');
set(h.push(3),'enable','off');
set(h.push(5),'enable','off');

set(h.panel(2),'visible','off');
set(h.panel(3),'visible','off');
set(h.panel(6),'visible','on');

config.SS_use_SIMW=0;

%=============================================================================
% get input data from handle

find_res=h.data;

%=============================================================================
% get index/indices of selected event(s) from list

index=get(h.list,'value');

%=============================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length(index)==1 % one single event

    tapdesign=tukeywin(length(find_res(index).results.Qcut),h.usetap);

    delta=h.EMAP_sampling;
    timevec=0:delta:delta*length(find_res(index).results.Qcut)-delta;

    % Q comp
    axes(h.axWF)
    cla reset
    plot(timevec,find_res(index).results.Qcut.*tapdesign,'b','linewidth',lwwaveform)
    set(gca,'xticklabel',[],'xMinorTick','on','yminorTick','on')
    xlim([0 timevec(end)])
    ylabel('amp')

    text(0.027,0.95,'\bfQ\rm' , ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'top','fontsize',15,'backgroundcolor','w');

    % T comp
    axes(h.axWF2)
    cla reset
    plot(timevec,find_res(index).results.Tcut.*tapdesign,'r','linewidth',lwwaveform)
    set(gca,'xMinorTick','on','yminorTick','on')
    xlim([0 timevec(end)])
    xlabel('time in s')
    ylabel('amp')

    text(0.027,0.95,'\bfT\rm' , ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'top','fontsize',15,'backgroundcolor','w');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif length(index) > 1  % more than one selected => show merged waveforms

    %############################################################################################
    % check if more than one phase per event is selected by comparing the
    % source times of the selected entries
    datevecs=vertcat(find_res(index).date);
    % YF 2023-01-16
    % checkmultiSIMW=unique(datenum(datevecs(:,1:6)));
    checkmultiSIMW = unique(datevecs(:,1:6),'rows'); % each row as one entry

    % save check result to handle, questdlg only is opened when INVERSION
    % button is clicked, see beginning of function SS_calc_SIMW.m
    % if length(checkmultiSIMW)~=length(index)
    if size(checkmultiSIMW,1)~=length(index) % number of columns, i.e. different events
        h.checkmultiSIMW=1;
    else
        h.checkmultiSIMW=0;
    end

    %############################################################################################
    % check if non-nulls and nulls are mixed in selection

    for ii=index
        restype{ii}=find_res(ii).results.Null;
    end

    restype=restype(~cellfun(@isempty, restype));
    checkmulti2=(unique(restype));

    if length(checkmulti2)~=1
        h.checkmultiSIMW2=1;
    else
        h.checkmultiSIMW2=0;
    end

    %############################################################################################

    % enable INVERSION button
    set(h.push(5),'enable','on');

    % only applied for plotting, for inversion zeros are not considered, see below
    zerosbe=h.EMAP_maxtime/h.EMAP_sampling; % = 4 s before and at end, necessary to calculate the test delay times

    % zeros at beginning
    merged_Q=zeros(zerosbe,1);
    merged_T=zeros(zerosbe,1);
    merged_L=zeros(zerosbe,1);
    merged_N=zeros(zerosbe,1);
    merged_E=zeros(zerosbe,1);

    merged_BAZ=[];
    merged_dist=[];
    merged_inc=[];
    merged_inipol=[];

    for ii=index

        tapdesign=tukeywin(length(find_res(ii).results.Qcut),h.usetap);
        Q2norm=max(abs(find_res(ii).results.Qcut));

        merged_Q=vertcat(merged_Q,(find_res(ii).results.Qcut./Q2norm).*tapdesign);
        merged_T=vertcat(merged_T,(find_res(ii).results.Tcut./Q2norm).*tapdesign);
        merged_L=vertcat(merged_L,(find_res(ii).results.Lcut./Q2norm).*tapdesign);

        merged_N=vertcat(merged_N,(find_res(ii).results.Ncut./Q2norm).*tapdesign);
        merged_E=vertcat(merged_E,(find_res(ii).results.Ecut./Q2norm).*tapdesign);

        merged_BAZ(end+1)=find_res(ii).bazi;
        merged_dist(end+1)=find_res(ii).dis;
        merged_inc(end+1)=find_res(ii).results.incline;
        merged_inipol(end+1)=find_res(ii).results.inipol;

    end

    % zeros at end
    merged_Q=vertcat(merged_Q,zeros(zerosbe,1));
    merged_T=vertcat(merged_T,zeros(zerosbe,1));
    merged_L=vertcat(merged_L,zeros(zerosbe,1));
    merged_N=vertcat(merged_N,zeros(zerosbe,1));
    merged_E=vertcat(merged_E,zeros(zerosbe,1));

    delta=h.EMAP_sampling;
    timevec=0:delta:delta*length(merged_Q)-delta;

    % Q comp
    axes(h.axWF)
    cla reset
    plot(timevec,merged_Q,'b','linewidth',lwwaveform)
    set(gca,'xticklabel',[],'xMinorTick','on','yminorTick','on')
    xlim([0 timevec(end)])
    ylim([-1 1])
    ylabel('norm amp')

    text(0.027,0.95,'\bfQ\rm' , ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'top','fontsize',15,'backgroundcolor','w');

    % T comp
    axes(h.axWF2)
    cla reset
    plot(timevec,merged_T,'r','linewidth',lwwaveform)
    set(gca,'xMinorTick','on','yminorTick','on')
    xlim([0 timevec(end)])
    ylim([-1 1])
    xlabel('time in s')
    ylabel('norm amp')

    text(0.027,0.95,'\bfT\rm' , ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'left', ...
        'VerticalAlignment', 'top','fontsize',15,'backgroundcolor','w');

    set(h.push(1),'enable','on');

    % write current merged waveforms to handle
    h.merged_Q=merged_Q;
    h.merged_T=merged_T;
    h.merged_L=merged_L;
    h.merged_N=merged_N;
    h.merged_E=merged_E;

    h.merged_BAZ=merged_BAZ;
    h.merged_dist=merged_dist;
    h.merged_inc=merged_inc;
    h.merged_inipol=merged_inipol;

    % only use merged "real" time series for inversion,
    % zeros at begin & end are not considered
    h.pickwin=zerosbe:length(merged_Q)-zerosbe;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot current event location(s) for one or multiple selected
% events on world map

axes(h.EQstatsax)

evlat=[h.data(index).lat];
evlon=[h.data(index).long];

find_bluedot=findobj(h.EQstatsax,'type','line');


if config.maptool==1 % if Mapping Toolbox available

    if length(find_bluedot) > 4
        set(find_bluedot(1),'Visible','off')
        delete(find_bluedot(1))
    end

    plotm(evlat, evlon,'ko','MarkerFaceColor','b','MarkerSize',8, 'ButtonDownFcn', '', 'HitTest', 'off');


else % if no Mapping Toolbox available

    if length(find_bluedot) > 3
        set(find_bluedot(1),'Visible','off')
        delete(find_bluedot(1))
    end

    plot(evlon,evlat,'ko','MarkerFaceColor','c','MarkerSize',8);

end

% EOF