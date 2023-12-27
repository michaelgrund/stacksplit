function [wf, countN] = SS_calc_RH(SNR, bazi_single, bazi_all, ~)
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
% Calculate
%   1) weighting factors for a specific SNR
%   2) normalization factors depending on BAZ distribution
% following the definition of Restivo & Helffrich (1999)
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
%##########################################################################
% WEIGHTING FUNCTION
%
% The applied weighting function is a modified sigmoid function
%
% see e.g.
%
% von Seggern, D.H. (2006), CRC Standard Curves and Surfaces with Mathematica,
%       Second Edition. Chapman and Hall/CRC, Boca Raton, FL, USA
%
%
% DEFAULT weighting function (Xmean=10, Xstd=2) with inflection point at SNR=10
% corresponding to Restivo & Helffrich (1999). If you want to modify the weighting,
% adjust the factors for Xmean ("moving" the curve along x-axis) and Xstd
% (adjusts "steepness of linear part")

Xmean=10;
Xstd=2;

wf=1./(1+exp(-((SNR-Xmean)/Xstd)));

% %%
% % uncomment following lines to plot weighting function
%
% figure(10)
%
% test_SNR=0:25;
% wf2plot=1./(1+exp(-((test_SNR-Xmean)/Xstd)));
% plot(test_SNR,wf2plot)
% xlabel('SNR')
% ylabel('weighting factor')
% axes(h.axEmap)
%
% %%

%##########################################################################
% NORMALIZATION depending on BAZ

                                                    %   N ^    (- hw)
% angle defining the wedge size for the RH method         |   .       * BAZ
halfwedge=10;  % DEFAULT: +- 10° from BAZ           %     |  .      *
                                                    %     | .    *
                                                    %     |.  *
                                                    %     |* . . . . (+ hw)

                                                    % !!! not in correct scale !!!

% calc wedge with BAZ+-10° for each single BAZ
bazi_wedge=[bazi_single-halfwedge;bazi_single+halfwedge]';

% check and convert correctly for wedges containing BAZs smaller or larger
% the true north direction (0°)
index_low=[bazi_wedge(:,1)] < 0;
index_high=[bazi_wedge(:,2)] > 360;
[bazi_wedge(index_low==1,1)]=360-abs([bazi_wedge(index_low==1,1)]);
[bazi_wedge(index_high==1,2)]=[bazi_wedge(index_high==1,2)]-360;

% count how many events fall in the defined BAZ wedges
if bazi_wedge(1) < bazi_wedge(2)
    countN=length(find(bazi_all > bazi_wedge(1) & bazi_all < bazi_wedge(2)));
else
    countN=length(find(bazi_all > bazi_wedge(1)))+length(find(bazi_all < bazi_wedge(2)));
end

%##########################################################################
% EOF