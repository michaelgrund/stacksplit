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

samp=zeros(1,length(find_res));
check_rows=zeros(1,length(find_res));
check_cols=zeros(1,length(find_res));

for ii=1:length(find_res)
    if isfield(find_res(ii).results,'dttrace')
        samp(ii)=find_res(ii).results.dttrace;
    else
        error('No field dttrace available! Maybe you use an old version of StackSplit!')
    end
    
    [check_rows(ii),check_cols(ii)]=size(find_res(ii).results.Ematrix);

end

%==========================================================================

if length(unique(samp)) > 1 % VARYING sampling rate for whole data set
  
   % perform resampling of cut traces if not the same sampling

   use_samp=max(unique(samp));
   disp(['Data set contains more than one sampling rate (' regexprep(num2str(unique(samp),3), '\s*', ','),...
       ')! Resample all traces to the lowest (' num2str(use_samp) ')!'])

   for ii=1:length(find_res)
       
       if find_res(ii).results.dttrace~=use_samp

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

       end
   
   end

    sampling=dtcheck;

else % SAME sampling rate for whole data set
    sampling=unique(samp);
end

%==========================================================================

if length(unique(check_rows)) > 1 
   error('Different accuracy factors were used for single event calculations!')
else
    check_acc=unique(check_rows);
end

% accuracy factor, 1==using all possibilities, which is slowest; only values: 2^n,
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

% EOF
%==================================================================================================================================
%==================================================================================================================================

