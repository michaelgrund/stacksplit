function h=SS_stack_Esurf(h)
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
% stack single error surfaces (minimum energy, EV) depending on the
% selected approaches (for details, see the corresponding papers):
%
% 1) no weighting (e.g. Wüstefeld, 2007; PhD thesis): true "topography" of
%       each surface is considered
% 2) Wolfe & Silver (1998) procedure: each single surface is normalized to
%       its overall minimum/maximum value before stacking
% 3) Restivo & Helffrich (1999) procedure: modified WS approach, each single 
%       surface is weighted based on the corresponding SNR and additionally 
%       scaled to a factor of 1/N, with its great-circle direction (BAZ) 
%       defining a wedge of +-10° in which N observations fall
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

index=get(h.list,'value');

use_data=h.data(index);
                                          
%======================================================
%############################################################################################
% check if more than one phase per event is selected by comparing the
% source times of the selected entries
datevecs=vertcat(use_data.date);
checkmulti=unique(datenum(datevecs(:,1:6)));

if length(checkmulti)~=length(index) 
    
    % disp dialog if stacking procedure should be continued or aborted
    ask4multi=questdlg('Your selection contains different phases/filters of the same event! Continue?',...
        'Multiple result selection','No','Yes','No');

    if strcmp(ask4multi,'No') % set all buttons/panels to visible off since stacking is aborted 
        set(h.push(1),'enable','off');   % STACK button
        set(h.push(2),'enable','off');   % CLEAR button
        set(h.push(3),'enable','off');   % SAVE button
        set(h.panel(2),'visible','off'); % Energymap panel
        set(h.panel(3),'visible','off'); % results panel

            % remove blue dots on worldmap when no option is selected       
            find_bluedot=findobj(h.EQstatsax,'type','line');
    
            if length(find_bluedot) > 4    
                set(find_bluedot(1:end-4),'Visible','off')
                delete(find_bluedot(1)) 
            end

        return
        
    else % although more than one result per event,
        % stacking continues and CLEAR & SAVE buttons are set to on
        set(h.panel(2),'visible','on'); 
        set(h.panel(3),'visible','on'); 
        set(h.push(2),'enable','on');
        set(h.push(3),'enable','on');
    end
    
else % if not more than one result per event, DEFAULT case
        set(h.panel(2),'visible','on');
        set(h.panel(3),'visible','on'); 
        set(h.push(2),'enable','on');
        set(h.push(3),'enable','on');
end

%############################################################################################
% check if non-nulls and nulls are selected for stacking together => not
% reasonable 

for ii=1:length(use_data)
    restype{ii}=use_data(ii).results.Null;
end

restype=restype(~cellfun(@isempty, restype));
checkmulti2=unique(restype);

if length(checkmulti2)~=1 
    
    % disp dialog if stacking procedure should be continued or aborted
    ask4multi2=questdlg('Your selection contains Splits and Nulls! Mixing both types is not reasonable! Continue?',...
        'Multiple result selection','No','Yes','No');

    if strcmp(ask4multi2,'No') % set all buttons/panels to visible off since stacking is aborted 
        set(h.push(1),'enable','off');   % STACK button
        set(h.push(2),'enable','off');   % CLEAR button
        set(h.push(3),'enable','off');   % SAVE button
        set(h.panel(2),'visible','off'); % Energymap panel
        set(h.panel(3),'visible','off'); % results panel

            % remove blue dots on worldmap when no option is selected       
            find_bluedot=findobj(h.EQstatsax,'type','line');
    
            if length(find_bluedot) > 4    
                set(find_bluedot(1:end-4),'Visible','off')
                delete(find_bluedot(1)) 
            end

        return
        
    else % although more than one result per event,
        % stacking continues and CLEAR & SAVE buttons are set to on
        set(h.panel(2),'visible','on'); 
        set(h.panel(3),'visible','on'); 
        set(h.push(2),'enable','on');
        set(h.push(3),'enable','on');
    end
    
else % if not more than one result per event, DEFAULT case
        set(h.panel(2),'visible','on');
        set(h.panel(3),'visible','on'); 
        set(h.push(2),'enable','on');
        set(h.push(3),'enable','on');
end

%############################################################################################
% maximum diff of used bazis, diss, and inipols

use_bazi=[use_data.bazi];
use_dis=[use_data.dis];

for ii=1:length(use_data)
    use_inipol(ii)=use_data(ii).results.inipol;
end

diffbazi=abs(max(use_bazi)-min(use_bazi));
diffdist=abs(max(use_dis)-min(use_dis));
diffinipol=abs(max(use_inipol)-min(use_inipol));

