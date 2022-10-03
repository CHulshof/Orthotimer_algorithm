function [iMultiMin, minIdx, maxminRemoved] = double_min_1h(iMultiMin, minIdx, locsAll, maxminRemoved, sampletime)

% if double min indices are within 1h, keep last MinIdx

%INPUT:
%   iMultiMin: zx1 double. indices of multiple consecutive minima.
%   minIdx: mx1 double. indices of minima in sensorSlope.
%   locsAll: ux2 double, indices of minima and maxima in sensorSlope. column 2
%   indicates a maxima (1) or minima (0).
%   sensor: nx1 double, orthotimer sensordata.
%   maxminRemoved: array to store removed max and min values.
%   sampletime: orthotimer sample time in minutes.

%OUTPUT:
%   iMultiMin: same as input but with double maxes removed.
%   minIdx: same as input but with double maxes removed.
%   maxminRemoved: array with removed max and min values.

if ~isempty(iMultiMin)
    for o = 1 : size(iMultiMin,2)
        if (iMultiMin(2,o) - iMultiMin(1,o)) <= (60/sampletime)
            iMatch2 = find(minIdx==iMultiMin(1,o),1,'last'); % find index in MinIdx of 1st MinIdx
            minIdx(iMatch2) = NaN; % remove 1st MinIdx
            iMatchAll2 = find(locsAll(:,1)==iMultiMin(1,o),1,'last'); % find 1st MinIdx in locs_all
            maxminRemoved(iMatchAll2) = 21; % save index for plot
            iMultiMin(1:2,o) = NaN; % remove from multiple
        end
    end
end
minIdx = rmmissing(minIdx);
iMultiMin = rmmissing(iMultiMin,2);
end