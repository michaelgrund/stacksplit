function out = checkmattaupclass

%##########################################################################
% Load matTaup java class for SplitLab
% Modified from same function of SplitLab 1.9.0
%==========================================================================
% created: 2024/01/25
% contact: yvonne.froehlich@kit.edu
%##########################################################################


global thiseq eq config


jpath = javaclasspath('-all');
f     = strfind(jpath,'matTaup.jar');
e     = cellfun('isempty',f);
path2jar = which('matTaup.jar');


if all(e) % no match found in classpath

    p = fileparts(which('taup.m'));

    if isempty(p)
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
