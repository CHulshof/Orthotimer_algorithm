function[filtSensor] = lowpassfilter(sensor,sampletime,Fc)

% Applies lowpass filter to sensor 

%INPUT: 
%   sensor: nx1 double. the sensor signal that needs to be filtered. n=number of samples 
%   sampletime: 1x1 double. the number of minutes per sample
%   Fc: 1x1 double. cutoff frequency

%OUTPUT:
%   filtSensor: filtered signal

%%
n=4; %order of the filter
Fs = 1/(60*sampletime); % sample frequency in Hz.
[b,a]=butter(n,Fc/(Fs/2),'low'); %normalized butter values..
filtSensor=filtfilt(b,a,sensor); %filtered signal.