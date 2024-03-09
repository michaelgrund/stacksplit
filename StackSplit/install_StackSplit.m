function install_StackSplit()
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
% Install the StackSplit plugin on your system
%
%..........................................................................
%..........................................................................
% !!! SplitLab has to be installed before StackSplit can be installed !!!
%..........................................................................
%..........................................................................
%
% 1) Please unzip the downloaded StackSplit package and copy it into
%    SplitLab's main folder where the file < install_SplitLab.m > is located.
%    To find the path to this folder use the command:
%
%           folderSL = fileparts(which('install_SplitLab.m'))
%
%
% 2) Please add the following folder to your MATLAB search path:
%
%           SplitLabX.X.X/StackSplit
%
%    For editing the path use the command:
%
%            pathtool
%
% 3) Change to the StackSplit folder in the SplitLab main directory
%
%            cd(folderSL + '/StackSplit')
%
% 4) Run this function < install_StackSplit.m > in your command window
%
% 5) Restart MATLAB
%
%
% GENERAL REMARKS
%
% Besides the StackSplit functions, the package also contains modified
% SplitLab functions which are necessary to generate the multi-event output.
% All these functions (except the SL starting function < splitlab.m >) are
% located in the original SL folders ShearWaveSplitting, Tools, and private.
%
% By running this installation file, all original functions are renamed
% with a suffix *_ori. The (new) modified ones are copied to their
% corresponding paths and have the same names as the others before renaming.
% But their content is slightly modified!
%
% So, if you are not happy with StackSplit you easily can recover your
% original SplitLab settings (see function < uninstall_StackSplit.m >)
% without big efforts. Otherwise, if you are sure you want to use
% StackSplit in future without returning to the standalone SL version,
% you can also delete the *_ori files manually or copy them to a place of
% your choice for backup.
%
% The changes in the modified SL functions in general do not affect any
% calculations within the functions except < geterrorbars.m > and
% < geterrorbarsRC.m > where modified equations for error calculations
% after Walsh et al. (2013) and a fixed taper application were implemented!
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
% Major updates:
%
% Yvonne Fröhlich (YF)
% https://github.com/yvonnefroehlich, https://orcid.org/0000-0002-8566-0619
%
% - v3.0 (2021) - YF
%   Modifications to fix extraction of start time by SplitLab
%   (unconsidered milliseconds or seconds of start time)
%   See also https://github.com/yvonnefroehlich/SplitLab-TemporalAlignment
%
% - v3.1 (2024) - YF
%   Up on MATLAB R2024a, recommendation "To improve performance, use
%   isscalar instead of length comparison."
%   Update length(xyz)==1 to isscalar(xyz)
%
% - v3.1 (2024) - YF
%   Improvements to load matTaup Java classes
%==========================================================================

%==================================================================================================================================
%==================================================================================================================================

% START installation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%========================
filesuffix='_ori';
%========================

% search for original SL folder
[folderSL, ~, ~]=fileparts(which('install_SplitLab.m'));

% check if RP version is available
[folderSLRP, ~, ~]=fileparts(which('SL_swap_QT_components.m'));

if ~isempty(folderSL) && isempty(folderSLRP)
    cd(folderSL)
    SL_version=1;
    disp(' ')
    disp('SplitLab version 1.0.5 was found on your system!')
elseif ~isempty(folderSL) && ~isempty(folderSLRP) && strcmp(folderSL,folderSLRP)
    cd(folderSL)
    SL_version=2;
    disp(' ')
    disp('SplitLab version 1.2.1 (by Rob Porritt) was found on your system!')
else
    errordlg('No SplitLab version found!')
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check if original SL function is already renamed
dir_orifiles=dir(['splitlab' filesuffix '.m']);

% check for unzipped StackSplit folder
dirSS=dir('StackSpl*');

if ~isempty(dirSS) && isfolder(dirSS.name) && isscalar(dirSS) && ~isempty(dir_orifiles)  % YF 2024-01-11
    disp(' ')
    disp('Installation aborted. Found installed version of StackSplit!')
    errordlg('StackSplit was already installed on your system!')
    return
end

if ~isempty(dirSS) && isfolder(dirSS.name) && isscalar(dirSS)  % YF 2024-01-11
    pathSS=[folderSL '/StackSplit'];
    disp(' ')
    disp('Start installation of StackSplit...')
else
    errordlg(['Missing StackSplit folder! Before installing, please first ' ...
        'copy the (unzipped) StackSplit folder to the SplitLab main folder!'])
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%============
% welcome

welcomestring={['Welcome to StackSplit - a plugin for multi-event ' ...
    'shear wave splitting analyses in SplitLab'], ' ', ...
    'Do you want to continue installing this package on your system?'};

pos = get(0,'DefaultFigurePosition');
pos(3:4) = [560 200];
H = figure('Name', 'StackSplit Installer', 'Color','w','units','Pixel',...
    'NumberTitle','Off','ToolBar','none','MenuBar','none','Position',pos);

