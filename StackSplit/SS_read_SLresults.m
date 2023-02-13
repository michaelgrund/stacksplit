function [merged_str,find_res]=SS_read_SLresults(curr_path2results,curr_staname)
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
% read SL results of single event measurements
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
% sort input depending on BAZ, if you want to sort by another parameter
% change it in the following line:

sortpar='bazi';
% sortpar='dist';
% sortpar='inipol';

%=============================================================================================
% find and load eqresults file in result folder

dir_eqresults=dir(fullfile(curr_path2results,[curr_staname '_eqresults.mat']));

if isempty(dir_eqresults)

   errordlg(['Sorry, no single event results are available for this ' ...
       'station!'],'Missing events')

   merged_str=[];
   find_res=[];

   return
elseif length(dir_eqresults)~=1
    error('More than one results file found in this folder!')
end

fload=load('-mat',fullfile(curr_path2results,[curr_staname '_eqresults.mat']));
eq=fload.eq;

%=============================================================================================
% check variable eq for results

zz=1;
for ii=1:length(eq)
    if ~isempty(eq(ii).results)
        if isfield(eq(ii).results,'ndfSC') && isfield(eq(ii).results,'LevelSC')  && isfield(eq(ii).results,'Qcut')
            find_res(zz)=eq(ii);
            zz=zz+1;
        else
            errordlg(['Available SplitLab results struct was generated ' ...
                'before the installation of StackSplit (several struct ' ...
                'fields are missing)! Sorry, no stacking possible!'])
            merged_str=[];
            find_res=[];
            return
        end
    end
end

if ~exist('find_res','var')

   disp('No results to stack in this folder!')
   return
end


if length([eq.results]) < 2

   errordlg(['Sorry, at least two single event results are necessary ' ...
       'for stacking!'],'Less events')

   merged_str=[];
   find_res=[];

   return

end

%=============================================================================================
% sort input depending on BAZ, if you want to sort by another parameter
% change it in the following line, e.g. find_res.dist for distance sorting

if strcmp(sortpar,'bazi')
    [~,index]=sort([find_res.bazi]);
elseif strcmp(sortpar,'dist')
    [~,index]=sort([find_res.dist]);
elseif strcmp(sortpar,'inipol')
    [~,index]=sort([find_res.inipol]);
end

find_res=find_res(index);

%=============================================================================================
% check for multiple results per event and modify (if necessary) input
% struct as follow:

% 1) if more than one result for the event is available (e.g. SKS + SKKS),
%   first a modification to the loaded input struct is done. Here, the main
%   struct with info about date, lat, long, bazi etc. is duplicated to the
%   number of results per event => in the list for each result an entry appears.
% 2) if more than one entry is selected for ONE event a warning is displayed
%   (e.g. if a SKS and SKKS result from one event is selected).
%   By listing all results in the same list, it is easy to access all
%   results without any further processing!

zz=1;
for ii=1:length(find_res)
    if length(find_res(ii).results) > 1
        for jj=1:length(find_res(ii).results)
            find_res_mod(zz)=find_res(ii);
            find_res_mod(zz).results=find_res(ii).results(jj);
            zz=zz+1;
        end
    else
        find_res_mod(zz)=find_res(ii);
        zz=zz+1;
    end
end

clear find_res
find_res=find_res_mod;

%=============================================================================================
% check if for each available single measurement the same method was
% used, especially important for the EV contribution

checkpre=[find_res.results];
checkop=unique({checkpre.method});

