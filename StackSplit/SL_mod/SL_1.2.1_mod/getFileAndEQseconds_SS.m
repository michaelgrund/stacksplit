function [FIsec, FIyyyy, EQsec, Omarker] = getFileAndEQseconds(F,eqin,offset)
%calculate start times of the files in seconds after midnight, January 1st
%this works for SAC files created with rdseed4.5.1
%eg: F = '1993.159.23.15.09.7760.IU.KEV..BHN.D.SAC'
% if your filnames contains no julian day, please use command
% dayofyear (in Splitlab/Tools)
% rdseed 5.3.1 format:
%    F = '2011.070.00.00.00.0195.IU.ANMO.00.BH1.M.SAC'


% Windows user can try a renamer , for example 1-4aren (one-for all renamer)
% http://www.1-4a.com/rename/ perhaps this adress is still valid


%==========================================================================
% Yvonne Fröhlich (YF), Karlsruhe Institute of Technology (KIT), 
% Email: yvonne.froelich@kit.edu
% July-December 2021
%
% modifications to fix extraction of start time by SplitLab 
% (unconsidered milliseconds or seconds of start time)
%
%==========================================================================


global config


if config.UseHeaderTimes | strcmp(config.FileNameConvention, '*.e; *.n; *.z')
    for k=1:size(F,1)
        workbar(k/size(F,1),'Reading header')
        try
            sac = sl_rsac([config.datadir filesep F(k,:)]);
        catch
            sac = sl_rsacsun([config.datadir filesep F(k,:)]);
        end
%        [FIyyyy(k), FIddd(k), FIHH(k), FIMM(k), FISS(k)] =...
%            sl_lh(sac, 'NZYEAR','NZJDAY','NZHOUR','NZMIN', 'NZSEC');
        [FIyyyy(k), FIddd(k), FIHH(k), FIMM(k), FISS(k), FImmm(k)] =...
            sl_lh(sac, 'NZYEAR','NZJDAY','NZHOUR','NZMIN', 'NZSEC', 'NZMSEC'); % YF add msec 2021/06/24
        Omarker(k) = sl_lh(sac, 'O');
    end
    
     Omarker(Omarker == -12345) = 0;  %verify, if O-marker is set   
%     FIsec  =  FISS + FIMM*60 + FIHH*3600 + (FIddd)*86400 + Omarker;
     FIsec  =  FImmm/1000 + FISS + FIMM*60 + FIHH*3600 + (FIddd)*86400 + Omarker; % YF add msec 2021/06/24

    fclose all;



