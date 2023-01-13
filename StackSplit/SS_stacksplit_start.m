function SS_stacksplit_start
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
% main function of StackSplit
%
% StackSplit is a plugin for the MATLAB toolbox SplitLab (Wüstefeld et al.,
% 2008) which allows to apply multi-event techniques for shear wave splitting 
% measurements directly from within the main program. 
%
%
% !!! NOTE: StackSplit cannot operate without an installed SplitLab version !!!
%
% !!! Before using StackSplit, take a look into the UserGuide !!!
%
%
% For MATLAB version 2014b and higher I recommend to use the updated SplitLab 
% version by Rob Porritt (available via https://robporritt.wordpress.com/software/)
% 
% The use of StackSplit requires small modifications in some of the original Split-
% Lab functions which partly were taken from Rob Porritts updated version 1.2.1.
% This modified functions come with this package and must replace the original ones.
% An overview about this changes is given in SL2SS_changelog.txt in StackSplit/doc.
%
% StackSplit allows to apply up to now 4 stacking schemes for already existing 
% single SWS splitting measurments (see also REFERENCES section below):

% 1) SIMW: simultaneous inversion of multiple waveforms in timedomain (Roy et al., 2017)
% 2) WS  : stacking of error surfaces, normalized on minimum of each single surface 
%          (Wolfe & Silver, 1998)
% 3) RH  : modified WS method with weight depending on SNR of each measurement 
%          (Restivo & Helffrich, 1999)
% 4) def : stacking of error surfaces without weighting following e.g. PhD thesis of 
%          Wüstefeld (2007)
% 
%==========================================================================
% REFERENCES
%
% If you make use of StackSplit for shear wave splitting measurements, 
% please refer to the following contributing articles: 
%
%.................................................
% SOFTWARE OVERALL
%.................................................
%
% Grund (2017), StackSplit - a plugin for multi-event shear wave splitting
%     analyses in SplitLab, Computers & Geosciences, 105, 43-50,
%     https://doi.org/10.1016/j.cageo.2017.04.015.
%
% Wüstefeld et al. (2008), SplitLab: A shear-wave splitting environment in Matlab, 
%     Computers & Geosciences 34, 515–528
%
%.................................................
% USED METHODS (depending on your application)
%.................................................
%
% Roy et al. (2017), On the improvement of SKS splitting measurements by the
%    simultaneous inversion of multiple waveforms (SIMW), GJI, doi:10.1093/gji/ggw470
%
% Restivo & Helffrich (1999), Teleseismic shear wave splitting 
%    measurements in noisy environments, GJI 137, 821-830
%
% Wolfe & Silver (1998), Seismic anisotropy of oceanic upper mantle: Shear wave 
%    splitting methodologies and observations, JGR 103(B1), 749-771
%
% Silver & Chan (1991), Shear wave splitting and subcontinental mantle deformation,
%    JGR 96, 16429–16454
%
% Bowman & Ando (1987), Shear-wave splitting in the upper-mantle wedge above the Tonga 
%    subduction zone. Geophys. J. Roy. Astron. Soc. 88, 2541
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

% START of main function
%##############################################################################################################
%##############################################################################################################

global config eqstack

% StackSplit version
%VVVVVVVVVVVVVVVVVVVVVVV
config.SS_version='3.1';

% 1.0 released 2017-04-04
% 2.0 released 2019-06-28
% 3.0 released 2021-12-23
% 3.1 upcoming 2023-01-DD
%VVVVVVVVVVVVVVVVVVVVVVV

clc

%=============================================================
% CHECK for mapping toolbox

if license('test', 'MAP_Toolbox')
  config.maptool=1;
else
   config.maptool=0;
end

%=============================================================
% CHECK if a project was already loaded in SplitLab,
% otherwise StackSplit will not start

if ~exist('config','var')
    errordlg('Please first start SplitLab to load a project!','SL is not running')
    return
end

%=============================================================
% READ SL results of single measurements for current project

%.........................................
[merged_str,find_res]=SS_read_SLresults(config.savedir,config.stnname);
%.........................................

if isempty(merged_str) && isempty(find_res)
   return
end  

disp(' ')
disp('#################################')
disp('#     Welcome to StackSplit     #')
disp('#################################')
disp(['version ' config.SS_version])
disp(' ')

%=============================================================
% READ/GENERATE global variable for saving stacking results in mat-file

fname = [config.stnname '_stackresults.mat'];
find_file=dir(fullfile(config.savedir,fname));

