function [iMultiMax, iMultiMin, locsAll] = check_multiple_peaks(locsAll)

% This function checks if there are multiple MaxIdx / MinIdx in a row

%INPUT:
%   locsAll: ux2 double, indices of minima and maxima in sensorSlope. column 2
%   indicates a maxima (1) or minima (0);
%   sensor: nx1 double, orthotimer sensordata

%OUTPUT:
%   iMultiMax: zx1 double. indices of multiple consecutive maxima
%   iMultiMin: yx1 double. indices of multiple consecutive minima
%   locsAll:same as input

% maxIdx = matrix with all ON peaks
% minIdx = matrix with all OFF peaks 

% variables
multiple = NaN(length(locsAll),1); %matrix with indices multiple MaxIdx / MinIdx in a row
multipleCheck = NaN(length(locsAll),1); %for speed
iMultiMax = []; iMultiMin = [];

for i = 1:length(locsAll)-1
    if locsAll(i,2) == 0 && locsAll(i+1,2) == 1 % true
        multipleCheck(i) = 20; %min peak = 20
        
    elseif locsAll(i,2) == 1 && locsAll(i+1,2) == 0 % true
        
        multipleCheck(i) = 30; %max peak = 30
        
    elseif locsAll(i,2) == 1 && locsAll(i+1,2) == 1 % false, two consecutive positive peaks
        multiple(i) = 30;
        multiple(i+1) = 30;
        maxxi = [locsAll(i); locsAll(i+1)];
        iMultiMax = [iMultiMax, maxxi];% save indices
        
    elseif locsAll(i,2) == 0 && locsAll(i+1,2) == 0 % false, two consecutive negative peaks
        multiple(i) = 20;
        multiple(i+1) = 20;
        minni = [locsAll(i); locsAll(i+1)];
        iMultiMin = [iMultiMin, minni];% save indices
        
    end
end