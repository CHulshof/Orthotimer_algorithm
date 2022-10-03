function [maxIdx,minIdx]=peak_gap_second(maxIdx,minIdx,f)

% check if there is a (serie) last positive peak(s) before a gap or first a (serie) negative peak(s) after a gap.

%INPUT:
%   maxIdx: mx1 double. indices of maxima in sensorSlope. m = number of minima.
%   minIdx: px1 double. indices of maxima in sensorSlope. p = number of minima
%   f: rx1 double. indices of gaps in sensor. r = number of gaps.

%OUTPUT:
%   maxIdx: mx1 double. indices of maxima in sensorSlope. m = number of minima.
%   minIdx: px1 double. indices of maxima in sensorSlope. p = number of minima   
%   locsAll: (m+p-o)x2 double combined max and minima indices. second
%   column has 0 for minima and 1 for maxima. o = number of removed
%   maxima+minima

maxIdx(:,2)=1;
minIdx(:,2)=0;
locsAll = sortrows([maxIdx;minIdx],1);
if ~isempty(f)
    for i=1:length(f)
        gap_start=f(i);
        lastPeakBeforeGap=find(locsAll(:,1)<=gap_start,1,'last');
        firstPeakAfterGap=find(locsAll(:,1)>gap_start,1,'first');
        %% check first last peak       
        if isempty(lastPeakBeforeGap) && ~isempty(firstPeakAfterGap)
            j=0;
            while locsAll(firstPeakAfterGap+j,2)==0
                locsAll(firstPeakAfterGap+j,2)=NaN;
                j=j+1;
            end
        elseif ~isempty(lastPeakBeforeGap) && isempty(firstPeakAfterGap)
            j=0;
            while locsAll(firstPeakAfterGap-j,2)==0
                locsAll(firstPeakAfterGap-j,2)=NaN;
                j=j+1;
            end
            
        elseif ~isempty(lastPeakBeforeGap) && ~isempty(firstPeakAfterGap)
            j=0;
            while locsAll(lastPeakBeforeGap-j,2)==1
                locsAll(lastPeakBeforeGap-j,2)=NaN;
                j=j+1;
            end
            k=0;
            while locsAll(firstPeakAfterGap+k,2)==0
                locsAll(firstPeakAfterGap+k,2)=NaN;
                k=k+1;
            end
        end
    end
end
locsAll=rmmissing(locsAll);
maxIdx=locsAll(locsAll(:,2)==1,1);
minIdx=locsAll(locsAll(:,2)==0,1);