if ~isempty(find_file)
    eqstack=load(fullfile(config.savedir,fname));
else
    eqstack=[];
end

evalin('base','global eqstack');

%=============================================================
% CHECK INPUT

%.........................................
[f,sampling,find_res]=SS_check_input(find_res);
%.........................................

if isempty(f) || isempty(sampling)
   return
end

%=============================================================
% GENERATE GUI layout and corresponding handles

%.........................................
h=SS_layout(@call_pushSTACK,@call_pushCLEAR,@call_pushSAVE,@call_pushEXIT,@call_listbox,...
    @call_checkNW,@call_checkWS,@call_checkRH,@call_checkSIMW,@call_popTAP,@call_pushINV,...
    @call_popMAXBAZ,@call_popMAXDIST,@call_popSURF,@call_popMAXPOL);
%.........................................

%=============================================================
% SET basic settings

% Emap settings
h.EMAP_sampling=sampling;
h.EMAP_maxtime=config.maxSplitTime; 
h.EMAP_f=f;

%.........................................
h=SS_basic_settings(h,merged_str,find_res);
%.........................................

% generate worldmap
%.........................................
h=SS_gen_worldmap(h);

if isfield(h,'quit')
    return
end
%.........................................

% generate legends for meas qualities
%.........................................
h=SS_gen_legends(h);
%.........................................

guidata(h.fig,h)

% check screen size
% -introduced in v3.0-
%.........................................
% workaround for Windows 10 OS: by default under
%
%    'Settings' => 'System' => 'Display' => 'Scale and Layout' 
%     => 'Change the size of text, apps, and other items' 
%
% the selection sometimes is set to a value different from 100% (e.g. 150%) 
% which effectively reduces your screen size in pixels: Set it to 125% or 
% better 100% and check again, mostly then the panel fits on the screen.

screenSize = get(0,'ScreenSize');
resstr = ['Your current screen resolution is lower than the pre-defined StackSplit panel width. ',...
    'Some parts may not be displayed correctly! Please adjust! For details see the v3.0 changelog.'];

if screenSize(3) < h.fig.Position(3)
    warndlg(resstr, 'Resolution issue')
    warning(resstr)
end
   
%.........................................    
    
end
% END of main function
%##############################################################################################################
%##############################################################################################################
  
%==============================================================================================================

% CALLBACK FUNCTIONS
%##############################################################################################################
%############################################################################################################## 
% call LISTBOX

function call_listbox(hObject, ~, ~)

h=guidata(hObject);

check1=get(h.h_checkbox,'Value');

%==================================================================================================================================
% SIMW selected
if check1{4}==1
  
    %.........................................
    h=SS_prep_SIMW(h);
    %.........................................
    
    set(h.panel(6),'visible','on');
    set(h.panel(2),'visible','off');     
    set(h.panel(3),'visible','off');
    
%==================================================================================================================================    
% ERR SURF stack selected    
else

    axes(h.axEmap);
    
    set(h.push(1),'enable','off');
    set(h.push(2),'enable','off');
    set(h.push(3),'enable','off');

    index=get(h.list,'value');

    set(h.panel(2),'visible','on');     
    set(h.panel(3),'visible','on');
    set(h.panel(6),'visible','off');

    set(h.push(5),'visible','off');

    %.........................................
    h=SS_disp_Esurf_single(h,index);
    %.........................................

end

guidata(hObject,h);

end

%==================================================================================================================================
%================================================================================================================================== 
% call STACK button (no weight, WS, RH), stack error surfaces and disp stacked Emap

function call_pushSTACK(hObject,~,~)

h=guidata(hObject);

    %.........................................
    h=SS_stack_Esurf(h);
    %.........................................

guidata(hObject, h);

end

%==================================================================================================================================
%================================================================================================================================== 
% call CLEAR button

function call_pushCLEAR(hObject,~,~)

global config

h=guidata(hObject);

cla reset
set(gca,'xticklabel',[])
set(gca,'yticklabel',[])
set(gca,'xtick',[])
set(gca,'ytick',[])
set(gca,'visible','off')

set(h.push(1),'enable','off');
set(h.push(2),'enable','off');
set(h.push(3),'enable','off');

set(h.panel(2),'visible','off'); 
set(h.panel(3),'visible','off'); 

set(h.list,'value',0);
set(h.list,'string',h.list_origin);
set(h.list,'value',1);
     

