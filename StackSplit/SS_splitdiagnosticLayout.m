function [axH, axRC, axSC,axSeis, axwm] = SS_splitdiagnosticLayout(Synfig)
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
% generate diagnostic plot for SIMW analysis, this function is a modified
% version of the original SL function < splitdiagnosticLayout.m >
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

m1 = uimenu(Synfig,'Label',   'Quality');
q(1) = uimenu(m1,'Label',  'good ', 'Callback',@q_callback);
q(2) = uimenu(m1,'Label',  'fair ', 'Callback',@q_callback);
q(3) = uimenu(m1,'Label',  'poor ', 'Callback',@q_callback);
set(q,'Userdata',q)

m2 = uimenu(Synfig,'Label',   'IsNull');
n(1) = uimenu(m2,'Label',  'Yes',  'Callback',@n_callback);
n(2) = uimenu(m2,'Label',  'No ',  'Callback',@n_callback);
set(n,'Userdata',n)

m3 = uimenu(Synfig,'Label',   'Result');
n(1) = uimenu(m3,'Label',  'Save',      'Accelerator','s', 'Callback','SS_saveresults;');
n(2) = uimenu(m3,'Label',  'Discard',   'Accelerator','d', 'Callback','close(gcbf)');
n(3) = uimenu(m3,'Label',  'Add remark','Accelerator','r', 'Callback',@r_callback);
set(n(1:2),'Userdata',n(1:2))

m4 = uimenu(Synfig,'Label',   'Figure');
uimenu(m4,'Label',  'Save current figure',  'Callback',@localSavePicture);
uimenu(m4,'Label',  'Page setup',           'Callback','pagesetupdlg(gcbf)');
uimenu(m4,'Label',  'Print preview',        'Callback','printpreview(gcbf)');
uimenu(m4,'Label',  'Print current figure', 'Callback','printdlg(gcbf)');

%% create axes

% borders
fontsize = get(gcf,'DefaultAxesFontsize')-2;

%clf
%axSeis = axes('units','normalized', 'position',[.08 .78 .43 .2], 'Box','on', 'Fontsize',fontsize); % without world map
axSeis = axes('units','normalized', 'position',[.08 .78 .26 .2], 'Box','on', 'Fontsize',fontsize);

axRC(1) = axes('units','normalized', 'position',[.08 .42 .19  .28], 'Box','on', 'Fontsize',fontsize);
axRC(2) = axes('units','normalized', 'position',[.32 .42 .19  .28], 'Box','on', 'Fontsize',fontsize);
axRC(3) = axes('units','normalized', 'position',[.54 .43 .19  .27], 'Box','on', 'Fontsize',fontsize);
axRC(4) = axes('units','normalized', 'position',[.77 .42 .19  .28], 'Box','on', 'Fontsize',fontsize, 'Layer','top');

axSC(1) = axes('units','normalized', 'position',[.08 .05 .19  .28], 'Box','on', 'Fontsize',fontsize);
axSC(2) = axes('units','normalized', 'position',[.32 .05 .19  .28], 'Box','on', 'Fontsize',fontsize);
axSC(3) = axes('units','normalized', 'position',[.54 .06 .19  .27], 'Box','on', 'Fontsize',fontsize);
axSC(4) = axes('units','normalized', 'position',[.77 .05 .19  .28], 'Box','on', 'Fontsize',fontsize, 'Layer','top');

% world map
if config.maptool==1
    axwm = axes('units','normalized', 'position',[.77 .755 .23 .249]);
else
    axwm = axes('units','normalized', 'position',[.81 .78 .18 .20]);
end

% header axes:
axH    = axes('units','normalized',  'Position',[.27 .8 .46 .14]);
axis off

%% SUBFUNTION menu

%% ---------------------------------
function q_callback(src,~)
% quality menu callback
global SIMW_temp
% 1) set menu markers
tmp1 = get(src,'Userdata');
set(tmp1(tmp1~=src),'Checked','off');
set(src,'Checked','on'),
SIMW_temp.Q=get(src,'Label');

% 2) set figure header entries
tmp1 = findobj('Tag','FigureHeader');
tmp2 = get(tmp1,'String');
tmp3 = tmp2{end};

tmp3(29:33)=SIMW_temp.Q;
tmp2(end) = {tmp3};
set(tmp1,'String',tmp2);

%% ---------------------------------
function n_callback(src,~)
% null menu callback
global SIMW_temp
% 1) set menu markers
tmp1 = get(src,'Userdata');
set(tmp1(tmp1~=gcbo),'Checked','off');
set(gcbo,'Checked','on')
SIMW_temp.AnisoNull=get(gcbo,'Label');

% 2) set figure header entries
tmp1 = findobj('Tag','FigureHeader');
tmp2 = get(tmp1,'String');
tmp3 = tmp2{end};
tmp3(57:59) = SIMW_temp.AnisoNull;
tmp2(end) = {tmp3};
set(tmp1,'String',tmp2);

function r_callback(~,~)
%null menu callback
global SIMW_temp

if exist('res_remark','var')
   clear res_remark
end

res_remark=inputdlg('Enter a remark to this result', 'Remark');

% if exist h.stacked_remark delete it !!!!!!!!!
if ~isempty(res_remark) && ~strcmp(res_remark,'')
    remark=res_remark;
elseif isempty(res_remark)
    remark=[];
elseif strcmp(res_remark,'')
    error('No remark was inserted!')
end

SIMW_temp.remark=remark;

%% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
function localSavePicture(hFig,evt)
global config thiseq SIMW_temp
defaultname = 'Multi_result_SIMW';
defaultextension = '.pdf';
exportfiguredlg(gcbf, [defaultname defaultextension])