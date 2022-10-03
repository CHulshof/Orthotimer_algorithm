function[maxima,maxIdx,minima,minIdx,dataInv,trueMinima] = determinationpeaks(sensorSlope,MPD,MPH_MAX,MPH_MIN)

% Find peaks (maxIdx) and minima (minIdx) of Orthotimer data.

%INPUT:
%   sensorSlope: (n-1)x1 double. slope of orthotimer measurements. n = number of measurements.
%   MPD: 1x1 double. minimal peak distance setting.
%   MPH_MAX: 1x1 double. minimal peak height for maxima
%   MPH_MIN: 1x1 double. minimal peak height for minima 

%OUTPUT:
%   maxima: mx1 double. slopes of peaks maxima. m = number of minima.
%   maxIdx: mx1 double. indices of maxima in sensorSlope.
%   minima: px1 double. slopes of peaks minima. p = number of minima.
%   minIdx: px1 double. indices of maxima in sensorSlope.
%   dataInv:(n-1)x1 double. inverse of sensorSlope.
%   trueMinima: px1 dboule. slopes of actual minima (instead of maxima of inverse sensorSlope)

[maxima,maxIdx] = findpeaks(sensorSlope(:,1),'MinPeakDistance',MPD,'MinPeakHeight',MPH_MAX); 
dataInv = (sensorSlope(:,1))*-1;    % Inverse data to find the minima

[minima,minIdx] = findpeaks(dataInv,'MinPeakDistance',MPD,'MinPeakHeight',MPH_MIN);
trueMinima = minima*-1;             % Inverse minima