% remove blue dots on worldmap when no option is selected       
find_bluedot=findobj(h.EQstatsax,'type','line');
 
if config.maptool==1 
    if length(find_bluedot) > 4    
        set(find_bluedot(1:end-4),'Visible','off')
        delete(find_bluedot(1)) 
    end    
else
    if length(find_bluedot) > 3  
        set(find_bluedot(1:end-3),'Visible','off') 
        delete(find_bluedot(1))
    end
end

guidata(hObject, h);

end

%==================================================================================================================================
%================================================================================================================================== 
% call SAVE button

function call_pushSAVE(hObject,~,~)

h=guidata(hObject);

res_remark=inputdlg('Enter a remark to this result', 'Remark');

if ~isempty(res_remark) && ~strcmp(res_remark,'')
    remark=res_remark;
elseif isempty(res_remark)
    remark=[];
elseif strcmp(res_remark,'')
    error('No remark was inserted!')
end

h.stacked_remark=remark;

% save stuff to struct or txtfile?
%.........................................
h=SS_saveresults(h);
%.........................................

guidata(hObject, h);

end

%==================================================================================================================================
%================================================================================================================================== 
% call INVERSION button (SIMW)

function call_pushINV(hObject,~,~)

global config

h=guidata(hObject);

config.SS_use_SIMW=1;

SS_calc_SIMW(h);

config.SS_use_SIMW=0;

end

%==================================================================================================================================
%================================================================================================================================== 
% call Exit button

function call_pushEXIT(hObject,~,~)

h=guidata(hObject);

exit=get(h.push(4),'Value');

if exit==1
    
    choice = questdlg('Really want to exit?',...
        'Exit menu','Yes','No','Yes');

    switch choice
    case 'Yes'  
        
        h.fig
        close(h.fig)
        
        basews=evalin('base','who');
        existeqstack=ismember('eqstack',[basews(:)]);
        
        if ~isempty(existeqstack)
            evalin('base','clearvars -global eqstack');
        end

    case 'No'
        return
    end

end


end

%==================================================================================================================================
%================================================================================================================================== 
% call NO WEIGHT radio button

function call_checkNW(hObject,~,~)

global config

h=guidata(hObject);

set(h.panel(2),'visible','off'); 
set(h.panel(3),'visible','off'); 
set(h.panel(6),'visible','off'); 

set(h.push(1),'visible','on'); 
set(h.push(2),'visible','on'); 
set(h.push(3),'visible','on'); 

check1=get(h.h_checkbox,'Value');

if check1{1}==1

    set(h.h_checkbox(1),'Value',1)
    set(h.h_checkbox(2),'enable','off');
    set(h.h_checkbox(3),'enable','off');
    set(h.h_checkbox(4),'enable','off');
    
    set(h.taptext,'enable','off');
    
    set(h.list,'enable','on');
    
    set(h.pop(1),'enable','off')
    
    set(h.pop(4),'enable','off') % surf input 
    set(h.inputtext,'enable','off')
    
    config.SS_meth='nw';

elseif check1{1}==0
    
    set(h.h_checkbox(1),'Value',0)
    set(h.h_checkbox(2),'enable','on');
    set(h.h_checkbox(3),'enable','on');
    set(h.h_checkbox(4),'enable','on');
    
    set(h.push(1),'enable','off');
    set(h.push(2),'enable','off');
    set(h.push(3),'enable','off');
    set(h.push(1),'visible','off');
    set(h.push(2),'visible','off');
    set(h.push(3),'visible','off');
    
    set(h.taptext,'enable','off');
    
    set(h.list,'enable','off');
    
    set(h.pop(1),'enable','off')
    
    set(h.pop(4),'enable','on') % surf input 
    set(h.inputtext,'enable','on')
    set(h.list,'value',[])

    
    
end

% remove blue dots on worldmap when no option is selected
if sum([check1{:}])==0
    
        find_bluedot=findobj(h.EQstatsax,'type','line');
        
        if config.maptool==1 
            if length(find_bluedot) > 4    
                set(find_bluedot(1:end-4),'Visible','off')
                delete(find_bluedot(1)) 
            end    
        else
            if length(find_bluedot) > 3  
                set(find_bluedot(1:end-3),'Visible','off') 
                delete(find_bluedot(1))
            end
        end
end


end

%==================================================================================================================================
%================================================================================================================================== 
% call WS radio button

function call_checkWS(hObject,~,~)

global config

h=guidata(hObject);