if ~ischar(config.SS_maxbaz)
    if diffbazi > config.SS_maxbaz && ~strcmp(config.SS_maxbaz,'none')
        h.warn_diffbazi=warndlg({['BAZ difference (' num2str(diffbazi,'%2.1f') '°) exceeds'],...
            ;['    selected maximum (' num2str(config.SS_maxbaz) '°)!']},'BAZ difference');
    
        set(h.push(2),'enable','off');
        set(h.push(3),'enable','off');
        return
    end
end

if ~ischar(config.SS_maxdist)
    if diffdist > config.SS_maxdist && ~strcmp(config.SS_maxdist,'none')
        h.warn_diffdist=warndlg({['Dist difference (' num2str(diffdist,'%2.1f') '°) exceeds'],...
            ;['     selected maximum (' num2str(config.SS_maxdist) '°)!']},'Dist difference');
    
        set(h.push(2),'enable','off');
        set(h.push(3),'enable','off');
        return
    end
end

if ~ischar(config.SS_maxpol)
    if diffinipol > config.SS_maxpol && ~strcmp(config.SS_maxpol,'none')
        h.warn_diffinipol=warndlg({['Inipol difference (' num2str(diffinipol,'%2.1f') '°) exceeds'],...
            ;['     selected maximum (' num2str(config.SS_maxpol) '°)!']},'Inipol difference');
    
        set(h.push(2),'enable','off');
        set(h.push(3),'enable','off');
        return
    end
end

%############################################################################################
%======================================================
% use Emap axes 
axes(h.axEmap)

% clear axes before stacked surface is displayed
cla reset
box on

%======================================================
% visualization parameters

maxtime=h.EMAP_maxtime; % maximum time displayed in grid
sampling=h.EMAP_sampling; % sampling rate of input wavelets in seconds
f=h.EMAP_f; % accuracy factor

%======================================================
% test coordinate systems for single and stacked error surfaces
%-------------------------
% original setup

phi_test = ((-90:1*f:90))/180*pi;
phi_test = phi_test(1:end-1);
dt_test  = fix(0:f*1:maxtime/sampling); % test delay times (in samples)

%======================================================
% sum all single error surfaces/energy surfaces

% allocate stacked error surface with size of phi_test x dt_test
STACKsurf=zeros(length(phi_test),length(dt_test)); 
% allocate sum of the degrees of freedom of each single measurement
sum_ndf=0;                                     

