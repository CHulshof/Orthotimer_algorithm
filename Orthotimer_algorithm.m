function [M] = Orthotimer_algorithm(file)

%% Function to calculate footwear use from orthotimer raw datafiles.
% Copyright CM Hulshof & S Exterkate
% 2021

% INPUT: file = name csv file as character, for example: 
% 'E0-38-02-10-05-18-2D-FD_10_26_2021.csv'

% OUTPUT: M = matrix including:
% M.(csvName).startdate     -> start date sensor (datetime)
% M.(csvName).enddate       -> end date sensor (datetime)
% M.(csvName).sampletime    -> sample time sensor (double)
% M.(csvName).sensor        -> matrix with footwear on (=1) and footwear off
% (n=0) for each measurement (dependent on sample time) (double)
% M.(csvName).dayTbl        -> day table with number of samples footwear on
% (n=1) per day (time footwear on are dependent on sample time) (timetable)
% M.(csvName).dayTblHrs     -> day table with hours of wearing time per day
% (adjusted for sampletime) (timetable)
% M.(csvName).SensorOnMat   -> table with footwear on (=1) and footwear off
% (n=0) for each measurement (dependent on sample time) (timetable)

%% Set time zone
setTimeZone = 'Europe/Amsterdam'; %Set prefered time zone

%% load data
orthoFile = readtable(file);

% create csvName for matrix M
csvName = file;
location=regexp(csvName,'[_]');
csvName(location(1):end)=[];
csvName(regexp(csvName,'-'))=[];% Remove '-' from csvName

%Reshape orthoFile table into datetime
timeUTC = datetime(orthoFile{:,4},'InputFormat','h:mm a');
dtUTC = datetime(orthoFile{:,3},'Format','dd/MM/yyyy HH:mm') + timeofday(timeUTC);
orthoFile.Date_UTC_ = dtUTC;
orthoFile.Time_UTC_ = [];
orthoFile.Properties.VariableNames{3} = 'DateTime_UTC';
orthoFile.DateTime_UTC = datetime(orthoFile.DateTime_UTC,'TimeZone','Etc/UTC'); %Set timezone as UTC
orthoFile.DateTime_UTC.TimeZone = setTimeZone; %Change to prefered time zone
orthoFile.Properties.VariableNames{3} = 'DateTime_Ams';

%startdate
startdate = orthoFile.DateTime_Ams(1);
startdate.Format = 'dd-MMM-yyyy';
M.(csvName).startdate = dateshift(startdate, 'start','day');

%enddate
enddate = orthoFile.DateTime_Ams(end);
enddate.Format = 'dd-MMM-yyyy';
M.(csvName).enddate = dateshift(enddate, 'start','day');

%double of measured temperatures
sensor = orthoFile.Value;

%% Sample Frequency Settings
if height(orthoFile) < 19 %If less than 19 measurements
    fprintf('less than 19 measurements in %s sensor %s.\n',csvName);
    sensorOn = zeros(height(orthoFile),1);
    p = 0; %p = 0: not enough samples taken
    M.(csvName).sensor = sensorOn;

