function out = checkmattaupclass

% #########################################################################
% Load matTaup Java classes for SplitLab
% PR #26 https://github.com/michaelgrund/stacksplit/pull/26
% Modified from the checkmattaupclass function of SplitLab 1.9.0
% https://github.com/IPGP/splitlab/blob/master/SplitLab1.9.0/Tools/checkmattaupclass.m
% last access 2024-01-30
% =========================================================================
% created: 2024-01-25
% author: Yvonne Fröhlich
% contact: https://github.com/yvonnefroehlich, https://orcid.org/0000-0002-8566-0619
% #########################################################################


global thiseq eq config


java_paths = javaclasspath('-all');
find_taup = strfind(java_paths,'matTaup.jar');
not_found_taup = cellfun('isempty',find_taup);
path2jar = which('matTaup.jar');


if all(not_found_taup)  % no match found in classpath

    path_taup = fileparts(which('taup.m'));

    if isempty(path_taup)
        disp('Error: Could not establish matTaup Java path. No phases will be calculated!')
        out = false;
        return
    else

        fprintf(2,'The matTaup Java classes will now be loaded.\n')
        fprintf(2,'Please wait ...')

        if exist(path2jar,'file')
            javaaddpath(path2jar)
        else
            disp('Error: Could not find matTaup.jar!')
            out = 0;
            return
        end

        evalin('base','global eq thiseq config');
        evalin('caller','global eq thiseq config')  % These have been cleared previously by javaaddpath ...

        fprintf(2,'Done!\n')
        fprintf(2,'The matTaup Java classes have been loaded for this session of Matlab.\n')
        fprintf(2,'You can now continue with your work.\n\n')

        out = -1;
    end

else

    out = true;
end