%############################################################################################
if length(use_data) > 1 % more than 1 selection

    %=======================================================
    % which kind of weighting
    check_stack=get(h.h_checkbox,'Value');
    
    checks{1}='STACK surfaces (no weight)';
    checks{2}='STACK surfaces (WS method)';
    checks{3}='STACK surfaces (RH method)';

    disp(' ')
    disp('==========================')
    disp(checks{cell2mat(check_stack)~=0})
    disp('==========================')

    % BEGIN OF STACKING LOOP
    for ii=1:length(use_data)
        %_______________________________________________________________________
        % standard stacking without weighting, the relative topography of
        % each measurement is considered, (see e.g. Wüstefeld, 2007; PhD
        % thesis)
        if check_stack{1}==1

            if h.surf_kind==1 % energy surface

                STACKsurf=STACKsurf+use_data(ii).results.Ematrix;
                sum_ndf=sum_ndf+use_data(ii).results.ndfSC;
                
            elseif h.surf_kind==2 % EV surface
                
                STACKsurf=STACKsurf+use_data(ii).results.EVmatrix;
                sum_ndf=sum_ndf+use_data(ii).results.ndfEV;

            end
            
            stack_meth='nw';
         %_______________________________________________________________________
         % WS, each single error surface is normalized on its minimum/maximum before stacking
        elseif check_stack{2}==1

            if h.surf_kind==1 % energy surface
                
                STACKsurf=STACKsurf+use_data(ii).results.Ematrix./min(min(use_data(ii).results.Ematrix));
                sum_ndf=sum_ndf+use_data(ii).results.ndfSC;

            elseif h.surf_kind==2 % EV surface
              
                % depending on EV input, normalized on minimum or maximum
                switch config.splitoption
                    case 'Minimum Energy' % minimum normalization;
                                          % if Minimum Energy is the "splitoption",
                                          % then automatically min(lambda2)
                                          % is the corresponding EV method
                                          % (see splitSilverChan.m)
                        STACKsurf=STACKsurf+use_data(ii).results.EVmatrix./min(min(use_data(ii).results.EVmatrix));
                        sum_ndf=sum_ndf+use_data(ii).results.ndfEV;             
                    case 'Eigenvalue: min(lambda2)' % minimum normalization
                        STACKsurf=STACKsurf+use_data(ii).results.EVmatrix./min(min(use_data(ii).results.EVmatrix));
                        sum_ndf=sum_ndf+use_data(ii).results.ndfEV;
                    case 'Eigenvalue: min(lambda1 * lambda2)' % minimum normalization
                        STACKsurf=STACKsurf+use_data(ii).results.EVmatrix./min(min(use_data(ii).results.EVmatrix));
                        sum_ndf=sum_ndf+use_data(ii).results.ndfEV;
                    case 'Eigenvalue: max(lambda1 / lambda2)' % maximum normalization
                        STACKsurf=STACKsurf+use_data(ii).results.EVmatrix./max(max(use_data(ii).results.EVmatrix));
                        sum_ndf=sum_ndf+use_data(ii).results.ndfEV;
                    case 'Eigenvalue: max(lambda1)' % maximum normalization
                        STACKsurf=STACKsurf+use_data(ii).results.EVmatrix./max(max(use_data(ii).results.EVmatrix));
                        sum_ndf=sum_ndf+use_data(ii).results.ndfEV;
                end
            end
            
            stack_meth='WS';
        %_______________________________________________________________________
        % RH, each single (normalized) error surface is weighted based on the SNR of the
        % corresponding single event before stacking and scaled on BAZ rate
        elseif check_stack{3}==1

                curr_SNR=use_data(ii).results.SNR(2); % use SNR_SC => SNR(2)
                [wf,countN]=SS_calc_RH(curr_SNR,use_bazi(ii),use_bazi,h);

            if h.surf_kind==1 % energy surface

                STACKsurf=STACKsurf+((use_data(ii).results.Ematrix./...
                    min(min(use_data(ii).results.Ematrix)))./countN).*wf;
                sum_ndf=sum_ndf+use_data(ii).results.ndfSC;
                
            elseif h.surf_kind==2 % EV surface
                
                % depending on EV input, normalized on minimum or maximum
                switch config.splitoption
                    
                    case 'Minimum Energy' % minimum normalization;
                                          % if Minimum Energy is the "splitoption",
                                          % then automatically min(lambda2)
                                          % is the corresponding EV method
                                          % (see splitSilverChan.m)
                        STACKsurf=STACKsurf+((use_data(ii).results.EVmatrix./...
                            min(min(use_data(ii).results.EVmatrix)))./countN).*wf;
                        sum_ndf=sum_ndf+use_data(ii).results.ndfEV;
                    case 'Eigenvalue: min(lambda2)' % minimum normalization
                        STACKsurf=STACKsurf+((use_data(ii).results.EVmatrix./...
                            min(min(use_data(ii).results.EVmatrix)))./countN).*wf;
                        sum_ndf=sum_ndf+use_data(ii).results.ndfEV;
                    case 'Eigenvalue: min(lambda1 * lambda2)' % minimum normalization
                        STACKsurf=STACKsurf+((use_data(ii).results.EVmatrix./...
                            min(min(use_data(ii).results.EVmatrix)))./countN).*wf;
                        sum_ndf=sum_ndf+use_data(ii).results.ndfEV;
                    case 'Eigenvalue: max(lambda1 / lambda2)' % maximum normalization
                        STACKsurf=STACKsurf+((use_data(ii).results.EVmatrix./...
                            max(max(use_data(ii).results.EVmatrix)))./countN).*wf;
                        sum_ndf=sum_ndf+use_data(ii).results.ndfEV;
                    case 'Eigenvalue: max(lambda1)' % maximum normalization
                        STACKsurf=STACKsurf+((use_data(ii).results.EVmatrix./...
                            max(max(use_data(ii).results.EVmatrix)))./countN).*wf;
                        sum_ndf=sum_ndf+use_data(ii).results.ndfEV;
                end
            end
            
            stack_meth='RH';
            
        end
       
        %=======================================================
    end
    % END OF STACKING LOOP

end
%############################################################################################
%======================================================
% find minimum or maximum of stacked error surface (depending on input of ME and EV)
 
if h.surf_kind==1 % Minimum Energy
    
    [indexPhi,indexDt]   = find(STACKsurf==min(STACKsurf(:)), 1);
   
elseif h.surf_kind==2 % EV surface
    
    switch config.splitoption
        
        case 'Minimum Energy' % search abs min;
                              % if Minimum Energy is the "splitoption",
                              % then automatically min(lambda2)
                              % is the corresponding EV method
                              % (see splitSilverChan.m)
            [indexPhi,indexDt]   = find(STACKsurf==min(STACKsurf(:)), 1);      
        case 'Eigenvalue: min(lambda2)' % search abs min
            [indexPhi,indexDt]   = find(STACKsurf==min(STACKsurf(:)), 1);
        case 'Eigenvalue: min(lambda1 * lambda2)' % search abs min
            [indexPhi,indexDt]   = find(STACKsurf==min(STACKsurf(:)), 1);
        case 'Eigenvalue: max(lambda1 / lambda2)' % search abs max
            [indexPhi,indexDt]   = find(STACKsurf==max(STACKsurf(:)), 1);
        case 'Eigenvalue: max(lambda1)' % search abs max
            [indexPhi,indexDt]   = find(STACKsurf==max(STACKsurf(:)), 1);       
    end
