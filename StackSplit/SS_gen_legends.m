function h = SS_gen_legends(h)
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
% Generate legends to display qualities of single measurements, separate
% for nulls and splits
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
% GENERATE axes

hax1=axes('Parent',h.panel(1),'Units','pixel',...
                             'Position',[200 417+45 92 82]);
hax2=axes('Parent',h.panel(1),'Units','pixel',...
                             'Position',[450 417+45 92 82]);

%=================================================================================
%=================================================================================
% SET font parameters

lwleg=2;

col_good_nn=[8,138,41]./256;
col_fair_nn=[0,0,0];
col_poor_nn=[180,4,4]./256;
col_good_null=[0,64,255]./256;
col_fair_null=[137,4,177]./256;
col_poor_null=[110,110,110]./256;

%=================================================================================
%=================================================================================
% LEGEND for SPLITS

marker_size=6;

axes(hax1);

hold all
plot(-10,-100,'^','color',col_good_nn,'linewidth',lwleg,'markerfacecolor',col_good_nn,...
    'visible','off','markersize',marker_size)
plot(-10,-10,'^','color',col_fair_nn,'linewidth',lwleg,'markerfacecolor',col_fair_nn,...
    'visible','off','markersize',marker_size)
plot(-10,-10,'^','color',col_poor_nn,'linewidth',lwleg,'markerfacecolor',col_poor_nn,...
    'visible','off','markersize',marker_size)

legsplit=legend('\color{black} good','\color{black} fair','\color{black} poor','hittest','off','orientation','horizontal');
set(legsplit,'ButtonDownFcn',[])

set(hax1,'Visible','off')

titsplit = get(legsplit,'title');
set(titsplit,'string','Splits');
legend boxoff

%=====================================================================
% LEGEND for NULLS

axes(hax2);

hold all
plot(-10,-10,'v','color',col_good_null,'linewidth',lwleg,'markerfacecolor',col_good_null,...
    'visible','off','markersize',marker_size)
plot(-10,-10,'v','color',col_fair_null,'linewidth',lwleg,'markerfacecolor',col_fair_null,...
    'visible','off','markersize',marker_size)
plot(-10,-10,'v','color',col_poor_null,'linewidth',lwleg,'markerfacecolor',col_poor_null,...
    'visible','off','markersize',marker_size)

legnulls=legend('\color{black} good','\color{black} fair','\color{black} poor','hittest','off','orientation','horizontal');
set(legnulls,'ButtonDownFcn',[])

set(hax2,'Visible','off')

titnull = get(legnulls,'title');
set(titnull,'string','Nulls');

legend boxoff
end
%=================================================================================
%=================================================================================
% EOF