else %20 or more measurements done with orthotimer
    dateAms = orthoFile.DateTime_Ams; %Datetime vector
    sampleDifs = diff(dateAms(1:20)); %Difference between first 20 samples
    sampletime = minutes(mode(sampleDifs));% most common sampletime in minutes (difference between two time points in orthoFile,DateTime_Ams);
    M.(csvName).sampletime = sampletime;

    sameDateLgc = ismember(dateAms,startdate); %find startdate
    sensorStart = find(sameDateLgc,1,'first'); %row number of start date

    %% Get time
    sensorEnd = length(sensor);
    sensor = sensor(sensorStart:sensorEnd); %Delete rows outside start and enddate.

    %% Settings based on sampletime (minutes)
    if sampletime==20
        Fc = 1.3*10^-4;
        mph_min=0.8;
        mph_max=1.1;
        mpd = 1;
    elseif sampletime==15
        Fc = 1.4*10^-4;
        mph_min=0.5;
        mph_max=0.8;
        mpd = 1;
    else
        error('Error: Sampletime is different from 15 or 20 minutes')
    end
   
    %% Filter raw temperature data
    %lowpassfilter
    %CutOff frequencies are based on FourierTransform.
    [filtSensor] = lowpassfilter(sensor, sampletime, Fc);

    %% Check Gaps
    a = diff(dateAms);
    f = find(a>minutes(sampletime));% Gaps bigger than sampletime

    %% peak detection
    sensorSlope = diff(filtSensor(:,1));
    [~,maxIdx,~,minIdx,~,~] = determinationpeaks(sensorSlope,mpd,mph_min,mph_max);
    if ~isempty(maxIdx) && ~isempty(minIdx) %Both minima and maxima in sensorSlope
        %% <24h between MaxIdx & MinIdx %% also check for gap in between.
        [maxIdx,minIdx,~,lastMax,firstMin,~] = check_24h(maxIdx,minIdx,sampletime,f);
        if ~isempty(maxIdx) && ~isempty(minIdx)
            locsAll=peak_gap_first(maxIdx,minIdx,f);%% peak gap check
            [iMultiMax, iMultiMin, locsAll] = check_multiple_peaks(locsAll);%% check multiple indices max / min. also check for gap in locsAll

            %% Remove double positive peaks and double negative peaks
            maxminRemoved = NaN(length(locsAll),1); %array to save removed max and min indices.

            %remove double maxes and mins that are <1hour apart
            [iMultiMax, maxIdx, maxminRemoved] = double_max_1h(iMultiMax,...
                maxIdx, locsAll, maxminRemoved, sampletime); % 2 MaxIdx <= 1h
            [iMultiMin, minIdx, maxminRemoved] = double_min_1h(iMultiMin,...
                minIdx, locsAll, maxminRemoved, sampletime); % 2 MinIdx <= 1h

            %remove double maxes and mins that are further apart
            [~, maxIdx, maxminRemoved] = double_max_2(iMultiMax, maxIdx, ...
                locsAll, maxminRemoved, sensor, minIdx, firstMin); % 2 on-peaks > 1h
            [~, minIdx, ~] = double_min_2(iMultiMin, minIdx, maxIdx,...
                locsAll, maxminRemoved, sensor, lastMax); % 2 off-peaks > 1h
            %% check for gaps a second time.
            [maxIdx,minIdx]=peak_gap_second(maxIdx,minIdx,f);
            locsAll=peak_gap_first(maxIdx,minIdx,f);

            [iMultiMax, iMultiMin, locsAll] = check_multiple_peaks(locsAll);% check multiple indices max / min %% also check for gap in locs_all
            %% Remove peaks within 1 hour again
            maxminRemoved = NaN(length(locsAll),1); %array to save removed max and min indices.

            %remove double maxes and mins that are <1hour apart
            [iMultiMax, maxIdx, maxminRemoved] = double_max_1h(iMultiMax,...
                maxIdx, locsAll, maxminRemoved, sampletime); % 2 MaxIdx <= 1h
            [iMultiMin, minIdx, maxminRemoved] = double_min_1h(iMultiMin,...
                minIdx, locsAll, maxminRemoved, sampletime); % 2 MinIdx <= 1h

            %remove double maxes and mins that are further apart
            [iMultiMax, maxIdx, maxminRemoved] = double_max_2(iMultiMax,...
                maxIdx, locsAll, maxminRemoved, sensor, minIdx, firstMin); % 2 on-peaks > 1h
            [iMultiMin, minIdx, maxminRemoved] = double_min_2(iMultiMin,...
                minIdx, maxIdx, locsAll, maxminRemoved, sensor, lastMax);% 2 off-peaks > 1h

            [maxIdx,minIdx]=peak_gap_second(maxIdx,minIdx,f); %Check for gaps in wearingtime again
            [maxIdx, minIdx, p] = firstMax_lastMin(maxIdx, minIdx);%% find first maxIdx & last minIdx
        end
    end

    %% Selection maxIdx/minIdx
    if isempty(maxIdx) || isempty(minIdx)
        p = 0; %no peaks detected
        sensorOn = zeros(size(sensor));
    end
    %% shoes on
    if p~=0
        sensorOn = zeros(size(sensor));     % For speed
        for idx =  1 : size(p,1)
            sensorOn(p(idx,1):p(idx,2)) = 1;    % 0 = Sensor off, 1 = Sensor on
        end
    end

    %Create timetable of sensorOn.
    timeTbl = timetable(orthoFile.DateTime_Ams,sensorOn);
    timeTbl.Properties.VariableNames = {'sensorOn'};

    %retime
    dayTbl = retime(timeTbl,'daily','sum'); %retime to daily.

    %make gaps nan
    dtFormt = 'yyyy-MM-dd';
    for gapNum = 1:length(f)
        datestr1 = string(dateAms(f(gapNum)),dtFormt);
        datestr2 = string(dateAms(f(gapNum)+1),dtFormt);
        dt1 = datetime(datestr1,'InputFormat',dtFormt,'TimeZone',setTimeZone);
        dt2 = datetime(datestr2,'InputFormat',dtFormt,'TimeZone',setTimeZone);
        dt2 = dt2 + 23*hours + 59*minutes + 59*seconds;
        dtRange = timerange(dt1,dt2);
        timeTbl.sensorOn(dtRange) = nan; %Both on timetable of sensor
        dayTbl.sensorOn(dtRange) = nan; %and timetable per day
    end
    sensorOn = timeTbl.sensorOn;

    dayTbl.sensorOn(1) = NaN; %First day was not measured fully.
    dayTbl.sensorOn(end) = NaN; %Last day was not measured fully.
    
    M.(csvName).sensor = dayTbl.sensorOn;
    M.(csvName).dayTbl = dayTbl;
    M.(csvName).dayTblHrs = dayTbl;
    M.(csvName).dayTblHrs.sensorOn = M.(csvName).dayTblHrs.sensorOn * (sampletime/60);

end

%% Save timepoints (metadata) and sensorOn data in matrix inside M
metaDatetime = orthoFile.DateTime_Ams;
M.(csvName).SensorOnMat = timetable(sensorOn,'RowTimes',metaDatetime);

fprintf('sensor %s processed.\n',csvName);
end