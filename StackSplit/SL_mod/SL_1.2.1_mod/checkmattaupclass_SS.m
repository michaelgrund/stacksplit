function out = checkmattaupclass

% #########################################################################
% Load matTaup java class for SplitLab
% Modified from same function of SplitLab 1.9.0
% https://github.com/IPGP/splitlab/blob/master/SplitLab1.9.0/Tools/checkmattaupclass.m
% last access 2024/01/30
% =========================================================================
% created: 2024/01/25
% contact: yvonne.froehlich@kit.edu
% #########################################################################


global thiseq eq config


java_paths = javaclasspath('-all');
find_taup = strfind(java_paths,'matTaup.jar');
not_found_taup = cellfun('isempty',find_taup);
path2jar = which('matTaup.jar');


if all(not_found_taup) % no match found in classpath

    path_taup = fileparts(which('taup.m'));

    if isempty(path_taup)
        disp('Error: Could not establish matTaup java path. No phases will be calculated.')
        out = false;
        return
    else

        fprintf(2,'The matTaup JAVA Classes will now be loaded.\n')
        fprintf(2,'Please wait...')

        if exist(path2jar,'file')
            javaaddpath(path2jar)
        else
            disp('Error: Could not find matTaup.jar')
            out = 0;
            return
        end

        evalin('base','global eq thiseq config');
        evalin('caller','global eq thiseq config')  % these have been cleard previously by javaaddpath....

        fprintf(2,'Done\n')
        fprintf(2,'Java classes of matTaup have been loaded for this session of Matlab.\n')
        fprintf(2,'You can now continue with your work\n\n')

        out = -1;
    end

else

    out = true;
end
