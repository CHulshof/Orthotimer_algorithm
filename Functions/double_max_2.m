function [iMultiMax, maxIdx, maxminRemoved] = double_max_2(iMultiMax, maxIdx, locsAll, maxminRemoved, sensor, minIdx, firstMin)

% if double max indices are > 1h, keep MaxIdx based on temperature

%INPUT:
%   iMultiMax: zx1 double. indices of multiple consecutive maxima
%   maxIdx: mx1 double. indices of maxima in sensorSlope.
%   locsAll: ux2 double, indices of minima and maxima in sensorSlope. column 2
%   indicates a maxima (1) or minima (0).
%   sensor: nx1 double, orthotimer sensordata.
%   maxminRemoved: array with removed max and min values.
%   sensor: tx1 double. orthotimer data.
%   sampletime: orthotimer sample time in minutes.
%   minIdx: ux1 double. indices of minima in sensorSlope.
%   firstMin: 1x1 double. index of first minimum.

%OUTPUT:
%   iMultiMax: same as input but with double maxes removed.
%   maxIdx: same as input but with double maxes removed.
%   maxminRemoved: array with removed max and min values.

if ~isempty(iMultiMax)
    for r = 1 : size(iMultiMax,2)
        Maxx1 = iMultiMax(1,r);
        Maxx2 = iMultiMax(2,r);
        pmin = find(minIdx<Maxx1,1,'last');
        if isempty(pmin)
            if Maxx1>firstMin    
                MinI = firstMin;
            else
                MinI = 1;
            end
        else
            MinI=minIdx(pmin);
        end
        
        if abs(mean(sensor(MinI:Maxx1))-mean(sensor(Maxx1:Maxx2))) < 1
            iMatch3 = find(maxIdx==iMultiMax(1,r),1,'last'); % remove 1st MaxIdx
            maxIdx(iMatch3) = NaN;
            iMatchAll3 = find(locsAll(:,1)==iMultiMax(1,r),1,'last'); % find 1st MaxIdx in locs_all
            maxminRemoved(iMatchAll3) = 21; % save index for plot
            iMultiMax(1:2,r) = NaN; % remove from multiple
        elseif mean(sensor(MinI:Maxx1))<mean(sensor(Maxx1:Maxx2))
            iMatch3 = find(maxIdx==iMultiMax(2,r),1,'last'); % remove 2nd MaxIdx
            maxIdx(iMatch3) = NaN;
            iMatchAll3 = find(locsAll(:,1)==iMultiMax(2,r),1,'last'); % find 2nd MaxIdx in locs_all
            maxminRemoved(iMatchAll3) = 29; % save index for plot
            iMultiMax(1:2,r) = NaN; % remove from multiple
        else
            iMatch3 = find(maxIdx==iMultiMax(1,r),1,'last'); % remove 1st MaxIdx
            maxIdx(iMatch3) = NaN;
            iMatchAll3 = find(locsAll(:,1)==iMultiMax(1,r),1,'last'); % find 2nd MaxIdx in locs_all
            maxminRemoved(iMatchAll3) = 29; % save index for plot
            iMultiMax(1:2,r) = NaN; % remove from multiple
        end
    end
end
maxIdx = rmmissing(maxIdx);
iMultiMax = rmmissing(iMultiMax,2);