end

%======================================================
% absolute Value in stacked_err_surf, corresponding to the best
% inversion (e.g. for the SC method min(Energy map))
Eresult(1) = STACKsurf(indexPhi, indexDt, 1); 
   
%======================================================
% calculate errors for stacked surface
[errbar_phi,errbar_t,MAPlevel]=SS_geterrorbars_stack_Esurf(Eresult,sum_ndf,STACKsurf);  

%======================================================
% find corresponding phi and dt value from absolute minimum/maximum of
% stacked error surface
phi_test_ext = (phi_test(indexPhi)/ pi * 180);   % fast axis in Q-T-system
%phiSC  = mod((phi_test_ext+bazi_in), 180);      % fast axis in E-N-system
phiSTACK  = phi_test_ext;

shift  = dt_test(indexDt); % samples
dtSTACK   = shift * sampling; % seconds

if phiSTACK>90
    phiSTACK = phiSTACK-180; % input [-90:90]
end

singlephiSTACK=phiSTACK;
singledtSTACK=dtSTACK;

singlephiSTACK = [errbar_phi(1)  singlephiSTACK   errbar_phi(2)];
singledtSTACK = [errbar_t(1)  singledtSTACK   errbar_t(2)];

%======================================================
% plot stuff

hold on
f  = size(STACKsurf);
ts = linspace(0,maxtime,f(2));
ps = linspace(-90,90,f(1));

maxi = max(abs(STACKsurf(:)));
mini = min(abs(STACKsurf(:)));
nb_contours = floor((1 - mini/maxi)*10);
      
version=SS_check_matlab_version(); % MATLAB 2014b or higher?
 
if version==1   
    [~, hcon] = contourf(ts,ps,-STACKsurf,-[MAPlevel MAPlevel]);
else
    [~, hcon] = contourf('v6',ts,ps,-STACKsurf,-[MAPlevel MAPlevel]);   
end

contour(ts, ps, STACKsurf, nb_contours);

set(hcon,'FaceColor',[1 1 1]*.90,'EdgeColor','k','linestyle','-','linewidth',1)

% horizontal line plotted twice for sake of safety
line([0 maxtime], [singlephiSTACK(2) singlephiSTACK(2)], 'Color',[0 0 1])
line([0 maxtime], [singlephiSTACK(2) singlephiSTACK(2)], 'Color',[0 0 1])
% vertical line plotted twice to be also visible in exported diagnostic plot
line([singledtSTACK(2) singledtSTACK(2)], [-90 90], 'Color',[0 0 1]) 
line([singledtSTACK(2) singledtSTACK(2)], [-90 90], 'Color',[0 0 1])

colormap(gray)

[~,~]=find(abs(STACKsurf)==min(abs(STACKsurf(:))));

fontsize=10;

hold off
axis([0 maxtime -90 90])
set(gca, 'Xtick',0:1:maxtime, 'Ytick',-90:30:90, ...
    'XtickLabel',0:1:maxtime, 'xMinorTick','on', 'yminorTick','on')
xlabel('delay time \delta\itt\rm in s', 'Fontsize', fontsize) 
ylabel('fast axis \phi in \circ', 'Fontsize', fontsize)
title(['Stacked surfaces: ' num2str(length(use_data))],'fontsize',11)
    
string1 = char( strcat({'fast: '}, char(num2str(singlephiSTACK(1),'%4.0f')), {'° < '}, ... 
								   char(num2str(singlephiSTACK(2),'%4.0f')), {'° < '}, ...
								   char(num2str(singlephiSTACK(3),'%4.0f')), {'°'}) );
string2 = [string1 newline char(strcat({'dt:   '}, char(num2str(singledtSTACK(1),'%3.1f')), {' s < '}, ...
												   char(num2str(singledtSTACK(2),'%3.1f')), {' s < '}, ...
												   char(num2str(singledtSTACK(3),'%3.1f')), {' s'}))];

uicontrol(h.panel(3),'Style','text', 'String',string2,'Position',[0.05,0.05,170,40], 'BackgroundColor', 'w','Fontsize',10);

%======================================================
% save results to handle
h.stacked_err_surf=STACKsurf;
h.stacked_err_surf_ndf=sum_ndf;
h.stacked_err_surf_phi=singlephiSTACK;
h.stacked_err_surf_dt=singledtSTACK;
h.stacked_err_surf_level=MAPlevel;
h.stacked_nsurf=length(use_data); % number of stacked surfaces
h.stacked_meth=stack_meth;
h.stacked_bazis=use_bazi;
h.stacked_dists=use_dis;

%############################################################################################
%############################################################################################
% EOF