else % USE FILENAME

	% YF add warning 2021/Nov/28
    msgbox( {'When extracting the \bfstart time\rm from the \bffile name\rm be sure that this time is \bf\itreally\rm the exact \bfstart time\rm of the \bftrace!'}, ...
            'Check start time' ,'warn', ...
            struct('WindowStyle',{'modal'},'Interpreter',{'tex'}) ); 
        
    switch config.FileNameConvention
	
        case 'mseed2sac1'
            % mseed2sac format: QT.ANIL.00.HHZ.D.2012,321,18:00:00.SAC % YF year,jday,hour:min:sec
            
			% YF add warning 2021/Nov/28
			msgbox( 'Only correct for traces with start times of \bfzero milliseconds\rm!', ...
                    'Check milliseconds' ,'warn', ...
                    struct('WindowStyle',{'modal'},'Interpreter',{'tex'}) );
            
			FIsec = zeros(1,length(F(:,1)));
            FIyyyy = zeros(1,length(F(:,1)));
            
            % Loop through each file
            for i=1:length(F(:,1))
               dots   =  strfind(F(i,:),'.');
               commas =  strfind(F(i,:),',');
               colons =  strfind(F(i,:),':');
               % Find the network code (if it exists)
               if dots(1) > 1
                   networkcode=F(i,dots(1)-2:dots(1)-1);
               end
               % Find the station name
               stationcode = F(i,dots(1)+1:dots(2)-1);
               % location code (if not blank!)
               if dots(2)+1 ~= dots(3)
                   locationcode = F(i,dots(2)+1:dots(3)-1);
               end
               % Channel code
               channelcode = F(i,dots(3)+1:dots(4)-1);
               % and the single letter quality flag
               qualitycode = F(i,dots(4)+1);
               % Now for timing (only part that really matters)
               FIyyyy(i) = str2double(F(i,dots(5)+1:commas(1)-1));
               FIddd     = str2double(F(i,commas(1)+1:commas(2)-1));
               FIHH      = str2double(F(i,commas(2)+1:colons(1)-1));
               FIMM      = str2double(F(i,colons(1)+1:colons(2)-1));
               FISS      = str2double(F(i,colons(2)+1:dots(end)-1));
               FIsec(i)  = FISS + FIMM * 60 + FIHH * 3600 + (FIddd) * 86400;  
            end
            
        case 'mseed2sac2'
            % seems mseed2sac changed naming convention...
            % mseed2sac format: IU.HRV.00.BH1.M.2011.246.044859.SAC % YF year.jday.hourminsec
            
			% YF add warning 2021/Nov/28
			msgbox( 'Only correct for traces with start times of \bfzero milliseconds\rm!', ...
                    'Check milliseconds' ,'warn', ...
                    struct('WindowStyle',{'modal'},'Interpreter',{'tex'}) );
            
			FIsec = zeros(1,length(F(:,1)));
            FIyyyy = zeros(1,length(F(:,1)));
            
            % Loop through each file
            for i=1:length(F(:,1))
               dots   =  strfind(F(i,:),'.');
               % Find the network code (if it exists)
               if dots(1) > 1
                   networkcode=F(i,dots(1)-2:dots(1)-1);
               end
               % Find the station name
               stationcode = F(i,dots(1)+1:dots(2)-1);
               % location code (if not blank!)
               if dots(2)+1 ~= dots(3)
                   locationcode = F(i,dots(2)+1:dots(3)-1);
               end
               % Channel code
               channelcode = F(i,dots(3)+1:dots(4)-1);
               % and the single letter quality flag
               qualitycode = F(i,dots(4)+1);
               % Now for timing (only part that really matters)
               FIyyyy(i) = str2double(F(i,dots(5)+1:dots(6)-1));
               FIddd     = str2double(F(i,dots(6)+1:dots(7)-1));
               FIHH      = str2double(F(i,dots(7)+1:dots(7)+2));
               FIMM      = str2double(F(i,dots(7)+3:dots(7)+4));
               FISS      = str2double(F(i,dots(7)+5:dots(end)-1));
               FIsec(i)  = FISS + FIMM * 60 + FIHH * 3600 + (FIddd) * 86400;  
            end            
                    
        case 'RDSEED'
            % RDSEED format '1993.159.23.15.09.7760.IU.KEV..BHN.D.SAC' % YF year.jday.hour.min.sec.msec
            FIyyyy = str2num(F(:,1:4));
            FIddd  = str2num(F(:,6:8));
            FIHH   = str2num(F(:,10:11));
            FIMM   = str2num(F(:,13:14));
            FISS   = str2num(F(:,16:17));
            FIMMMM = str2num(F(:,18:22));
            FIsec  = FIMMMM + FISS + FIMM*60 + FIHH*3600 + (FIddd)*86400; 
			% YF no division by 1000 or 10000 for msec to get sec 
			% because position 18 is the dot therefore .xxxx, so 0.xxxx

        case 'SEISAN'
            % SEISAN format '2003-05-26-0947-20S.HOR___003_HORN__BHZ__SAC' % YF year-month-day-minsec
            
			% YF add warning 2021/Nov/28
			msgbox( 'Only correct for traces with start times of \bfzero milliseconds\rm!', ...
                    'Check milliseconds' ,'warn', ...
                    struct('WindowStyle',{'modal'},'Interpreter',{'tex'}) );
            
			FIyyyy = str2num(F(:,1:4));
            FImonth= str2num(F(:,6:7));
            FIdd   = str2num(F(:,9:10));
            FIHH   = str2num(F(:,12:13));
            FIMM   = str2num(F(:,14:15));
            FISS   = str2num(F(:,17:18));

            FIddd = dayofyear(FIyyyy',FImonth',FIdd')';%julian Day
            FIsec =  FISS + FIMM*60 + FIHH*3600 + (FIddd)*86400;

        case 'YYYY.JJJ.hh.mm.ss.stn.sac.e'
            % Format: 1999.136.15.25.00.ATD.sac.z % YF year.jday.hour.min.sec
            
			% YF add warning 2021/Nov/28
			msgbox( 'Only correct for traces with start times of \bfzero milliseconds\rm!', ...
                    'Check milliseconds' ,'warn', ...
                    struct('WindowStyle',{'modal'},'Interpreter',{'tex'}) );
            
			FIyyyy = str2num(F(:,1:4));
            FIddd  = str2num(F(:,6:8));
            FIHH   = str2num(F(:,10:11));
            FIMM   = str2num(F(:,13:14));
            FISS   = str2num(F(:,16:17));
            FIsec  = FISS + FIMM*60 + FIHH*3600 + (FIddd)*86400;

        case 'YYYY.MM.DD-hh.mm.ss.stn.sac.e';
            % Format: 2003.10.07-05.07.15.DALA.sac.z % YF year.month.day-hour.min.sec
            
			% YF add warning 2021/Nov/28
			msgbox( 'Only correct for traces with start times of \bfzero milliseconds\rm!', ...
                    'Check milliseconds' ,'warn', ...
                    struct('WindowStyle',{'modal'},'Interpreter',{'tex'}) );
            
			FIyyyy = str2num(F(:,1:4));
            FImonth= str2num(F(:,6:7));
            FIdd   = str2num(F(:,9:10));
            FIHH   = str2num(F(:,12:13));
            FIMM   = str2num(F(:,15:16));
            FISS   = str2num(F(:,18:19));

            FIddd = dayofyear(FIyyyy',FImonth',FIdd')';%julian Day
            FIsec  =  FISS + FIMM*60 + FIHH*3600 + (FIddd)*86400;
            
        case 'YYYY_MM_DD_hhmm_stnn.sac.e';
            % Format: 2005_03_02_1155_pptl.sac (LDG/CEA data) % YF year_month_day_hourmin
            
			% YF add warning 2021/Nov/28
			msgbox( 'Only correct for traces with start times of \bfzero seconds\rm!', ...
                    'Check seconds' ,'warn', ...
                    struct('WindowStyle',{'modal'},'Interpreter',{'tex'}) );
           
			FIyyyy = str2num(F(:,1:4));
            FImonth= str2num(F(:,6:7));
            FIdd   = str2num(F(:,9:10));
            FIHH   = str2num(F(:,12:13));
            FIMM   = str2num(F(:,14:15));
            
            FIddd = dayofyear(FIyyyy',FImonth',FIdd')';%julian Day
            FIsec = FIMM*60 + FIHH*3600 + (FIddd)*86400;

        case 'stn.YYMMDD.hhmmss.e'
            % Format: fp2.030723.213056.X (BroadBand OBS data) % YF yearmonthday.hourminsec
            
			% YF add warning 2021/Nov/28
			msgbox( {'Only correct for traces with start times of \bfzero milliseconds\rm!'; ...
					'Only correct for \bfyear 2000 or later\rm!'}, ...
                    'Check milliseconds and year' ,'warn', ...
                    struct('WindowStyle',{'modal'},'Interpreter',{'tex'}) );
           
			FIyyyy = 2000 + str2num(F(:,5:6));%only two-digit year identifier => add 2000, assuming no OBS data before 2000
            FImonth= str2num(F(:,7:8));
            FIdd   = str2num(F(:,9:10));
            FIHH   = str2num(F(:,12:13));
            FIMM   = str2num(F(:,14:15));
            FISS   = str2num(F(:,16:17));

            FIddd = dayofyear(FIyyyy',FImonth',FIdd')';%julian Day
            FIsec = FISS + FIMM*60 + FIHH*3600 + (FIddd)*86400;
    end
    
    Omarker = zeros(size(FIsec));
end

%% get earthquake origin times
for a=1:length(eqin);
    EQsec(a) = eqin(a).date(6) + eqin(a).date(5)*60 + eqin(a).date(4)*3600 + eqin(a).date(7)*86400;
end

EQsec = EQsec + offset;

% EOF