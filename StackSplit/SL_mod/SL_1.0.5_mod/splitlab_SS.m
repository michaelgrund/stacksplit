
function splitlab
% Main window of the SplitLab toolbox, configure the parameters and projects
% creating the configuration figure of Splitlab

global config eq


SL_checkversion
config.version='SplitLab1.0.4';

[p,f] = fileparts(mfilename('fullpath'));  % directory of SplitLab
set(0,'DefaultFigurecolor', [224   223   227]/255 ,...
      'DefaultFigureWindowStyle','normal',...
      'DefaultUIControlBackgroundColor', [224   223   227]/255) 
cfig=findobj('type','Figure','name',['Configure ' config.version]);
if isempty(cfig)
    cfig=figure('name',['Configure ' config.version],...
        'Menubar','none',...
        'NumberTitle','off','units','pixel');
else
    clf
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load icon.mat ;

p = get(0,'DefaultFigurePosition');
p(3:4)=[560 420];
set(gcf,'Position',p,'Resize','off');
pos = [130 5 425 410];

configpanelGENERAL;
configpanelSTATION;
configpanelPHASES;
configpanelSEARCHWIN;
configpanelUSER;
configpanelFINDFILE;



set(h.panel(2:end), 'Visible','off');


%% Side panel: radio buttons
h.menu = uibuttongroup('visible','off','units','pixel','Position',[5 5 120 410],...
    'BackgroundColor','w','HighlightColor',[1 1 1]*.3,...
    'BorderWidth',1,'BorderType','beveledin' );

h.menu(2) = uicontrol(...
    'Style','Radio','String','General',...
    'BackgroundColor','w',...
    'pos',[10 350 100 30],'parent',h.menu(1),'HandleVisibility','off',...
    'Userdata',h.panel([6 8]));
h.menu(4) = uicontrol(...
    'Style','Radio','String','Station',...
    'BackgroundColor','w',...
    'pos',[10 325 100 30],'parent',h.menu(1),'HandleVisibility','off',...
    'Userdata',h.panel(1 ));
h.menu(4) = uicontrol(...
    'Style','Radio','String','Event window',...
    'BackgroundColor','w',...
    'pos',[10 300 100 30],'parent',h.menu(1),'HandleVisibility','off',...
    'Userdata',h.panel(3));
h.menu(5) = uicontrol(...
    'Style','Radio','String','Request',...
    'BackgroundColor','w',...
    'pos',[10 275 100 30],'parent',h.menu(1),'HandleVisibility','off',...
    'Userdata',h.panel(4:5));
h.menu(3) = uicontrol(...
    'Style','Radio','String','Phases',...
    'BackgroundColor','w',...
    'pos',[10 250 100 30],'parent',h.menu(1),'HandleVisibility','off',...
    'Userdata',h.panel(2));
h.menu(6) = uicontrol(...
    'Style','Radio','String','Find Files ',...
    'BackgroundColor','w',...
    'pos',[10 225 100 30],'parent',h.menu(1),'HandleVisibility','off',...
    'Userdata',h.panel([7 9]));


%% Side panel: push buttons

%===================================================
%###################################################
%===================================================
% implementation of StackSplit (2016), -MG-

push_y=30; % move each pushbutton 30 pixels higher

% add new pushbutton << Stacking >> at lowemost position
h.menu(100) = uicontrol(...
    'Style','pushbutton',...
    'String','Stacking',...
    'BackgroundColor','w',...
    'pos',[10 10 100 25],'parent',h.menu(1),'HandleVisibility','off',...
    'Callback','SS_stacksplit_start');   
%===================================================
%###################################################
%===================================================

tmp = mfilename('fullpath');
tmp = fileparts(tmp);
tmp = ['file:///' tmp filesep 'Doc' filesep 'splitlab.html'];
uicontrol('parent',h.menu(1),...
    'Units','pixel',...
    'Style','Pushbutton',...
    'Position',[10 160+push_y 100 25],...
    'Cdata', icon.help,...
    'Tooltip',' See help documents',...
    'Callback',['web ' tmp  ]);
