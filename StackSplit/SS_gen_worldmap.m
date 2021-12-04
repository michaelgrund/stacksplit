function h=SS_gen_worldmap(h)
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
% generate worldmap that displays the station and currently selected events 
% from list 
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

%==========================================================================
% plot eq worldmap overview

% parameter from global variable config
thissta.slat=config.slat;
thissta.slong=config.slong;
SKSwin=config.eqwin;

% plot parameters
circleColor='k';
fontsize_eqwin=6;

%vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
% if mapping toolbox is available

if config.maptool==1

    fileparts(mfilename('fullpath'));
    coast_data = load('coast');        
    plates_data = load('SS_plates.mat');  

    % generate subplot and handles
    ax=subplot(1,1,1,'Parent',h.panel(1));
    set(ax,'Color',[224 223 227]./256, 'ButtonDownFcn', [], 'Position',[0.599 0.53 0.472 0.472])
    %imagesc(randn(100,100))
    axis off
    axes(ax)
    axm=axesm('eqdazim','origin',[thissta.slat,thissta.slong],'Frame','on','FLinewidth',1,'FFaceColor','w');
    set(axm, 'ButtonDownFcn', [])
    h.EQstatsax=ax;
    
    % plot plate boundaries & continents
    plotm(plates_data.PBlat, plates_data.PBlong, 'LineStyle','-','Linewidth',1,'Tag','Platebounds','Color',[1.2 1 1]*.8, 'ButtonDownFcn', '', 'HitTest', 'off')
    fillm(coast_data.lat,coast_data.long,'FaceColor',[1 1 1]*.65,'EdgeColor','none','Tag','Continents', 'ButtonDownFcn', '', 'HitTest', 'off');

    % plot circles at distance seletion wdw
    [latlow,lonlow]= scircle1(thissta.slat, thissta.slong, SKSwin(1));
    [latup,lonup]  = scircle1(thissta.slat, thissta.slong, SKSwin(2));
    plotm(latlow, lonlow, '--', 'Color',circleColor, 'linewidth',1, 'ButtonDownFcn', '', 'HitTest', 'off');%SKSwindow
    plotm(latup , lonup , '--', 'Color',circleColor, 'linewidth',1, 'ButtonDownFcn', '', 'HitTest', 'off');   
  
    wmin=[num2str(SKSwin(1)) '\circ'];
    wmax=[num2str(SKSwin(2)) '\circ'];

    textm(latup(50) ,lonup(50),wmax, 'verticalalignment','top','horizontalalignment',   'center', 'Color', circleColor,'fontsize',fontsize_eqwin, 'ButtonDownFcn', '', 'HitTest', 'off');
    textm(latlow(50),lonlow(50),wmin,'verticalalignment','Bottom','horizontalalignment','center', 'Color', circleColor,'fontsize',fontsize_eqwin, 'ButtonDownFcn', '', 'HitTest', 'off');

    % plot station marker    
    plotm(thissta.slat, thissta.slong,'k^','MarkerFaceColor','r','MarkerSize',8, 'ButtonDownFcn', '', 'HitTest', 'off');   

    %remove axis etc around plot
    framem('FLinewidth',1,'FFaceColor','w')
    axis off
    
%vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
% if no mapping toolbox is available, use map proposed by Rob Porritt for
% SL version 1.2.1
else
    
    % generate subplot and handles
    ax=subplot(1,1,1,'Parent',h.panel(1),'Position',[0.71 0.63 0.27 0.30]);
    axes(ax) 
    h.EQstatsax=ax;

    % check for files needed to construct "alternative" map
    if exist('SL_plates.mat', 'file') == 2 && exist('SL_coasts.mat', 'file') ==2 ...
             && exist('ETOPO1_Ice_g_gmt4_1deg.grd', 'file') ==2 && exist('ncread')

        % matlab structures included with this distribution
        coast_data = load('SL_coasts.mat');        
        plates_data = load('SL_plates.mat'); 

        % etopo from http://www.ngdc.noaa.gov/mgg/global/global.html
        topoElevation = ncread('ETOPO1_Ice_g_gmt4_1deg.grd','z');
        topoLatitude = ncread('ETOPO1_Ice_g_gmt4_1deg.grd','lat');  
        topoLongitude = ncread('ETOPO1_Ice_g_gmt4_1deg.grd','lon');   
        lon=repmat(topoLongitude,1,length(topoLatitude));  
        lat=repmat(topoLatitude,1,length(topoLongitude));
        contourf(lon,lat',topoElevation);

    else
        errordlg('To run StackSplit you need either the Mapping toolbox or SplitLab version >= 1.2.1!','Version issue')
        close(h.fig)
        h.quit=1;
        return
    end
    
    hold on
    
    colormap(gray);
    plot(plates_data.PBlong,plates_data.PBlat, 'LineStyle','-','Linewidth',1,'Tag','Platebounds','Color',[1.2 1 1]*.8);
    plot(coast_data.ncst(:,1),coast_data.ncst(:,2),'k');
    
    %station marker
    plot(config.slong, config.slat,'k^','MarkerFaceColor','r','MarkerSize',8);
    axis([-180 180 -90 90])
    ylabel('Latitude','fontsize',6);
    xlabel('Longitude','fontsize',6);
    set(gca,'fontsize',6)

end
    

end
%==================================================================================================================================
%================================================================================================================================== 
% EOF

