function SS_splitdiagnosticSetHeader(axH, phiRC, dtRC, phiSC, dtSC, phiEV, dtEV,pol,  splitoption, bazi_int, dist_int)
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
% set header for diagnostic plot of SIMW analysis, this function is a modified
% SplitLab function
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

global thiseq config

axes(axH);
str11 = sprintf(['%4.0f<%4.0f\\circ <%4.0f']   ,phiRC);
str21 = sprintf('%3.1f<%3.1fs<%3.1f'           ,dtRC);
str12 = sprintf(['%4.0f<%4.0f\\circ <%4.0f']   ,phiSC);
str22 = sprintf('%3.1f<%3.1fs<%3.1f'           ,dtSC);
str13 = sprintf(['%4.0f<%4.0f\\circ <%4.0f']   ,phiEV);
str23 = sprintf('%3.1f<%3.1fs<%3.1f'           ,dtEV);

%% 

switch splitoption 
    case 'Minimum Energy'
       optionstr ='      Minimum Energy';
    case 'Eigenvalue: max(lambda1)'
       optionstr ='             max(\lambda1)';
    case 'Eigenvalue: max(lambda1 / lambda2)'
       optionstr ='        max(\lambda1 / \lambda2)';
    case 'Eigenvalue: min(lambda2)'
       optionstr ='             min(\lambda2)  ';
    case 'Eigenvalue: min(lambda1 * lambda2)'
       optionstr ='        min(\lambda1 * \lambda2)';
end

%%



str ={['\rm                     Station: \bf' config.stnname ''];
    ['\rmBackazimuth: \bf' sprintf(['%5.1f'  '\\circ - %5.1f'  '\\circ'],bazi_int) '   \rmDistance: \bf' sprintf(['%5.1f'  '\\circ - %5.1f'  '\\circ'],dist_int) ];
    [''];
    ['\rmRotation Correlation: ' str11 '     ' str21 ];
    ['\rm      Minimum Energy: ' str12 '     ' str22 ];
    ['\rm          Eigenvalue: ' str13 '     ' str23 ];
    ['             \rmQuality: \bf ?       \rm     IsNull: \bf ? \rm ']};

%%% without worldmap
% text(.6, .5,str,...
%     'HorizontalAlignment','left',...
%     'Tag','FigureHeader',...
%     'fontname','fixedwidth');

text(.22, .5,str,...
    'HorizontalAlignment','left',...
    'Tag','FigureHeader',...
    'fontname','fixedwidth');

