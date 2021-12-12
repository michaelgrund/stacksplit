function uninstall_StackSplit()
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
% To uninstall the StackSplit plugin from your system run 
%
%     >> uninstall_StackSplit()    in your command window
%
% includes: 
% 
% 1) removal of the whole StackSplit content (folder, functions etc.)
% 2) recovery of your original SplitLab copy as before the installation of
%    StackSplit
%
%==========================================================================
% LICENSE
%
% Copyright (C) 2016  Michael Grund, Karlsruhe Institute of Technology (KIT), 
% Email: michael.grund@kit.edu
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filesuffix='_ori';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% search for original SL folder 
[folderSL, ~, ~]=fileparts(which('install_SplitLab'));

if ~isempty(folderSL)
    cd(folderSL)
else
    errordlg('No SplitLab version found!')
end

% check for unzipped SS folder
dirSS=dir('StackSpl*');

if ~isempty(dirSS) && isfolder(dirSS.name) && length(dirSS)==1
    disp('Uninstall StackSplit...')
else
    errordlg('Missing StackSplit folder! Uninstallation aborted!')
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

farewellstring={'StackSplit did not fulfil your expectations? Simply open a new issue or PR on GitHub to give comments or address suggestions for improvements etc. ',...
    ' ','Do you want to continue uninstalling StackSplit from your system?'};

pos = get(0,'DefaultFigurePosition');
pos(3:4) = [560 200];
H = figure('Name', 'StackSplit uninstaller', 'Color','w','units','Pixel',...
    'NumberTitle','Off','ToolBar','none','MenuBar','none','Position',pos);

uicontrol('style','text','Parent',H,'units','Pixel','String',farewellstring,...
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

%===============================
% DELETE StackSplit folder
rmdir(dirSS.name,'s')
%===============================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN FOLDER

% check if original SL function (*_ori.m) is available
dir_orifiles=dir(['*' filesuffix '.m']); 

if ~isempty(dir_orifiles) && length(dir_orifiles)==1 && strcmp(dir_orifiles.name,['splitlab' filesuffix '.m'])

    % first delete the current SS version of the function with correct name
    dir_splitlab=dir('splitlab.m');
    
    if ~isempty(dir_splitlab)
        delete('splitlab.m')
    else
        errordlg('No file < splitlab.m > available to delete!')
        return
    end
    
    % then rename back the original SL file (*_ori.m) to the official name without *_ori
    movefile(dir_orifiles.name,'splitlab.m')
    
else
    errordlg(['No original SL file < splitlab' filesuffix '.m > available! Uninstallation aborted!'])
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SUBFOLDER Tools

dir_TOOL=dir('*Tools');

if ~isempty(dir_TOOL) && isfolder(dir_TOOL.name) && length(dir_TOOL)==1
    cd(dir_TOOL.name)
else
    errordlg('Missing subfolder Tools! Uninstallation aborted!')
end

% check if original SL function (*_ori.m) is available
dir_orifiles=dir(['*' filesuffix '.m']); 

if ~isempty(dir_orifiles) && length(dir_orifiles)==1 && strcmp(dir_orifiles.name,['database_editResults' filesuffix '.m'])

    % first delete the current SS version of the function with correct name
    dir_edres=dir('database_editResults.m');
    
    if ~isempty(dir_edres)
        delete('database_editResults.m')
    else
        errordlg('No file < database_editResults.m > available to delete!')
        return
    end
    
    % then rename back the original SL file (*_ori.m) to the official name without *_ori
    movefile(dir_orifiles.name,'database_editResults.m')
    
else
    errordlg(['No original SL file < database_editResults' filesuffix '.m > available! Uninstallation aborted!'])
    return
    
end

cd(folderSL)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SUBFOLDER private

dir_priv=dir('*private');

if ~isempty(dir_priv) && isfolder(dir_priv.name) && length(dir_priv)==1
    cd(dir_priv.name)
else
    errordlg('Missing subfolder private! Uninstallation aborted!')
end

% check if original SL function (*_ori.m) is available
dir_orifiles=dir(['*' filesuffix '.m']); 

if ~isempty(dir_orifiles) && length(dir_orifiles)==1 && strcmp(dir_orifiles.name,['seisfigbuttons' filesuffix '.m'])

    % first delete the current SS version of the function with correct name
    dir_seisfig=dir('seisfigbuttons.m');
    
    if ~isempty(dir_seisfig)
        delete('seisfigbuttons.m')
    else
        errordlg('No file < seisfigbuttons.m > available to delete!')
        return
    end
    
    % then rename back the original SL file (*_ori.m) to the official name without *_ori
    movefile(dir_orifiles.name,'seisfigbuttons.m')
    
else
    errordlg(['No original SL file < seisfigbuttons' filesuffix '.m > available! Uninstallation aborted!'])
    return
    
end

cd(folderSL)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SUBFOLDER ShearWaveSplitting

dir_SWS=dir('*WaveSplitting');

if ~isempty(dir_SWS) && isfolder(dir_SWS.name) && length(dir_SWS)==1
    cd(dir_SWS.name)
else
    errordlg('Missing subfolder ShearWaveSplitting! Uninstallation aborted!')
end

files2delete{1}='geterrorbars.m';
files2delete{2}='geterrorbarsRC.m';
files2delete{3}='preSplit.m';
files2delete{4}='saveresult.m';
files2delete{5}='splitdiagnosticplot.m';

files2rename{1}=['geterrorbars' filesuffix '.m'];
files2rename{2}=['geterrorbarsRC' filesuffix '.m'];
files2rename{3}=['preSplit' filesuffix '.m'];
files2rename{4}=['saveresult' filesuffix '.m'];
files2rename{5}=['splitdiagnosticplot' filesuffix '.m'];

% check if original SL functions (*_ori.m) are available
dir_orifiles=dir(['*' filesuffix '.m']); 

if ~isempty(dir_orifiles) && length(dir_orifiles)==5

    for ii=1:length(files2rename)
        strold(ii)=sum(cell2mat(strfind({dir_orifiles.name},files2rename{ii})));
    end 

    if sum(strold)~=5  
        errordlg(['Missing files with suffix *' filesuffix '!'])
        return 
    end

    %================================================================
    for ii=1:length(files2delete)
        
        % delete SS version of file
        dir_file2del=dir(files2delete{ii});
        
        if ~isempty(dir_file2del)
            delete(files2delete{ii});
        else
           errordlg(['Missing file ' files2delete{ii} '!']) 
        end
        
        % rename original SL files (*_ori.m) to the official name without *_ori
        dir_file2ren=dir(files2rename{ii});
                
        if ~isempty(dir_file2ren)
            % here we use the names of files2delete to rename the original
            % SL files to their original name
            %
            % files2rename: *.ori.m
            % files2delete:     *.m
            movefile(files2rename{ii},files2delete{ii});
        else
           errordlg(['Missing file ' files2rename{ii} '!']) 
        end
        
    end
    %================================================================
    
    disp(' ')    
    disp('Uninstallation of StackSplit successfully finished!')

    msgbox('StackSplit was successfully removed from your system!','Uninstallation complete');

else
    errordlg(['Missing files with suffix *' filesuffix '! Uninstallation aborted!'])
    return
end

cd(folderSL)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EOF