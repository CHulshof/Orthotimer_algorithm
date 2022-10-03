function [locsAll]=peak_gap_first(maxIdx,minIdx,f)

% Check if there is a (series of) last positive peak(s) before a gap or first a (series of) negative peak(s) after a gap.

%INPUT:
%   maxIdx: mx1 double. indices of maxima in sensorSlope. m = number of minima.
%   minIdx: px1 double. indices of maxima in sensorSlope. p = number of minima
%   f: rx1 double. indices of gaps in sensor. r = number of gaps.

%OUTPUT:
%   locsAll: (m+p-o)x2 double combined max and minima indices. second
%   column has 0 for minima and 1 for maxima. o = number of removed
%   maxima+minima

locs1 = [maxIdx,ones(size(maxIdx,1),1)]; %on
locs2 = [minIdx,zeros(size(minIdx,1),1)]; %off

locsAll = sortrows([locs1;locs2],1); %combination locs 1 and locs 2

if ~isempty(f)
    for i=1:length(f) %cycle through gaps
        gapStart=f(i);
        lastPeakBeforeGap=find(locsAll(:,1)<=gapStart,1,'last'); %idx in locsAll of the last peak before this gap
        firstPeakAfterGap=find(locsAll(:,1)>gapStart,1,'first'); %idx in locsAll of the first peak after this gap
        %% check first last peak       
        if isempty(lastPeakBeforeGap) && isempty(firstPeakAfterGap) 
            %do nothing, there are no peaks
        elseif isempty(lastPeakBeforeGap) && ~isempty(firstPeakAfterGap) %there is only a peak after gap
            j=0; 
            while locsAll(firstPeakAfterGap+j,2)==0 %loop through next peaks of locsAll, while these are minima...
                locsAll(firstPeakAfterGap+j,2)=NaN;
                j=j+1;
            end
        elseif ~isempty(lastPeakBeforeGap) && isempty(firstPeakAfterGap) %only a peak before the gap
            j=0;
            while locsAll(firstPeakAfterGap-j,2)==0 %loop through next peaks of locsAll, while these are minima...
                locsAll(firstPeakAfterGap-j,2)=NaN; %set these peaks to NaN.
                j=j+1;
            end
            
        elseif ~isempty(lastPeakBeforeGap) && ~isempty(firstPeakAfterGap) %Both a peak before and after gap
            j=0;
            while locsAll(lastPeakBeforeGap-j,2)==1 %loop through next peaks of locsAll, while these are maxima...
                locsAll(lastPeakBeforeGap-j,2)=NaN; %set to nan
                j=j+1;
            end
            k=0;
            while locsAll(firstPeakAfterGap+k,2)==0 %loop through next peaks of locsAll, while these are minima...
                locsAll(firstPeakAfterGap+k,2)=NaN; %set to nan
                k=k+1;
            end
        end
    end
end
locsAll=rmmissing(locsAll); %remove all nans