uicontrol('style','text','Parent',H,'units','Pixel','String',welcomestring,...
    'Position',[30 100 pos(3:4)-[60 130]], 'BackGroundColor','w','HorizontalAlignment','Center');
uicontrol('style','pushbutton','Parent',H,'units','Pixel','String','Yes',...
    'Position',[190 15 90 25],'Callback',' set(0,''Userdata'',1);uiresume; closereq; ');
uicontrol('style','pushbutton','Parent',H,'units','Pixel','String','No',...
    'Position',[290 15 90 25],'Callback','set(0,''Userdata'',0);uiresume; closereq; ');

uiwait
agree = get(0,'Userdata');
if ~agree
    return
end

%============
% disclaimer

licensestring={'DISCLAIMER:',' '...
    '1) TERMS OF USE'...
    ['StackSplit is provided "as is" and without any warranty. The author cannot be held '...
    'responsible for anything that happens to you or your equipment. '],...
    'Use it at your own risk.',' ',...
    '2) LICENSE:',...
    ['StackSplit is free software; you can redistribute it and/or modify ',...
    'it under the terms of the GNU General Public License as published by ',...
    'the Free Software Foundation; either version 3 of the License, or ',...
    '(at your option) any later version.'],...
    ' ',...
    ['This program is distributed in the hope that it will be useful,',...
    'but WITHOUT ANY WARRANTY; without even the implied warranty of ',...
    'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the ',...
    'GNU General Public License for more details.'],...
    ' ',...
    ['You should have received a copy of the GNU General Public License ',...
    'along with this program. If not, see <http://www.gnu.org/licenses/>'],' ',' '};

pos = get(0,'DefaultFigurePosition');
pos(3:4) = [ 560 420];
H = figure('Name', 'StackSplit Licence Agreement', 'Color','w','units','Pixel',...
    'NumberTitle','Off','ToolBar','none','MenuBar','none','Position',pos);

uicontrol('style','text','Parent',H,'units','Pixel','String',licensestring,...
    'Position',[30 100 pos(3:4)-[60 130]], 'BackGroundColor','w','HorizontalAlignment','Center');

uicontrol('style','pushbutton','Parent',H,'units','Pixel','String','I agree...',...
    'Position',[190 15 90 25],'Callback',' set(0,''Userdata'',1);uiresume; closereq; ');
uicontrol('style','pushbutton','Parent',H,'units','Pixel','String','I do not agree!!!',...
    'Position',[290 15 90 25],'Callback','set(0,''Userdata'',0);uiresume; closereq; ');

uiwait
agree = get(0,'Userdata');
if ~agree
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first rename the original SplitLab files to *_ori

% in total
% - 9 original files have to be modified
% - 1 new files has to be added
% for running StackSplit

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN FOLDER

% #1 =====================
% < splitlab.m >
% =======================
% changes: added a new button on the left panel to access StackSplit
% (and corresponding callbacks), position depends on the version
% (original or from Rob Porritt), add commands to close StackSplit if a
% new SplitLab project is loaded

dir_splitlab=dir('splitlab.m');

if ~isempty(dir_splitlab)
    movefile(dir_splitlab.name,['splitlab' filesuffix '.m'])
else
    errordlg('Missing file < splitlab.m >!')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFOLDER ShearWaveSplitting

dir_SWS=dir('*WaveSplitting');

if ~isempty(dir_SWS) && isfolder(dir_SWS.name) && isscalar(dir_SWS)  % YF 2024-01-11
    cd(dir_SWS.name)
    pathSWS=pwd;
else
    errordlg('Missing subfolder ShearWaveSplitting!')
    return
end

% check if original SL functions are already renamed
dir_orifiles=dir(['*' filesuffix '.m']);

if isempty(dir_orifiles)

    % #2 =====================
    % < geterrorbars.m >
    %=======================
    % changes: fixed taper, fixed NDF calculation based on Walsh et al. (2013),
    % new output argument ndf

    dir_geterrors1=dir('geterrorbars.m');
    movefile(dir_geterrors1.name,['geterrorbars' filesuffix '.m'])

    % #3 ====================
    % < geterrorbarsRC.m >
    %=======================
    % changes: fixed taper, fixed NDF calculation based on Walsh et al. (2013),
    % new output argument ndf

    dir_geterrors2=dir('geterrorbarsRC.m');
    movefile(dir_geterrors2.name,['geterrorbarsRC' filesuffix '.m'])

    % #4 ====================
    % < preSplit.m >
    %=======================
    % changes: added further output information to temporary variable
    % thiseq.tmpresult, like cut component traces, ndfs etc.

    dir_preSplit=dir('preSplit.m');
    movefile(dir_preSplit.name,['preSplit' filesuffix '.m'])

    % #5 ====================
    % < saveresult.m >
    %=======================
    % changes: added further output information to permanent variable eq,
    % like cut component traces, ndfs etc.,

    dir_saveresult=dir('saveresult.m');
    movefile(dir_saveresult.name,['saveresult' filesuffix '.m'])

    % #6 ====================
    % < splitdiagnosticplot.m >
    %=======================
    % changes: changed the position where Emap and Cmap are saved and
    % separated EVmap to additionally save it

    dir_diagplot=dir('splitdiagnosticplot.m');
    movefile(dir_diagplot.name,['splitdiagnosticplot' filesuffix '.m'])

