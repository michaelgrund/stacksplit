function h=SS_basic_settings(h,merged_str,find_res)
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
% set basic settings for GUI (buttons, axes etc.)
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
% If the single listbox entries are not perfectly aligned below their
% corresponding headline entry (t0time, JD, BAZ etc.) please adjust the
% listbox's fontsize in the following line until everything is according to
% your wishes ;)

fontsize_list=13;

%==================================================================================================================================

global config

% first check if StackSplit fields are already available in config,
% if yes the user saved the project for this station before with the
% available settings, otherwise the fields are created in the following

%VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
% default values for max diffBAZ/diffdist/diffinipol selection 

if isfield(config,'SS_maxbaz') && isfield(config,'SS_maxdist') && isfield(config,'SS_maxpol')
    % set popups to corresponding start values, if available in config
    
    inputs=0:1:10;

    [~,b]=ismember(config.SS_maxbaz,inputs);
    if b~=0 
        set(h.pop(2),'Value',b);
    else
        set(h.pop(2),'Value',1);
    end

    [~,b]=ismember(config.SS_maxdist,inputs);
    if b~=0 
        set(h.pop(3),'Value',b);
    else
        set(h.pop(3),'Value',1);
    end
    
    inputs=0:1:20;
    
    [~,b]=ismember(config.SS_maxpol,inputs);
    if b~=0 
        set(h.pop(5),'Value',b);
    else
        set(h.pop(5),'Value',1);
    end

else % default settings

    inputs={'none', 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    config.SS_maxbaz=cell2mat(inputs(6));   % default deltaBAZ is 5°
    config.SS_maxdist=cell2mat(inputs(6));  % default deltadist is 5°
    inputs={'none', 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20};
    config.SS_maxpol=cell2mat(inputs(6));   % default deltapol is 5°
    
    set(h.pop(2),'Value',6);
    set(h.pop(3),'Value',6);
    set(h.pop(5),'Value',6);
    
end

%VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
% stacking method

% fist set all buttons off
set(h.check(1),'enable','off'); % no weighting
set(h.check(2),'enable','off'); % WS
set(h.check(3),'enable','off'); % RH
set(h.check(4),'enable','off'); % SIMW

% if field exists which method was latest before closing last StackSplit session
if isfield(config,'SS_meth')
    
    if strcmp(config.SS_meth,'nw')
        
       set(h.check(1),'enable','on');  
       set(h.check(1),'Value',1)
       set(h.pop(1),'enable','off'); % SIMW pop up for taper selection
       set(h.taptext,'enable','off'); % taper text off
       set(h.push(1),'visible','on')
       set(h.push(2),'visible','on')
       set(h.push(3),'visible','on')
       set(h.push(1),'enable','off')
       set(h.push(2),'enable','off')
       set(h.push(3),'enable','off')
       set(h.push(5),'visible','off')
        
    elseif strcmp(config.SS_meth,'WS')
        
       set(h.check(2),'enable','on');  
       set(h.check(2),'Value',1)  
       set(h.pop(1),'enable','off'); % SIMW pop up for taper selection
       set(h.taptext,'enable','off'); % taper text off
       set(h.push(1),'visible','on')
       set(h.push(2),'visible','on')
       set(h.push(3),'visible','on')       
       set(h.push(1),'enable','off')
       set(h.push(2),'enable','off')
       set(h.push(3),'enable','off')
       set(h.push(5),'visible','off')

    elseif strcmp(config.SS_meth,'RH')
        
       set(h.check(3),'enable','on');  
       set(h.check(3),'Value',1) 
       set(h.pop(1),'enable','off'); % SIMW pop up for taper selection
       set(h.taptext,'enable','off'); % taper text off
       set(h.push(1),'visible','on')
       set(h.push(2),'visible','on')
       set(h.push(3),'visible','on')
       set(h.push(1),'enable','off')
       set(h.push(2),'enable','off')
       set(h.push(3),'enable','off')
       set(h.push(5),'visible','off')

    elseif strcmp(config.SS_meth,'SIMW') 
        
       set(h.check(4),'enable','on');  
       set(h.check(4),'Value',1) 
       set(h.pop(1),'enable','on'); % SIMW pop up for taper selection
       set(h.taptext,'enable','on'); % taper text on
       set(h.push(1),'visible','off')
       set(h.push(2),'visible','off')
       set(h.push(3),'visible','off')
       set(h.push(5),'visible','on')
       set(h.push(5),'enable','off')
       
    end
    
else % default values (first run of StackSplit)

    set(h.check(1),'Value',1)  
    set(h.check(1),'enable','on');
    set(h.check(2),'enable','off'); 
    set(h.check(3),'enable','off'); 
    set(h.check(4),'enable','off');
    
    % action buttons
    set(h.push(1),'enable','off'); % stack button off
    set(h.push(2),'enable','off'); % refresh button off
    set(h.push(3),'enable','off'); % save button off
    set(h.push(5),'enable','off'); % inversion button SIMW off
    set(h.push(5),'visible','off'); % inversion button SIMW not visible

    config.SS_meth='nw';
    
    set(h.pop(1),'enable','off'); % SIMW pop up for taper selection

end 

h_checkbox(1) = h.check(1);
h_checkbox(2) = h.check(2);
h_checkbox(3) = h.check(3);
h_checkbox(4) = h.check(4);
h.h_checkbox = h_checkbox;

%VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
% taper

popupcont=0:0.1:1; % taper 0% (none) - 100% (1)

if isfield(config,'SS_tap') 
    % set popups to corresponding start values, if available in config
    inputs=0:10:100;

    [~,b]=ismember(config.SS_tap,inputs);
    
    if b~=0 
        set(h.pop(1),'Value',b);
        h.usetap=popupcont(b);
    else
        set(h.pop(1),'Value',1);
        h.usetap=popupcont(1); 
    end

else %default taper setting 
    defval_tap=3; %  20% of the wdw is influenced by the taper => 10% at the beginning and 10% at the end
    set(h.pop(1),'Value',defval_tap);
    h.usetap=popupcont(defval_tap);
    
    inputs={'none', 10, 20, 30, 40, 50, 60, 70, 80, 90, 100};
    config.SS_tap=cell2mat(inputs(defval_tap));
end

%VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
% surface input

if isfield(config,'SS_surf') 

    if strcmp(config.SS_surf,'Esurf')
        h.surf_kind=1;
        set(h.pop(4),'Value',1); 
    elseif strcmp(config.SS_surf,'EVsurf')
        h.surf_kind=2;
        set(h.pop(4),'Value',2);
    end
    
else
    
    % default surface is energymap
    h.surf_kind=1;
    set(h.pop(4),'Value',1);
    config.SS_surf='Esurf';

end

set(h.pop(4),'enable','off');
set(h.inputtext,'enable','off') 
    
%VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
% listbox settings
set(h.list,'fontunits','pixel')

set(h.list,'string',merged_str,'fontsize',fontsize_list);
set(h.list,'Max',length(find_res),'Min',0);
  
h.list_origin=merged_str;

%VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
% panel and axes settings
cla reset
set(gca,'xticklabel',[])
set(gca,'yticklabel',[])
set(gca,'xtick',[])
set(gca,'ytick',[])
box on
set(gca,'visible','off')

set(h.panel(2),'visible','off');
set(h.panel(3),'visible','off'); 
set(h.panel(6),'visible','off'); % SIMW waveforms 

%VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
% write input data to handle
h.data=find_res;

%VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
%EOF
%==================================================================================================================================
%==================================================================================================================================