function [maxIdx,minIdx,firstMax,lastMax,firstMin,lastMin] = check_24h(maxIdx,minIdx,sampletime,f)

% check if <24h between maxIdx and minIdx, if not, remove maxIdx.
% If there is no maxIdx before the minIdx, remove minIdx as well.

%INPUT:
%   maxIdx: mx1 double. indices of maxima in sensorSlope. m = number of maxima
%   minIdx: px1 double. indices of maxima in sensorSlope. p = number of minima
%   sampletime: 1x1 double. sampletime in minutes.
%   f: qx1 double. indices of gaps in sensor

%OUTPUT:
%   maxIdx: nx1 double. indices of maxima after removing >=24h between min and max. n = new number of maxima
%   minIdx: rx1 double. indices of minima after removing >=24h between min and max. r = new number of maxima
%   first_max, last_max: indices of first and last maxima.
%   first_min, last_min: indices of first and last minima.

firstMax=maxIdx(1,1);
lastMax=maxIdx(end,1);
firstMin=minIdx(1,1);
lastMin=minIdx(end,1);

% maxIdx relative to minIdx <24H
for m = 1 : length(maxIdx)
    maxI = maxIdx(m); % maxIdx
    pmin = find(minIdx>maxI,1,'first'); % first minIdx after MaxI
    minI = minIdx(pmin);
    if isempty (pmin)
        maxIdx(m:end,1)=NaN;
    elseif isempty(find((maxI<=f)-(minI<=f))) && (minI-maxI) < ((24*60)/sampletime) %the positive and negative peak are both bofore or after the same gaps.
       % do nothing 
    else % not within 24h or a gap in between
        maxIdx(m) = NaN; % remove maxIdx
    end
end
maxIdx = rmmissing(maxIdx);

% minIdx relative to maxIdx <24H
for n = 1 : length(minIdx)
    minI2 = minIdx(n); % maxIdx
    pmax = find(maxIdx<minI2,1,'last'); % first maxIdx before minIdx
    maxI2 = maxIdx(pmax);
    if isempty(pmax)
        minIdx(1:n,:)=NaN;
    elseif isempty(find((maxI2<=f)-(minI2<=f))) && (minI2-maxI2) < ((24*60)/sampletime) % within 24h
        % do nothing
    else % not within 24h or a gap in between
        minIdx(n) = NaN; % remove minIdx
    end
end
minIdx = rmmissing(minIdx);