function SS_gen_stackresplot(h,min_bazi,max_bazi,min_dis,max_dis,mean_bazi,mean_dist,phi,dt)
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
% export final stacked surface to pdf, note for each saved measurement a
% corresponding diagnostic plot is saved 
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

global config

bazi_int=[min_bazi max_bazi];
dist_int=[min_dis max_dis];

%================================================================================
% check if figure already is opened
fig_ex=findobj('type','figure','name','StackSplit_stack_results');

if ~isempty(fig_ex)
    close(fig_ex)
   fig_out = figure('name','StackSplit_stack_results', 'numbertitle','off','menubar','none','units','normalized');
else
    fig_out = figure('name','StackSplit_stack_results', 'numbertitle','off','menubar','none','units','normalized');
end

set(fig_out,'visible','off')

%================================================================================
% SET diagnostic header

ax0=subplot(3,4,1:4);

str11 = sprintf('%4.0f <%4.0f <%4.0f',phi); % phi from stacked surface
str21 = sprintf('%3.1f < %3.1f s < %3.1f',dt); % dt from stacked surface

if h.surf_kind==1 
   surf_input='Minimum Energy';
elseif h.surf_kind==2
   surf_input='EV';
end

str ={['          \rmStation: \bf' config.stnname '\rm   Surface input: \bf' surf_input '\rm   Method: \bf' h.stacked_meth];
['\rmBackazimuth range: \bf' sprintf('%5.1f - %5.1f',bazi_int) ' (' sprintf('%5.1f',mean_bazi) ')\rm   Distance range: \bf' sprintf('%5.1f - %5.1f',dist_int) ' (' sprintf('%5.1f',mean_dist) ')' ];
'  ';
['\rm                  \phi: ' str11 '       \delta\itt\rm: ' str21]};

% In case the header of the exported STACK diagnostic plot does not look
% appealing to you, you can uncomment the lines below to try this
% arrangement or you adjust the header on your own.
%{
str ={['          \rmStation: \bf  '        config.stnname '       \rm    Surface input: \bf      ' surf_input ' \rm        Method: \bf      ' h.stacked_meth];
['\rmBackazimuth range: \bf   ' sprintf('%5.1f - %5.1f',bazi_int) ' (' sprintf('%5.1f',mean_bazi)   ') \rm           Distance range: \bf           ' sprintf('%5.1f - %5.1f',dist_int) ' (' sprintf('%5.1f',mean_dist) ')' ];
'  ';
['\rm                                   \phi: ' str11 '                                              \deltat: ' str21 ]};
%}

text(.05, 0.2, str, ...
    'HorizontalAlignment','left', ...
    'Tag','FigureHeader', ...
    'fontname','fixedwidth');

pos=get(ax0,'position');
set(ax0,'position',[pos(1) pos(2)-0.05 pos(3) pos(4)])
set(gca,'visible','off')

%================================================================================
% WORLD map

%get objects from worlmap plot
H2=findall(h.EQstatsax);
ax1=subplot(3,4,[5 6 9 10]);

if config.maptool==1

    copyobj(H2(2:end),ax1); 
    colormap(fig_out,'gray')

    axis square
    axis off

    findtext=findobj(gca,'type','text');
    set(findtext,'fontsize',10)
    pos=get(ax1,'position');
    set(ax1,'position',[pos(1)-0.02 pos(2)+0.05 pos(3) pos(4)])
else
    copyobj(H2([2 5:end]),ax1);
    axis off
    
    pos=get(ax1,'position');
    set(ax1,'position',[pos(1)-0.02 pos(2)+0.175 pos(3) pos(4)-0.25])
end  
    
%================================================================================
% STACKED surface

% get objects from Emap plot
H1=findall(h.axEmap);
ax2=subplot(3,4,[7 8 11 12]);
copyobj(H1(3:end),ax2); 
colormap(fig_out,'gray')

% set axes parameters again
% label = ['0' sprintf('|%u',1:config.maxSplitTime) 'sec'];
axis square
axis([0 config.maxSplitTime -90 90])
set(gca, 'Xtick',[0:1:config.maxSplitTime], 'XtickLabel',[0:1:config.maxSplitTime],'Ytick',[-90:30:90],'xMinorTick','on','yminorTick','on')
box on

pos=get(ax2,'position');
set(ax2,'position',[pos(1)-0.015 pos(2)+0.06 pos(3) pos(4)])

%================================================================================
% SET print parameters

set(gcf, 'PaperOrientation','landscape')
set(gcf, 'PaperType','A5');
papersize = get(gcf, 'PaperSize');

width=25;
height=25;

left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;

myfiguresize=[left-0.3, bottom+0.5, width, height];

set(gcf,'PaperPosition', myfiguresize);

%================================================================================
% SAVE FIGURES 
% change here, if you dont like the figure output (resolution etc)

switch config.exportformat
    case '.ai'
        option={ '-dill', '-noui'};
    case '.eps'
        option={ '-depsc2', '-cmyk',   '-r300', '-noui','-tiff', '-loose','-painters'};
    case '.fig'
        option={};
    case '.jpg'
        option={ '-djpeg', '-r300', '-noui', '-painters'};
    case '.pdf'
        option={ '-dpdf',  '-noui', '-cmyk', '-painters'};
    case '.png'
        option={ '-dpng', '-r300', '-noui',  '-painters'};
    case '.ps'
        option={ '-dps2',   '-adobecset','-r300', '-noui','-loose', '-painters'};
    case '.tiff'
        option={ '-dtiff', '-r150', '-noui'};
end

fname = sprintf(['Multi_result_STACK', config.exportformat]);

%check if file alredy exists 
No=2;
while exist(fullfile(config.savedir, fname),'file') == 2
    fname = sprintf('Multi_result_STACK[%.0f]%s',...
            No, config.exportformat);
    No = No+1;
end

print(fig_out, option{:}, fullfile(config.savedir,fname));

close(fig_out)

%================================================================================
% EOF