if length(checkop)~=1
    errordlg([{['Different splitting options were used for the single ' ...
        'event analysis in SplitLab!']}, {' '}, checkop(:)'],'Input problem')

    merged_str=[];
    find_res=[];
    return
end

%=============================================================================================
% assign color to event depending on quality

merged_str=cell(length(find_res),1); % allocation

for ii=1:length(find_res) % color results depending on quality ranking

    datestrings=find_res(ii).date(1:6);

    % using html syntax to generate forced spaces depending on the length
    % of the input character for BAZ, dist, inc, SNR => columns are sorted
    % perfectly beneath each other ;)

    % BAZ
    if find_res(ii).bazi < 100 && round(find_res(ii).bazi*100)/100 < 100 && find_res(ii).bazi > 10
        chbet_baz='<&nbsp ';

    elseif find_res(ii).bazi < 10 && round(find_res(ii).bazi*10)/10 < 10%% && find_res(ii).bazi > 1
        chbet_baz='<&nbsp&nbsp&nbsp ';

%     elseif find_res(ii).bazi < 1 && round(find_res(ii).bazi) < 1
%         chbet_baz='<&nbsp&nbsp&nbsp ';
    else
        chbet_baz='';
    end

    % dist
    if find_res(ii).dis < 100 && round(find_res(ii).dis*100)/100 < 100
        chbet_dis='<&nbsp ';
    elseif find_res(ii).dis < 10 && round(find_res(ii).dis*10)/10 < 10
        chbet_dis='<&nbsp&nbsp ';
    else
        chbet_dis='';
    end

    % ini pol
    if find_res(ii).results.inipol < 100 && round(find_res(ii).results.inipol*100)/100 < 100
        chbet_inipol='<&nbsp ';
    elseif find_res(ii).results.inipol < 10 && round(find_res(ii).results.inipol*10)/10 < 10
        chbet_inipol='<&nbsp&nbsp ';
    else
        chbet_inipol='';
    end

    % inc
    if find_res(ii).results.incline < 10 && round(find_res(ii).results.incline*10)/10 < 10
        chbet_inc='<&nbsp ';
    else
        chbet_inc='';
    end

    % SNR
    if find_res(ii).results.SNR(2) < 10 && round(find_res(ii).results.SNR(2)*10)/10 < 10
        chbet_snr='<&nbsp ';
    else
        chbet_snr='';
    end

    % filter
    if isinf(find_res(ii).results.filter(1)) && ~isinf(find_res(ii).results.filter(2))
        chbet_fil='<&nbsp ';
    elseif isinf(find_res(ii).results.filter(2)) && ~isinf(find_res(ii).results.filter(1))
        chbet_fil='<&nbsp&nbsp&nbsp&nbsp ';
    else
        chbet_fil='';
    end

    % phases
    if length(find_res(ii).results.SplitPhase) < 4
        chbet_phase='<&nbsp ';
    else
        chbet_phase='';
    end
    sel_qual=[datestr(datestrings,'yyyy/mm/dd_HH:MM:SS'),...
    ' | ' num2str(find_res(ii).date(end),'%03d'),...
    ' | ' chbet_baz num2str(find_res(ii).bazi,'%.01f'),...
    ' | ' chbet_dis num2str(find_res(ii).dis,'%3.1f'),...
    ' | ' chbet_inipol num2str(find_res(ii).results.inipol,'%3.1f'),...
    ' | ' chbet_inc num2str(find_res(ii).results.incline,'%.01f'),...
    ' | ' chbet_snr num2str(find_res(ii).results.SNR(2),'%.01f'),...
    ' | ' chbet_fil num2str(find_res(ii).results.filter(1),'%0.3f') '-' num2str(find_res(ii).results.filter(2),'%0.3f'),...
    ' | ' chbet_phase find_res(ii).results.SplitPhase];

    % using html syntax to generate coloured entries, at this point:
    % thanks to Yair Altman's undocumented MATLAB site
    % (http://undocumentedmatlab.com/blog/html-support-in-matlab-uicomponents)
    if strcmp(find_res(ii).results.quality,'good') && strcmp(find_res(ii).results.Null,'No')
       String=['<HTML><font color="#088A29"> &#9650<&nbsp ' sel_qual '</font></HTML>'];
    elseif strcmp(find_res(ii).results.quality,'fair') && strcmp(find_res(ii).results.Null,'No')
       String=['<HTML><font color="#000000"> &#9650<&nbsp ' sel_qual '</font></HTML>'];
    elseif strcmp(find_res(ii).results.quality,'poor') && strcmp(find_res(ii).results.Null,'No')
          String=['<HTML><font color="#B40404"> &#9650<&nbsp ' sel_qual '</font></HTML>'];
    elseif strcmp(find_res(ii).results.quality,'good') && strcmp(find_res(ii).results.Null,'Yes')
         String=['<HTML><font color="#0040FF"> &#9660<&nbsp ' sel_qual '</font></HTML>'];
    elseif strcmp(find_res(ii).results.quality,'fair') && strcmp(find_res(ii).results.Null,'Yes')
       String=['<HTML><font color="#8904B1"> &#9660<&nbsp ' sel_qual '</font></HTML>'];
    elseif strcmp(find_res(ii).results.quality,'poor') && strcmp(find_res(ii).results.Null,'Yes')
       String=['<HTML><font color="#6E6E6E"> &#9660<&nbsp ' sel_qual '</font></HTML>'];
    end

    merged_str{ii}=String;

end

%=====================================================================================================================
%=====================================================================================================================