clear tmp
%-------------------------------------------------------------------------
pjtlist = getpref('Splitlab','History');
files   = {};
for k =1:length(pjtlist)
    [pp,name,ext] = fileparts(pjtlist{k});
    files{k}=[name ext];
end
loadstr={'    Load Project','    Browse...', files{:}};

h.menu(8) = uicontrol(...
    'Style','popupmenu',...
    'String',loadstr,...
    'UserData',pjtlist,...
    'BackgroundColor','w',...
    'pos',[10 130+push_y 100 25],'parent',h.menu(1),'HandleVisibility','off',...
    'Callback',@loadcallback);
%-------------------------------------------------------------------------
h.menu(7) = uicontrol(...
    'Style','pushbutton',...
    'String','Save Project As',...
    'BackgroundColor','w',...
    'pos',[10 100+push_y 100 25],'parent',h.menu(1),'HandleVisibility','off',...
    'Callback',@savecallback,...
    'USERDATA', h.menu(8));

h.menu(9) = uicontrol(...
    'Style','pushbutton',...
    'String','View Seismograms',...
    'ToolTipString','Start / Continue splitting',...
    'BackgroundColor','w',...
    'pos',[10 70+push_y 100 25],'parent',h.menu(1),'HandleVisibility','off',...
    'Callback','SL_SeismoViewer(config.db_index)'); %open last splitting event
h.menu(10) = uicontrol(...
    'Style','pushbutton',...
    'String',' View Database',...
    'BackgroundColor','w',...
    'pos',[10 40+push_y 100 25],'parent',h.menu(1),'HandleVisibility','off',...
    'Callback','SL_databaseViewer');
h.menu(10) = uicontrol(...
    'Style','pushbutton',...
    'String','Results',...
    'BackgroundColor','w',...
    'pos',[10 10+push_y 100 25],'parent',h.menu(1),'HandleVisibility','off',...
    'Callback','SL_Results');
h.menu(99) = uicontrol(...
    'Style','pushbutton',...
    'String',' Save Preferences',...
    'ToolTipString','Save current configuration as preference',...
    'BackgroundColor','w',...
    'pos',[7 380 106 22],'parent',h.menu(1),'HandleVisibility','off',...
    'Callback','SL_preferences(config);  helpdlg(''Preferences succesfully saved!'',''Preferences'')');

%==============================================================    

set(h.menu(1),'SelectionChangeFcn',@selcbk);
set(h.menu(1),'SelectedObject',[h.menu(2)]);
set(h.panel([6 8]),'Visible','on');
set(h.menu(1),'Visible','on');

figure(cfig)



% Interestingly, at startup the first value of the random generator is
% often 0.9501. So, generate first dummy random numbers, and then in a new
% round take two random numbers to state if postcard or acknowledgement
% dialogs are shown.
rand(100,100);
R = rand(1,2);   
%if R(1)>.92,    postcardware,      end %Delete this line, if you have already sent a PostCard
%if R(2)>.92,    acknowledgement,   end






%% S U B F U N C T I O N S %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function selcbk(source,eventdata)
%set selected menu panel visible, others are made invisible
old = get(eventdata.OldValue,'Userdata');
new = get(eventdata.NewValue,'Userdata');

set (old, 'visible', 'off')
set (new, 'visible', 'on')

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function loadcallback(source,eventdata)
evalin('base','global eq thiseq config');
global config eq

%===================================================
%###################################################
%===================================================
% StackSplit content, 2016-12-02 -MG-

% if open, close StackSplit when a new/other project is loaded  

if isfield(config,'SS_version')
    
    checkSS=findobj('type','figure','name',['StackSplit ' config.SS_version]);

    if ~isempty(checkSS)
        close(checkSS)
    end

    basews=evalin('base','who');
    existeqstack=ismember('eqstack',[basews(:)]);

    if ~isempty(existeqstack) 
        evalin('base','clearvars -global eqstack');
    end
    
