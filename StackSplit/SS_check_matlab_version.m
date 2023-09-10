function vers_out=SS_check_matlab_version()
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
% Check MATLAB version to distinguish between versions:
%
% (I) Applying the "contourf" function to create the energy maps
%  (1) vers_out == 0: R2014a and lower: -v6 flag is necessary
%  (2) vers_out > 0:  R2014b and higher: -v6 flag is not supported anymore
%
% (II) Using the coastlines provided by the Mapping Toolbox (YF 2023-01-04)
%  (1) vers_out < 2: R2020a and lower: load('coast') with "lon" and "lat"
%  (2) vers_out > 1: R2020b and higher: load('coastlines') with "coastlon" and "coastlat"
%
% (III) Using "imresize" instead of "resizem", which was removed in R2023b (YF 2023-08-16)
%       Please note that the results of these two functions are not always identical
%       For examples see https://github.com/michaelgrund/stacksplit/pull/13#issuecomment-1624974426
%       This issue was reported to and confirmed by the MATLAB Support
%  (1) vers_out < 3:  R2023a and lower: "resizem" is available
%  (2) vers_out == 3: R2023b and higher: "imresize" is used
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
% - v3.1 (2023): Yvonne Fröhlich, Karlsruhe Institute of Technology (KIT),
%                ORCID: 0000-0002-8566-0619
%                Email: yvonne.froehlich@kit.edu
%                Add queries (II) and (III) and adjust query (I)
%                Affected StackSplit functions are SS_check_input.m,
%                SS_disp_Esurf_single.m, SS_gen_worldmap.m, SS_stack_Esurf.m
%==========================================================================
%==========================================================================

vers = version('-release');
vers_yyyy = str2double(vers(1:4));
vers_char = vers(5);

% Do NOT change the oder of these queries!

%{
vers_out = 0

% (I) Applying the contourf function to create the energy maps
if (vers_yyyy==2014 && strcmp(vers_char,'b')) || vers_yyyy>2014  % R2014b and higher
   vers_out = 1;
end

% YF 2023-01-04
% (II) Using the coastlines provided by the Mapping Toolbox
if (vers_yyyy==2020 && strcmp(vers_char,'b')) || vers_yyyy>2020  % R2020b and higher
    vers_out = 2;
end

% YF 2023-08-16
% (III) Using "imresize" instead of "resizem"
if (vers_yyyy==2023 && strcmp(vers_char,'b')) || vers_yyyy>2023  % R2023b and higher
    vers_out = 3;
end
%}

vers_out = 0

% (I) Applying the contourf function to create the energy maps
if (vers_yyyy==2014 && strcmp(vers_char,'b')) || vers_yyyy>2014  % R2014b and higher
   vers_out = 1;

    % YF 2023-01-04
    % (II) Using the coastlines provided by the Mapping Toolbox
    if (vers_yyyy==2020 && strcmp(vers_char,'b')) || vers_yyyy>2020  % R2020b and higher
        vers_out = 2;

        % YF 2023-08-16
        % (III) Using "imresize" instead of "resizem"
        if (vers_yyyy==2023 && strcmp(vers_char,'b')) || vers_yyyy>2023  % R2023b and higher
            vers_out = 3;
        end

    end

end


%==========================================================================
%==========================================================================
% EOF
