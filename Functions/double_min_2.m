function [iMultiMin, minIdx, maxminRemoved] = double_min_2(iMultiMin, minIdx, MaxIdx, locsAll, maxminRemoved, sensor, lastMax)

% if double max indices are > 1h, keep MinIdx based on temperature

%INPUT:
%   iMultiMin: zx1 double. indices of multiple consecutive minima.
%   minIdx: mx1 double. indices of minima in sensorSlope.
%   maxIdx: mx1 double. indices of maxima in sensorSlope.
%   locsAll: ux2 double, indices of minima and maxima in sensorSlope. column 2
%   indicates a maxima (1) or minima (0).
%   sensor: nx1 double, orthotimer sensordata.
%   maxminRemoved: array with removed max and min values.
%   sensor: tx1 double. orthotimer data.
%   sampletime: orthotimer sample time in minutes.
%   minIdx: ux1 double. indices of minima in sensorSlope.
%   lastMax: 1x1 double. index of last maximum.

%OUTPUT:
%   iMultiMin: same as input but with double minis removed.
%   minIdx: same as input but with double minis removed.
%   maxminRemoved: array with removed max and min values.

if ~isempty(iMultiMin)
    for r = 1 : size(iMultiMin,2)
        Minn1 = iMultiMin(1,r);
        Minn2 = iMultiMin(2,r);
        pmax = find(MaxIdx>Minn1,1,'first');
        if isempty(pmax)
            if Minn1<lastMax
                MaxI=lastMax;
            else
                MaxI=length(sensor);
            end
        else
            MaxI = MaxIdx(pmax);
        end
        
        if abs(mean(sensor(Minn1:Minn2))-mean(sensor(Minn2:MaxI))) < 1
            iMatch3 = find(minIdx==iMultiMin(2,r),1,'last'); % remove 2nd MinIdx
            minIdx(iMatch3) = NaN;
            iMatchAll3 = find(locsAll(:,1)==iMultiMin(2,r),1,'last'); % find 2nd MinIdx in locs_all
            maxminRemoved(iMatchAll3) = 21; % save index for plot
            iMultiMin(1:2,r) = NaN; % remove from multiple
        elseif mean(sensor(Minn1:Minn2))>mean(sensor(Minn2:MaxI))
            iMatch3 = find(minIdx==iMultiMin(1,r),1,'last'); % remove 1st MinIdx
            minIdx(iMatch3) = NaN;
            iMatchAll3 = find(locsAll(:,1)==iMultiMin(1,r),1,'last'); % find 2nd MinIdx in locs_all
            maxminRemoved(iMatchAll3) = 21; % save index for plot
            iMultiMin(1:2,r) = NaN; % remove from multiple
        else
            iMatch3 = find(minIdx==iMultiMin(2,r),1,'last'); % remove 2nd MinIdx
            minIdx(iMatch3) = NaN;
            iMatchAll3 = find(locsAll(:,1)==iMultiMin(2,r),1,'last'); % find 2nd MinIdx in locs_all
            maxminRemoved(iMatchAll3) = 21; % save index for plot
            iMultiMin(1:2,r) = NaN; % remove from multiple
        end
    end
end
minIdx = rmmissing(minIdx);
iMultiMin = rmmissing(iMultiMin,2);