function [f,sampling,find_res]=SS_check_input(find_res)
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
% check if input data (results of SplitLab) fulfill several criteria for
% the sampling rate and the accuracy factor for plotting stacked error
% surfaces
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
% Major updates:
%
% - v3.1 (2023): Yvonne Fröhlich, Karlsruhe Institute of Technology (KIT),
%                ORCID: 0000-0002-8566-0619
%                Email: yvonne.froehlich@kit.edu
%                Replace "resizem" by "imresize" for MATLAB R2023b and higher
%                as "resizem" was removed in R2023b
%                For context see PR https://github.com/michaelgrund/stacksplit/pull/13
%                Please note that the results of these two functions are not always identical
%                For examples see https://github.com/michaelgrund/stacksplit/pull/13#issuecomment-1624974426
%                This issue was reported to and confirmed by the MATLAB Support
%==================================================================================================================================
%==================================================================================================================================

global config

samp=zeros(1,length(find_res));
check_rows=zeros(1,length(find_res));
check_rowsC=zeros(1,length(find_res));
check_cols=zeros(1,length(find_res));
check_colsC=zeros(1,length(find_res));

for ii=1:length(find_res)
    if isfield(find_res(ii).results,'dttrace')
        samp(ii)=find_res(ii).results.dttrace;
    else
        error(['No field dttrace available! ' ...
            'Maybe you are using an old version of SplitLab?'])
    end
    [check_rows(ii),check_cols(ii)]=size(find_res(ii).results.Ematrix);
    [check_rowsC(ii),check_colsC(ii)]=size(find_res(ii).results.Cmatrix);
end

%==========================================================================

if length(unique(check_rows)) > 1
   check_acc=min(unique(check_rows));
   check_accC=min(unique(check_rowsC));
else
   check_acc=unique(check_rows);
   check_accC=unique(check_rowsC);
end

% define f for further calculations

% f: accuracy factor, 1==using all possibilities, which is slowest; only values: 2^n,
% value must be the same like in function splitSilverChan.m
% !!! if you use an other setting, please add a corresponding line in the
% following if query !!!

if check_acc==180
     f=1;
elseif check_acc==90 % default in SL
    f=2;
elseif check_acc==45
    f=4;
end

%==========================================================================

% VARYING sampling rate or accuracy factor for whole data set
if length(unique(samp)) > 1 || length(unique(check_rows)) > 1 ||...
        (length(unique(samp)) > 1 && ~isempty(unique(check_rows)))


   use_samp=max(unique(samp));

   if length(unique(samp)) > 1
        disp(['Data set contains more than one sampling rate (' regexprep(num2str(unique(samp),3), '\s*', ',') ')!'])
        disp(['Resample all traces to the lowest sampling rate (' num2str(use_samp) ') and resize surfaces!'])
   elseif length(unique(check_rows)) > 1
        disp('Data set contains more than one accuracy factor! Resize surfaces!')
   else
        disp(['Data set contains more than one sampling rate (' regexprep(num2str(unique(samp),3), '\s*', ',') ') and one accuracy factor!'])
        disp(['Resample all traces to the lowest sampling rate (' num2str(use_samp) ') and resize surfaces!'])
   end

   for ii=1:length(find_res)

       if find_res(ii).results.dttrace~=use_samp

           %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
           % perform resampling of cut traces if not the same sampling
           dtold=find_res(ii).results.dttrace;
           traceoldQ=find_res(ii).results.Qcut;
           traceoldT=find_res(ii).results.Tcut;
           traceoldL=find_res(ii).results.Lcut;
           traceoldE=find_res(ii).results.Ecut;
           traceoldN=find_res(ii).results.Ncut;
           traceoldZ=find_res(ii).results.Zcut;

           % old timevector
           timeolddt=0:dtold:(length(traceoldQ)-1)*dtold;
           % new timevector
           timenewdt=0:use_samp:fix(timeolddt(end)/use_samp)*use_samp;
           % check new sampling rate
           dtcheck=abs(timenewdt(1)-timenewdt(2));
           % interpolation method
           resampmeth='linear';

           % resample traces and write to struct
           find_res(ii).results.Qcut=(interp1(timeolddt,traceoldQ,timenewdt,resampmeth))';
           find_res(ii).results.Tcut=(interp1(timeolddt,traceoldT,timenewdt,resampmeth))';
           find_res(ii).results.Lcut=(interp1(timeolddt,traceoldL,timenewdt,resampmeth))';
           find_res(ii).results.Ecut=(interp1(timeolddt,traceoldE,timenewdt,resampmeth))';
           find_res(ii).results.Ncut=(interp1(timeolddt,traceoldN,timenewdt,resampmeth))';
           find_res(ii).results.Zcut=(interp1(timeolddt,traceoldZ,timenewdt,resampmeth))';

           % write new dt to struct
           find_res(ii).results.dttrace=dtcheck;
           %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

       end

       %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
       % resize error surfaces
       size_dt_test = length(fix(0:f*1:config.maxSplitTime/use_samp));

       Esurfold=find_res(ii).results.Ematrix;
       EVsurfold=find_res(ii).results.EVmatrix;
       Csurfold=find_res(ii).results.Cmatrix;

       % if sampling rate varies, matrix is resized to dimension of
       % smallest dimension in data set, if accuracy factor varies the
       % same, otherwise the matrices are not resized.

       % YF 2023-01-17, 2023-08-16
       % "resizem" was removed in R2023b and instead "imresize" should be used
       % For context see PR https://github.com/michaelgrund/stacksplit/pull/13
       % Please note that the results of these two functions are not always identical
       % For examples see https://github.com/michaelgrund/stacksplit/pull/13#issuecomment-1624974426
       % This issue was reported to and confirmed by the MATLAB Support
       matlab_version = SS_check_matlab_version();
       if matlab_version == 3  % MATLAB R2023b and higher
           Esurfnew = imresize(Esurfold,[check_acc size_dt_test], "nearest");
           EVsurfnew = imresize(EVsurfold,[check_acc size_dt_test], "nearest");
           Csurfnew = imresize(Csurfold,[check_accC size_dt_test], "nearest");
       else
           Esurfnew = resizem(Esurfold,[check_acc size_dt_test]);
           EVsurfnew = resizem(EVsurfold,[check_acc size_dt_test]);
           Csurfnew = resizem(Csurfold,[check_accC size_dt_test]);
       end

       find_res(ii).results.Ematrix=Esurfnew;
       find_res(ii).results.EVmatrix=EVsurfnew;
       find_res(ii).results.Cmatrix=Csurfnew;
       %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   end


   if exist('dtcheck','var')
        sampling=dtcheck;
   end

else % SAME sampling rate for whole data set
    sampling=unique(samp);
end

% EOF
%==================================================================================================================================
%==================================================================================================================================
