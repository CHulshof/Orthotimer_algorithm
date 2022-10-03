function [MaxIdx, MinIdx, p] = firstMax_lastMin(MaxIdx, MinIdx)

% first index should be a MaxIdx and last index should be a MinIdx

if isempty(MaxIdx)
elseif isempty(MinIdx)
else
    if MaxIdx(1) > MinIdx(1) % false
        MinIdx = MinIdx(2:end);
    elseif MaxIdx(1) < MinIdx(1) % true
    end
end

% last MinIdx
if isempty(MaxIdx)
elseif isempty(MinIdx)
else
    if MinIdx(end) > MaxIdx(end) % true
    elseif MinIdx(end) < MaxIdx(end) % true
        MaxIdx = MaxIdx(1:end-1);
    end
end

% matrix of MaxIdx and MinIdx
p = [MaxIdx, MinIdx];