end
%===================================================
%###################################################
%===================================================

val =get(gcbo,'Value');
if  val ==1;
    %"Load" string... do nothing!
    return
elseif  val == 2 %Browse...
    str ={'*.pjt', '*.pjt - SplitLab projects files';
        '*.mat', '*.mat - MatLab files';
        '*.*',     '* - All files'};
    pjtlist = getpref('Splitlab','History');
    
   [tmp1,pathstr] = uigetfile( str ,'Project file', [config.projectdir, filesep]) ; 
    if isstr(pathstr) %user did not cancle
        load('-mat',fullfile(pathstr,tmp1))
        newfile = fullfile(pathstr,tmp1);
        match = find(strcmp(newfile, pjtlist));

        if isempty(match)% selection not in history
            if length(pjtlist)>5
                pjtlist = {newfile, pjtlist{1:5}};
            else
                pjtlist = {newfile, pjtlist{:}};
            end
        else
            %re-order list
            L       = 1:length(pjtlist);
            new     = [match setdiff(L,match)];
            pjtlist = pjtlist(new);
        end
      else %user did cancle
          return
    end

else
    pjtlist = getpref('Splitlab','History');
    %moving recently loaded to top of list
    n        = val-2; %data does not contain the "Load" and "browse" entries
    L       = 1:length(pjtlist);
    new     = [n setdiff(L,n)];
    pjtlist = pjtlist(new);
    
    files = get(gcbo,'Userdata'); %need full path name, which is stored in userdata
    load('-mat',files{n})
    [pathstr,name] = fileparts(files{n});
end

config.projectdir = pathstr;

setpref('Splitlab','History', pjtlist);
splitlab


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function savecallback(src,e)
global config eq
str ={'*.pjt', '*.pjt - SplitLab projects files';
    '*.mat', '*.mat - MatLab files';
    '*.*',     '* - All files'};
[tmp1,tmp2]=uiputfile( str ,'Project file', ...
    [config.projectdir, filesep, config.project]);

if isstr(tmp2)
    oldpjt = config.project ;
    config.projectdir = tmp2;
    config.project    = tmp1;
    newfile = fullfile(tmp2,tmp1);
    pjtlist = getpref('Splitlab','History');
    match   = find(strcmp(newfile, pjtlist));

    if isempty(match)% selection not in history
        if length(pjtlist)>5
            pjtlist = {newfile, pjtlist{1:5}};
        else
            pjtlist = {newfile, pjtlist{:}};
        end
    else
        %re-order list
        L       = 1:length(pjtlist);
        new     = [match setdiff(L,match)];
        pjtlist = pjtlist(new);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    setpref('Splitlab','History', pjtlist)
    save(fullfile(tmp2,tmp1),    'config','eq')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    files   = {};
    for k =1:length(pjtlist);
        [pp,name,ext] = fileparts(pjtlist{k});
        files{k}=[name ext];
    end
    loadstr={'    Load Project','    Browse...', files{:}};
    loadUIcontrol = get(gcbo,'Userdata');
    set(loadUIcontrol,'UserData', pjtlist, 'String', loadstr)
    
    pjtfield = findobj('String',oldpjt,'type','uicontrol');
    set(pjtfield,'String',config.project)
    
end

clear tmp*

%% This program is part of SplitLab
% © 2006 Andreas Wüstefeld, Université de Montpellier, France
%
% DISCLAIMER:
% 
% 1) TERMS OF USE
% SplitLab is provided "as is" and without any warranty. The author cannot be
% held responsible for anything that happens to you or your equipment. Use it
% at your own risk.
% 
% 2) LICENSE:
% SplitLab is free software; you can redistribute it and/or modifyit under the
% terms of the GNU General Public License as published by the Free Software 
% Foundation; either version 2 of the License, or(at your option) any later 
% version.
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
% FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for 
% more details.