set(h.panel(2),'visible','off'); 
set(h.panel(3),'visible','off'); 
set(h.panel(6),'visible','off');

set(h.push(1),'visible','on'); 
set(h.push(2),'visible','on'); 
set(h.push(3),'visible','on');

check1=get(h.h_checkbox,'Value');

if check1{2}==1

    set(h.h_checkbox(2),'Value',1)
    set(h.h_checkbox(1),'enable','off');
    set(h.h_checkbox(3),'enable','off');
    set(h.h_checkbox(4),'enable','off');
    
    set(h.taptext,'enable','off');
    
    set(h.list,'enable','on');
    
    set(h.pop(1),'enable','off')
   
    set(h.pop(4),'enable','off')  % surf input 
    set(h.inputtext,'enable','off')

    config.SS_meth='WS';
    
elseif check1{2}==0
    
    set(h.h_checkbox(2),'Value',0)
    set(h.h_checkbox(1),'enable','on');
    set(h.h_checkbox(3),'enable','on');
    set(h.h_checkbox(4),'enable','on');
    
    set(h.push(1),'enable','off');
    set(h.push(2),'enable','off');
    set(h.push(3),'enable','off');
    set(h.push(1),'visible','off');
    set(h.push(2),'visible','off');
    set(h.push(3),'visible','off');

    set(h.taptext,'enable','off');
    
    set(h.list,'enable','off');
    
    set(h.pop(1),'enable','off')
    
    set(h.pop(4),'enable','on') % surf input 
    set(h.inputtext,'enable','on')
    set(h.list,'value',[])

end


% remove blue dots on worldmap when no option is selected
if sum([check1{:}])==0
    
        find_bluedot=findobj(h.EQstatsax,'type','line');
        
        if config.maptool==1 
            if length(find_bluedot) > 4    
                set(find_bluedot(1:end-4),'Visible','off')
                delete(find_bluedot(1)) 
            end    
        else
            if length(find_bluedot) > 3  
                set(find_bluedot(1:end-3),'Visible','off') 
                delete(find_bluedot(1))
            end
        end
end


end

%==================================================================================================================================
%================================================================================================================================== 
% call RH radio button

function call_checkRH(hObject,~,~)

global config

h=guidata(hObject);

set(h.panel(2),'visible','off'); 
set(h.panel(3),'visible','off');
set(h.panel(6),'visible','off');

set(h.push(1),'visible','on'); 
set(h.push(2),'visible','on'); 
set(h.push(3),'visible','on');

check1=get(h.h_checkbox,'Value');

if check1{3}==1

    set(h.h_checkbox(3),'Value',1)
    set(h.h_checkbox(1),'enable','off');
    set(h.h_checkbox(2),'enable','off');
    set(h.h_checkbox(4),'enable','off');
    
    set(h.taptext,'enable','off');
    
    set(h.list,'enable','on');
    
    set(h.pop(1),'enable','off')
    
    set(h.pop(4),'enable','off')  % surf input 
    set(h.inputtext,'enable','off')
    
    config.SS_meth='RH';

elseif check1{3}==0
    
    set(h.h_checkbox(3),'Value',0)
    set(h.h_checkbox(1),'enable','on');
    set(h.h_checkbox(2),'enable','on');
    set(h.h_checkbox(4),'enable','on');
    
    set(h.push(1),'enable','off');
    set(h.push(2),'enable','off');
    set(h.push(3),'enable','off'); 
    set(h.push(1),'visible','off');
    set(h.push(2),'visible','off');
    set(h.push(3),'visible','off');

    set(h.taptext,'enable','off');
    
    set(h.list,'enable','off');
    
    set(h.pop(1),'enable','off')
    
    set(h.pop(4),'enable','on') % surf input 
    set(h.inputtext,'enable','on')
    set(h.list,'value',[])
    

    
end

% remove blue dots on worldmap when no option is selected
if sum([check1{:}])==0
    
        find_bluedot=findobj(h.EQstatsax,'type','line');
        
        if config.maptool==1 
            if length(find_bluedot) > 4    
                set(find_bluedot(1:end-4),'Visible','off')
                delete(find_bluedot(1)) 
            end    
        else
            if length(find_bluedot) > 3  
                set(find_bluedot(1:end-3),'Visible','off') 
                delete(find_bluedot(1))
            end
        end
end

end

%==================================================================================================================================
%================================================================================================================================== 
% call SIMW radio button

function call_checkSIMW(hObject,~,~)

global config

