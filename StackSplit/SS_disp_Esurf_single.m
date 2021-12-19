function h=SS_disp_Esurf_single(h,index)
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
% plot corresponding energy/EV surface of selected event from list
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

global config

maxtime=h.EMAP_maxtime; % maximum time displayed in grid
find_res=h.data;

%=================================================================================
if length(index)==1

    cla reset

    if h.surf_kind==1 % energy surface
        
        set(h.panel(2),'title','Minimum energy surface')

        surf2plot=find_res(index).results.Ematrix;
        
        singlephi=find_res(index).results.phiSC;
        singledt=find_res(index).results.dtSC;

        Level=find_res(index).results.LevelSC;
        
    elseif h.surf_kind==2 % EV surface
        
        
        %#######################################
        % check for EV input 
        switch config.splitoption

        case 'Minimum Energy'
            % using min(lambda2) as default EV method when ME is set, see SL function
            % splitSilverChan
            set(h.panel(2),'title',['EV surface min(' char(hex2dec('03BB')) '2)'])
            
        case 'Eigenvalue: max(lambda1 / lambda2)'
            
            set(h.panel(2),'title',['EV surface max(' char(hex2dec('03BB')) '1/' char(hex2dec('03BB')) '2)'])
        
        case 'Eigenvalue: min(lambda2)'

            set(h.panel(2),'title',['EV surface min(' char(hex2dec('03BB')) '2)'])

        case 'Eigenvalue: max(lambda1)'

            set(h.panel(2),'title',['EV surface max(' char(hex2dec('03BB')) '1)'])

        case 'Eigenvalue: min(lambda1 * lambda2)'

            set(h.panel(2),'title',['EV surface min(' char(hex2dec('03BB')) '1 * ' char(hex2dec('03BB')) '2)'])
            
        end

        %#######################################
        
        surf2plot=find_res(index).results.EVmatrix;
        
        singlephi=find_res(index).results.phiEV;
        singledt=find_res(index).results.dtEV;

        Level=find_res(index).results.LevelEV;

    end

    
    hold on
    f  = size(surf2plot);
    ts = linspace(0,maxtime,f(2));
    ps = linspace(-90,90,f(1));

    maxi = max(abs(surf2plot(:)));
    mini = min(abs(surf2plot(:)));
    nb_contours = floor((1 - mini/maxi)*10);

    version=SS_check_matlab_version(); % MATLAB 2014b or higher?
    
    if version==1 
        [~, hcon] = contourf(ts,ps,-surf2plot,-[Level Level]);
    else
        [~, hcon] = contourf('v6',ts,ps,-surf2plot,-[Level Level]);
    end

    contour(ts, ps, surf2plot, nb_contours);

    set(hcon,'FaceColor',[1 1 1]*.90,'EdgeColor','k','linestyle','-','linewidth',1)

    line([0 maxtime], [singlephi(2) singlephi(2)],'Color',[0 0 1])
    line([singledt(2) singledt(2)],[-90 90],'Color',[0 0 1])

    colormap(gray)
    fontsize=10;

    hold off
    axis([0 maxtime -90 90])
    set(gca, 'Xtick',0:1:maxtime, 'XtickLabel', [0:1:maxtime] ,'Ytick',[-90:30:90],'xMinorTick','on','yminorTick','on')
    xlabel('delay time \delta\itt\rm in s', 'Fontsize', fontsize)
    ylabel('fast axis \phi in \circ', 'Fontsize',fontsize)
    
    box on
    set(gca,'layer','top')

    % disp result in white box
	string1 = char( strcat({'fast: '}, char(num2str(singlephi(1),'%4.0f')), {'° < '}, ...
									   char(num2str(singlephi(2),'%4.0f')), {'° < '}, ...
									   char(num2str(singlephi(3),'%4.0f')), {'°'}) ); 
	string2 = [string1 newline char(strcat({'dt: '}, char(num2str(singledt(1),'%3.1f')), {' s < '}, ...
												     char(num2str(singledt(2),'%3.1f')), {' s < '}, ....
													 char(num2str(singledt(3),'%3.1f')), {' s'}))];

    uicontrol(h.panel(3),'Style','text', 'String',string2,'Position',[0.05,0.05,170,40], 'BackgroundColor', 'w','Fontsize',10);

    % plot current event location
    axes(h.EQstatsax)

    evlat=h.data(index).lat;
    evlon=h.data(index).long;

    find_bluedot=findobj(h.EQstatsax,'type','line');

    if config.maptool==1 % if mapping toolbox available
    
        % the first four values in the handle find_bluedot are used for plateboundaries, SKS wdw lines etc.
        % if a fifth value is available a blue dot was set on the map to
        % show the current EQ location that is now removed before the new
        % one is set
        if length(find_bluedot) > 4 
            set(find_bluedot(1),'Visible','off')
            delete(find_bluedot(1))
        end

        plotm(evlat, evlon,'ko','MarkerFaceColor','b','MarkerSize',8, 'ButtonDownFcn', '', 'HitTest', 'off'); 

    else % if no mapping toolbox available

        % here the fourth value corresponds to the blue dot
    
        if length(find_bluedot) > 3
            set(find_bluedot(1),'Visible','off')
            delete(find_bluedot(1))
        end

        plot(evlon,evlat,'ko','MarkerFaceColor','c','MarkerSize',8);
    
    end

%=================================================================================
% if selection is > 1 stacking should be applied and stack button should
% become visible

elseif length(index) > 1

    set(h.push(1),'enable','on');

    % plot current event location
    axes(h.EQstatsax)

    evlat=[h.data(index).lat];
    evlon=[h.data(index).long];

    find_bluedot=findobj(h.EQstatsax,'type','line');
    
    
    if config.maptool==1 % if mapping toolbox available

        if length(find_bluedot) > 4
            set(find_bluedot(1),'Visible','off')
            delete(find_bluedot(1))
        end

        plotm(evlat, evlon,'ko','MarkerFaceColor','b','MarkerSize',8, 'ButtonDownFcn', '', 'HitTest', 'off'); 

    else % if no mapping toolbox available

        if length(find_bluedot) > 3
            set(find_bluedot(1),'Visible','off')
            delete(find_bluedot(1))
        end

        plot(evlon,evlat,'ko','MarkerFaceColor','c','MarkerSize',8);

    end
 
end

%=================================================================================
%=================================================================================
% EOF
