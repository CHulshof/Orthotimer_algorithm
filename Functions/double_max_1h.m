function [iMultiMax, maxIdx, maxminRemoved] = double_max_1h(iMultiMax, maxIdx, locsAll, maxminRemoved, sampletime)

% if double max indices are within 1h, keep first MaxIdx

%INPUT:
%   iMultiMax: zx1 double. indices of multiple consecutive maxima
%   maxIdx: mx1 double. indices of maxima in sensorSlope.
%   locsAll: ux2 double, indices of minima and maxima in sensorSlope. column 2
%   indicates a maxima (1) or minima (0).
%   sensor: nx1 double, orthotimer sensordata.
%   maxminRemoved: array to store removed max and min values.
%   sampletime: orthotimer sample time in minutes.

%OUTPUT:
%   iMultiMax: same as input but with double maxes removed.
%   maxIdx: same as input but with double maxes removed.
%   maxminRemoved: array with removed max and min values.

if ~isempty(iMultiMax)
    for n = 1:size(iMultiMax,2)
        if (iMultiMax(2,n) - iMultiMax(1,n)) <= (60/sampletime) %check whether these values are within one hour.
            i_match = find(maxIdx==iMultiMax(2,n),1,'last'); % find index in maxIdx of 2nd maxIdx
            maxIdx(i_match) = NaN; % remove 2nd maxidx
            i_match_all = find(locsAll(:,1)==iMultiMax(2,n),1,'last'); % find 2nd maxIdx in locsAll
            maxminRemoved(i_match_all) = 29; % save index for plot
            iMultiMax(1:2,n) = NaN; % remove from multiple
        end
    end
end
maxIdx = rmmissing(maxIdx);
iMultiMax = rmmissing(iMultiMax,2);