h=guidata(hObject);

set(h.panel(2),'visible','off'); 
set(h.panel(3),'visible','off'); 
set(h.panel(6),'visible','off');


set(h.push(1),'visible','off');
set(h.push(2),'visible','off');
set(h.push(3),'visible','off');

check1=get(h.h_checkbox,'Value');

if check1{4}==1

    set(h.h_checkbox(4),'Value',1);
    set(h.h_checkbox(3),'enable','off')
    set(h.h_checkbox(1),'enable','off');
    set(h.h_checkbox(2),'enable','off');
    
    set(h.push(5),'enable','off');
    set(h.push(5),'visible','on');
    
    set(h.taptext,'enable','on');
    
    set(h.list,'enable','on');
    
    set(h.pop(1),'enable','on')
    
    set(h.pop(4),'enable','off')
    set(h.inputtext,'enable','off')
    
    config.SS_meth='SIMW';

elseif check1{4}==0
    
    set(h.h_checkbox(4),'Value',0)
    set(h.h_checkbox(3),'enable','on')
    set(h.h_checkbox(1),'enable','on');
    set(h.h_checkbox(2),'enable','on');
    
    set(h.push(1),'enable','off');
    set(h.push(1),'visible','off');
    set(h.push(2),'visible','off');
    set(h.push(2),'enable','off');
    set(h.push(3),'visible','off');
    set(h.push(3),'enable','off');
    set(h.push(5),'enable','off');
    set(h.push(5),'visible','off');
    
    set(h.taptext,'enable','off');
    
    set(h.list,'enable','off');

    set(h.pop(1),'enable','off')
    
    set(h.pop(4),'enable','on')
    set(h.inputtext,'enable','on')
    
    set(h.list,'value',[])
    
    
end

% remove blue dots on worldmap when no option is selected
if sum([check1{:}])==0
    
        find_bluedot=findobj(h.EQstatsax,'type','line');
        
        if config.maptool==1 
            if length(find_bluedot) > 4    
                set(find_bluedot(1:end-4),'Visible','off')
                delete(find_bluedot(1)) 
            end    
        else
            if length(find_bluedot) > 3  
                set(find_bluedot(1:end-3),'Visible','off') 
                delete(find_bluedot(1))
            end
        end
end

end

%==================================================================================================================================
%================================================================================================================================== 
% call TAPER popup 

function call_popTAP(hObject,~,~)

    global config

    h=guidata(hObject);
    checkpop=get(h.pop(1),'Value');

    popupcont=0:0.1:1; % assign corresponding value to selected position in popup menu, 0 corresponds to none
    usetap=popupcont(checkpop);
    h.usetap=usetap;
    
    inputs={'none', 10, 20, 30, 40, 50, 60, 70, 80, 90, 100};
    
    config.SS_tap=cell2mat(inputs(checkpop));
    
    guidata(hObject, h);

end

%==================================================================================================================================
%================================================================================================================================== 
% call SURF popup, Esurf or EVsurf

function call_popSURF(hObject,~,~)

    global config 
    
    h=guidata(hObject);
    checkpop=get(h.pop(4),'Value');

    if checkpop==1 % use energysurface
        h.surf_kind=1;
        config.SS_surf='Esurf';
    elseif checkpop==2 % use EV surface
        h.surf_kind=2;
        config.SS_surf='EVsurf';
    end
    
    guidata(hObject, h);
    
end

%==================================================================================================================================
%================================================================================================================================== 
% call maxBAZ popup 

function call_popMAXBAZ(hObject,~,~)

    global config

    h=guidata(hObject);
    checkpop=get(h.pop(2),'Value');

    inputs={'none', 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    config.SS_maxbaz=cell2mat(inputs(checkpop));
    
    guidata(hObject, h);

end

% call maxdist popup 
function call_popMAXDIST(hObject,~,~)

    global config

    h=guidata(hObject);
    checkpop=get(h.pop(3),'Value');

    inputs={'none', 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    config.SS_maxdist=cell2mat(inputs(checkpop));

    guidata(hObject, h);

end

% call maxpol popup 
function call_popMAXPOL(hObject,~,~)

    global config

    h=guidata(hObject);
    checkpop=get(h.pop(5),'Value');

    inputs={'none', 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20};
    config.SS_maxpol=cell2mat(inputs(checkpop));

    guidata(hObject, h);

end

%##############################################################################################################
%############################################################################################################## 
% END of CALLBACK FUNCTIONS