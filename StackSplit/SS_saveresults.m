function h=SS_saveresults(h)
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
% write results of stacked error surfaces/SIMW to textfile, generate mat-file
%
%==========================================================================
% LICENSE
%
% Copyright (C) 2016  Michael Grund, Karlsruhe Institute of Technology (KIT), 
% Email: michael.grund@kit.edu
%
% 2019-04 -MG- saving output also in GMT-ready format (psxy with -SJ flag)
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
global config SIMW_temp eqstack

staname=config.stnname;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SAVE results of stacked surfaces
if exist('h','var') && sum([h.check(1).Value h.check(2).Value h.check(3).Value])~=0

    stacked_err_surf=h.stacked_err_surf;
    phistack=h.stacked_err_surf_phi;
    dtstack=h.stacked_err_surf_dt;
    level=h.stacked_err_surf_level;
    nsurf=h.stacked_nsurf;
    stack_meth=h.stacked_meth;   
    ndf=h.stacked_err_surf_ndf;
    bazis=h.stacked_bazis;
    dists=h.stacked_dists;   

    max_bazi=max(bazis);
    min_bazi=min(bazis);
    max_dis=max(dists);
    min_dis=min(dists);  

    % check if a remark was added to the current result
    if ~isempty(h.stacked_remark)
        res_remark=h.stacked_remark{1:end};
        outtext=1;
    else
        res_remark=[];
        outtext=2;
    end

    %==========================================================================
    % txt-file
    
    %....................................
    % generate yyyy.JD (phase) for txt file to show which single events/phases
    % were used for stacking
    index=get(h.list,'value'); 
    ev_used=h.data(index);
    datesall=vertcat(ev_used.date);
    yyyyJDs=[datesall(:,1) datesall(:,7)];
    
    string_ev_used=[];
    for ii=1:length(ev_used)
      phase_used=ev_used(ii).results.SplitPhase;
      string_ev_used=horzcat(string_ev_used,[num2str(yyyyJDs(ii,1)) '.' num2str(yyyyJDs(ii,2)) ' (' phase_used ')   ']);
    end
    %....................................

    fname = fullfile(config.savedir,['splitresultsSTACK_' config.project(1:end-4) '.txt' ]);

    xst   = exist(fname);
    fid   = fopen(fname,'a+');
    if ~xst
        fprintf(fid,'Stacked surface (ME or EV) splitting results, methods: nw (no weight), WS (Wolfe & Silver, 1998), RH (Restivo & Helffrich, 1999)');
        fprintf(fid,'\n--------------------------------------------------------------------------------------------------------------------------------------------------------');
        fprintf(fid,'\n sta nsurf ndf  minbaz  maxbaz  meanbaz  mindis  maxdis  meandis        phi               dt          method    surfin     Remark     used events (phases)');%      mbaz      minc' );
    end

    % check used surface input
    if h.surf_kind==1 % minimum energy
        surf_input='ME';
    else              % Eigenvalues
        surf_input='EV';
    end


    fseek(fid, 0, 'eof'); %go to end of file
    fprintf(fid,'\n %s %2.0f   %2.0f    %3.1f    %3.1f    %3.1f     %3.1f   %3.1f   %3.1f  %4.0f < %3.0f < %3.0f   %4.1f < %3.1f < %3.1f     %s        %s       %s           %s',...
        staname, nsurf, ndf, min_bazi, max_bazi, mean(bazis), min_dis, max_dis, mean(dists), phistack, dtstack, stack_meth, surf_input, res_remark, string_ev_used);
    fclose(fid);

    %==========================================================================
    % txt-file, GMT ready format
    
    % format allows to directly use the output file in GMT (5.2.1 or
    % higher) via the -SJ flag of psxy. 
    
    % EXAMPLE:   psxy splitresultsSTACK_OUTPUTNAME_4GMT.dat -R -J -SJ -W0.25p,blue -Gred -O -K >> $ps
    
    % column description:
    % station lat. | station lon. | phistack | dtstack(scaled by factor scale_bar) | bar thickness | mean BAZ (not used in GMT) | mean dist (not used in GMT) | station name (not used in GMT) 

    fname = fullfile(config.savedir,['splitresultsSTACK_' config.project(1:end-4) '_4GMT.dat' ]);

    %################
    % GMT parameters (please adjust for your requirements) 
    scale_bar=60; % scaling factor, set for scaling the plotted bars uniformly with respect to length
    thick_bar=10.5; % define thickness of bars
    %################

    fid   = fopen(fname,'a+');
    fseek(fid, 0, 'eof'); %go to end of file
    fprintf(fid,'%5.3f %5.3f %3.1f %3.1f %3.1f %5.3f %5.3f %s \n',...
       config.slong, config.slat, phistack(2), dtstack(2)*scale_bar, thick_bar, mean(bazis), mean(dists), staname);
    fclose(fid);

    %==========================================================================
    % pdf-plot

    %............................
    SS_gen_stackresplot(h,min_bazi,max_bazi,min_dis,max_dis,mean(bazis),mean(dists),phistack,dtstack)
    %............................

    %==========================================================================
    % mat-file

    % SAVE results to permanent variable eqstack (mat-file) for further analysis 
    % outside of SL/SS, when variable already exists, it is read in the main 
    % function and the new result is connected to the end, otherwise a new 
    % struct is generated and saved in the following

    eqstack(end+1).results.meas_dstr=datestr(now,'yyyy-mm-dd_HH:MM:SS'); % date of measurement
    eqstack(end).results.meas_sdn=now; % date of measurement, serial date number 
    eqstack(end).results.stnname=config.stnname; 
    eqstack(end).results.netw=config.netw; 
    eqstack(end).results.slat=config.slat; 
    eqstack(end).results.slong=config.slong; 
    eqstack(end).results.stack_meth=stack_meth;
    eqstack(end).results.nsurf=nsurf;
    eqstack(end).results.surf_in=surf_input;
    eqstack(end).results.phi_stack=phistack;
    eqstack(end).results.dt_stack=dtstack;
    eqstack(end).results.surf_stack=stacked_err_surf;
    eqstack(end).results.level=level;
    eqstack(end).results.ndf=ndf;
    eqstack(end).results.bazi_used=bazis;
    eqstack(end).results.bazi_min=min_bazi;
    eqstack(end).results.bazi_max=max_bazi;
    eqstack(end).results.bazi_mean=mean(bazis);
    eqstack(end).results.dist_used=dists;
    eqstack(end).results.dist_min=min_dis;
    eqstack(end).results.dist_max=max_dis;
    eqstack(end).results.dist_mean=mean(dists);
    eqstack(end).results.remark=res_remark;
    
    % add structs of input events, including all used content such as Emap,
    % EVmap, ndfs, singlephi, singledt etc.
    eqstack(end).results.events_in=h.data(index);

    save(fullfile(config.savedir,[config.stnname '_stackresults.mat']),'eqstack');

    %==========================================================================

    disp(' ')
    disp(['Saved result to file < ' config.stnname '_stackresults.mat > !'])

    disp(' ')
    if outtext==1
        disp(['Saved result to file < splitresultsSTACK_' config.project(1:end-4) '.txt > (with remark)!'])
    else
        disp(['Saved result to file << splitresultsSTACK_' config.project(1:end-4) '.txt >> (without remark)!'])
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SAVE SIMW results 
else
    
    % check if qual and isnull are selected
    null= ~isfield(SIMW_temp,'AnisoNull');
    qual= ~isfield(SIMW_temp,'Q');

    if any([qual,null])
        str=[];
        if qual
            str=char(str,'Please select QUALITY of this result');
        end
        if null
            str=char(str,'Please select if this result is a NULL');
        end
        errordlg(char(str,' ' ,'or select "Discard" in the Result menu...'),'Error');
        return
    end  
    
    % check if a remark was added to the current result
    if isfield(SIMW_temp,'remark') && ~isempty(SIMW_temp.remark)
        res_remark=SIMW_temp.remark {1:end};
        outtext=1;
    else
        res_remark=[];
        outtext=2;
    end   
  

    %==========================================================================
    % txt-file
    
    %....................................
    % generate yyyy.JD (phase) for txt file, to show which single events/phases 
    % where used for SIMW analysis
    ev_used=SIMW_temp.events;
    datesall=vertcat(ev_used.date);
    yyyyJDs=[datesall(:,1) datesall(:,7)];
    
    string_ev_used=[];
    for ii=1:length(ev_used)
      phase_used=ev_used(ii).results.SplitPhase;
      string_ev_used=horzcat(string_ev_used,[num2str(yyyyJDs(ii,1)) '.' num2str(yyyyJDs(ii,2)) ' (' phase_used ')   ']);
    end
    %....................................


    fname = fullfile(config.savedir,['splitresultsSIMW_' config.project(1:end-4) '.txt' ]);

    xst   = exist(fname);
    fid   = fopen(fname,'a+');
    if ~xst
        fprintf(fid,'Splitting results from SIMW analysis' );
        fprintf(fid,'\n------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
        fprintf(fid,'\n sta nwave minbaz maxbaz meanbaz mindis maxdis meandis taper   phi_RC   dt_RC        phi_SC           dt_SC        phi_EV  dt_EV  quality  null?  Remark     used events (phases)' );
    end
    fseek(fid, 0, 'eof'); %go to end of file
    
    if ~strcmp(SIMW_temp.taper,'none')
        formatstr='\n%4s%3.0f     %3.1f   %3.1f   %3.1f   %3.1f  %3.1f  %3.1f   %3.0f      %3.0f      %3.1f  %4.0f < %3.0f < %3.0f   %4.1f < %3.1f < %3.1f   %3.1f    %3.1f    %4s    %3s    %s           %s';
    else
        formatstr='\n%4s%3.0f     %3.1f   %3.1f   %3.1f   %3.1f  %3.1f  %3.1f   %4s      %3.0f      %3.1f  %4.0f < %3.0f < %3.0f   %4.1f < %3.1f < %3.1f   %3.1f    %3.1f    %4s    %3s    %s           %s';
    end

    fprintf(fid,formatstr,...
        config.stnname, SIMW_temp.noc, SIMW_temp.bazint(1),SIMW_temp.bazint(2),SIMW_temp.bazi_mean,...
        SIMW_temp.distint(1),SIMW_temp.distint(2),SIMW_temp.dist_mean,SIMW_temp.taper,...
        SIMW_temp.phiRC(2), SIMW_temp.dtRC(2),...
        SIMW_temp.phiSC,    SIMW_temp.dtSC,...
        SIMW_temp.phiEV(2), SIMW_temp.dtEV(2),...
        char(SIMW_temp.Q), char(SIMW_temp.AnisoNull), res_remark, string_ev_used);
    fclose(fid);
    
    
    %==========================================================================
    % txt-file, GMT ready format
    
    % format allows to directly use the output file in GMT (5.2.1 or
    % higher) via the -SJ flag of psxy. 
    
    % EXAMPLE:   psxy splitresultsSIMW_OUTPUTNAME_4GMT.dat -R -J -SJ -W0.25p,blue -Gred -O -K >> $ps
    
    % column description:
    % station lat. | station lon. | phistack | dtstack(scaled by factor scale_bar) | bar thickness | mean BAZ (not used in GMT) | mean dist (not used in GMT) | station name (not used in GMT) 

    fname = fullfile(config.savedir,['splitresultsSIMW_' config.project(1:end-4) '_4GMT.dat' ]);
    
    %################
    % GMT parameters (please adjust for your requirements) 
    scale_bar=60; % scaling factor, set for scaling the plotted bars uniformly with respect to length
    thick_bar=10.5; % define thickness of bars
    %################

    fid   = fopen(fname,'a+');
    fseek(fid, 0, 'eof'); %go to end of file
    
    formatstr='%5.3f %5.3f %3.1f %3.1f %3.1f %5.3f %5.3f %s \n';

    fprintf(fid,formatstr,...
       config.slong, config.slat, SIMW_temp.phiSC(2),SIMW_temp.dtSC(2)*scale_bar,thick_bar,SIMW_temp.bazi_mean,SIMW_temp.dist_mean,config.stnname);
    fclose(fid);

    %==========================================================================
    % mat-file

    % SAVE results to permanent variable eqstack (mat-file) for further analysis 
    % outside of SL/SS, when variable already exists, it is read in the main 
    % function and the new result is connected to the end, otherwise a new 
    % struct is generated and saved in the following

    eqstack(end+1).results.meas_dstr=datestr(now,'yyyy-mm-dd_HH:MM:SS'); % date of measurement
    eqstack(end).results.meas_sdn=now; % date of measurement, serial date number 
    eqstack(end).results.stnname=config.stnname; 
    eqstack(end).results.netw=config.netw; 
    eqstack(end).results.slat=config.slat; 
    eqstack(end).results.slong=config.slong; 
    eqstack(end).results.stack_meth='SIMW';
    eqstack(end).results.nwave=SIMW_temp.noc;
    eqstack(end).results.taper=SIMW_temp.taper;
    eqstack(end).results.quality_simw=SIMW_temp.Q;
    eqstack(end).results.Null_simw=SIMW_temp.AnisoNull;
    eqstack(end).results.phiSC_simw=SIMW_temp.phiSC;
    eqstack(end).results.dtSC_simw=SIMW_temp.dtSC;
    eqstack(end).results.phiRC_simw=SIMW_temp.phiRC;
    eqstack(end).results.dtRC_simw=SIMW_temp.dtRC;
    eqstack(end).results.phiEV_simw=SIMW_temp.phiEV;
    eqstack(end).results.dtEV_simw=SIMW_temp.dtEV;
    eqstack(end).results.bazi_used=SIMW_temp.bazi;
    eqstack(end).results.bazi_min=SIMW_temp.bazint(1);
    eqstack(end).results.bazi_max=SIMW_temp.bazint(2);
    eqstack(end).results.bazi_mean=SIMW_temp.bazi_mean;
    eqstack(end).results.dist_used=SIMW_temp.dist;
    eqstack(end).results.dist_min=SIMW_temp.distint(1);
    eqstack(end).results.dist_max=SIMW_temp.distint(2);
    eqstack(end).results.dist_mean=SIMW_temp.dist_mean;
    eqstack(end).results.remark=res_remark;

    % add structs of input events, including all used content such as Emap,
    % EVmap, ndfs, singlephi, singledt etc.
    eqstack(end).results.events_in=SIMW_temp.events;

    save(fullfile(config.savedir,[config.stnname '_stackresults.mat']),'eqstack');
    
    %==========================================================================

    disp(' ')
    disp(['Saved result to file < ' config.stnname '_stackresults.mat > !'])

    disp(' ')
    if outtext==1
        disp(['Saved result to file < splitresultsSIMW_' config.project(1:end-4) '.txt > (with remark)!'])
    else
        disp(['Saved result to file << splitresultsSIMW_' config.project(1:end-4) '.txt >> (without remark)!'])
    end

    %==========================================================================
    % pdf-plot

    %change here, if you dont like the figure output (resolution etc)
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


    fname = sprintf(['Multi_result_SIMW', config.exportformat]);

    %check if file alredy exists (phase already splitted)
    No=2;
    while exist(fullfile(config.savedir, fname),'file') == 2
        fname = sprintf('Multi_result_SIMW[%.0f]%s',...
                No, config.exportformat);
        No = No+1;
    end
  
    print( option{:}, fullfile(config.savedir,fname),'-fillpage');

    close(gcf) 
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

% EOF
