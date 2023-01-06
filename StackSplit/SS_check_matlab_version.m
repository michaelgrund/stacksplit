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
% (I) Applying the contourf function to create the energy maps
%  (1) vers_out==0: versions R2014a and lower: -v6 flag is necessary
%  (2) vers_out==1: versions R2014b and higher: -v6 flag not supported anymore
%
% (II) Using the coastlines of the Mapping Toolbox
%  (1) vers_out==0: versions R2020a and lower: load('coast') with "lon" and "lat"
%  (2) vers_out==2: versions R2020b and higher: load('coastlines.mat') with "coastlon" and "coastlat"
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

vers=version('-release');

vers_yyyy=str2double(vers(1:4));
vers_let=vers(5);

if vers_yyyy > 2014 || (vers_yyyy == 2014 && strcmp(vers_let,'b')) % MATLAB R2014b and higher
   vers_out=1;
else
    vers_out=0;
end

if vers_yyyy > 2020 || (vers_yyyy == 2020 && strcmp(vers_let,'b')) % MATLAB R2020b and higher (added 2023/01/04 YF)
    vers_out = 2;
end

%==================================================================================================================================
%==================================================================================================================================
% EOF