end

cd(folderSL)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFOLDER Tools

dir_TOOL=dir('*Tools');

if ~isempty(dir_TOOL) && isfolder(dir_TOOL.name) && isscalar(dir_TOOL)  % YF 2024-01-11
    cd(dir_TOOL.name)
    pathTOOL=pwd;
else
    errordlg('Missing subfolder Tools!')
    return
end

% check if original SL functions are already renamed
dir_orifiles=dir(['*' filesuffix '.m']);

if isempty(dir_orifiles)

    % #7 =====================
    % < database_editResults.m >
    %=======================
    % changes: if a phase result/event is deleted after any phase splitting calculation
	% in the database viewer, the variable "eq" is saved in this function, otherwise in StackSplit
	% the deleted event would still appear in the event list!

    dir_databaseedit=dir('database_editResults.m');
    movefile(dir_databaseedit.name,['database_editResults' filesuffix '.m'])

    % #8 =====================
    % < getFileAndEQseconds.m >
    %=======================
	% changes: fixed start time extraction by SplitLab

	dir_getfileandeqsec=dir('getFileAndEQseconds.m');
    movefile(dir_getfileandeqsec.name,['getFileAndEQseconds' filesuffix '.m'])

end

cd(folderSL)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFOLDER private

dir_priv=dir('*private');

if ~isempty(dir_priv) && isfolder(dir_priv.name) && isscalar(dir_priv)  % YF 2024-01-11
    cd(dir_priv.name)
    pathpriv=pwd;
else
    errordlg('Missing subfolder private!')
    return
end

% check if original SL functions are already renamed
dir_orifiles=dir(['*' filesuffix '.m']);

if isempty(dir_orifiles)

    % #9 =====================
    % < seisfigbuttons.m >
    %=======================
    % changes: if an event is deleted after any phase splitting calculation
	% in the SeismoViewer, the variable "eq" is saved in this function, otherwise in StackSplit
	% the deleted event would still appear in the event list!

    dir_seisfig=dir('seisfigbuttons.m');
    movefile(dir_seisfig.name,['seisfigbuttons' filesuffix '.m'])

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now copy the modified versions into the corresponding folders depending
% on the used SL version

if SL_version==1
    cd([pathSS '/SL_mod/SL_1.0.5_mod'])
elseif SL_version==2
    cd([pathSS '/SL_mod/SL_1.2.1_mod'])
end

copyfile('splitlab_SS.m',folderSL)
copyfile('geterrorbars_SS.m',pathSWS)
copyfile('geterrorbarsRC_SS.m',pathSWS)
copyfile('preSplit_SS.m',pathSWS)
copyfile('saveresult_SS.m',pathSWS)
copyfile('splitdiagnosticplot_SS.m',pathSWS)
copyfile('database_editResults_SS.m',pathTOOL)
copyfile('getFileAndEQseconds_SS.m',pathTOOL)
copyfile('checkmattaupclass_SS.m',pathTOOL)
copyfile('seisfigbuttons_SS.m',pathpriv)

% cleanup/remove folder SL_mod
cd(pathSS)
rmdir('SL_mod','s')

% cd to the four corresponding folders and rename *_SS.m version to original names

% main folder
cd(folderSL)
movefile('splitlab_SS.m','splitlab.m') % rename modified SplitLab file to original name

% SWS folder
cd(pathSWS)
movefile('geterrorbars_SS.m','geterrorbars.m')
movefile('geterrorbarsRC_SS.m','geterrorbarsRC.m')
movefile('preSplit_SS.m','preSplit.m')
movefile('saveresult_SS.m','saveresult.m')
movefile('splitdiagnosticplot_SS.m','splitdiagnosticplot.m')

% Tools folder
cd(pathTOOL)
movefile('database_editResults_SS.m','database_editResults.m')
movefile('getFileAndEQseconds_SS.m','getFileAndEQseconds.m')
movefile('checkmattaupclass_SS.m','checkmattaupclass.m')

% private folder
cd(pathpriv)
movefile('seisfigbuttons_SS.m','seisfigbuttons.m')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% final check

cd(folderSL)
if ~isempty(dir('splitlab.m'))
   cd(pathSWS)

   if sum(isempty(dir('preSplit.m')) && isempty(dir('geterrorbars.m')) && ...
           isempty(dir('geterrorbarsRC.m')) && isempty(dir('saveresults.m')) && ...
           isempty(dir('splitdiagnosticplot.m')))==0

       cd(pathTOOL)

            if ~isempty(dir('database_editResults.m')) && ...
				~isempty(dir('getFileAndEQseconds.m'))

              cd(pathpriv)

                   if ~isempty(dir('seisfigbuttons.m'))

                        disp(' ')
                        disp('Installation completed!')

                        msgbox(['StackSplit was successfully installed on your system! ' ...
                            'Please restart MATLAB!'],'Installation completed');

                   end
            end
   end
end

% EOF
