**README - Orthotimer_algorithm.m**

**The Orthotimer algorithm can detect footwear use and non-use based on temperature data assessed with an Orhotimer sensor.**

This algorithm used the base of the validated Groningen algorithm (Lutjeboer and colleagues, 2018) to detect footwear use and non-use based on temperature data measured with an Orthotimer® sensor. In long-term measures it was found that donning and doffing peaks present in the temperature signals were missed by the original algorithm. The algorithm was then improved to overcome these detection errors. A new filtering technique using Fourier transformation and cut-off values to detect positive and negative peaks in the temperature slope curve are used. The improved algorithm was validated on 20 randomly selected participants from two different studies (n=40) using orthopaedic shoes with Orthotimer® sensors. Per participant, 10 days were selected, with proportional representation of all seasons, and accuracy of peak detection was assessed visually by two researchers independently. Both researchers confirmed correct peak detection using this improved algorithm. This improved algorithm is in this Github: Orthotimer_algorithm.m . We are interested in your experiences or any improvements.


INSTRUCTIONS

Include the "Orthotimer algorithm" folder including its sub folder (Functions) to your MATLAB path.

If the path is set, you can run Orthotimer_algorithm.m.



CONTENTS

Folder "Functions" contains functions used in Orthotimer_algorithm.m.

Main function -> [M] = Orthotimer_algorithm(file)

IMPORTANT -> Set time zone in line 23 (setTimeZone = 'Europe/Amsterdam'; %Set prefered time zone)

Multiple_sensors_analyses.m is an example script how to run Orthotimer_algorithm.m mulitiple times with different input files.



INPUT

file -> fill in the name of the csv file extracted from cloud.orthotimer.com as character, for example: 'E0-38-02-10-05-18-2D-FD_10_26_2021.csv'



OUTPUT

M -> matrix including:

M.(csvName).startdate     -> start date sensor (datetime)

M.(csvName).enddate       -> end date sensor (datetime)

M.(csvName).sampletime    -> sample time sensor (double)

M.(csvName).sensor        -> matrix with footwear on (=1) and footwear off (n=0) for each measurement (dependent on sample time) (double)

M.(csvName).dayTbl        -> day table with number of samples footwear on (n=1) per day (time footwear on are dependent on sample time) (timetable)

M.(csvName).dayTblHrs     -> day table with hours of wearing time per day (adjusted for sampletime) (timetable)

M.(csvName).SensorOnMat   -> table with footwear on (=1) and footwear off (n=0) for each measurement (dependent on sample time) (timetable)



FUNCTIONS

In order of script:

- lowpassfilter.m			-> Applies lowpass filter to sensor 
- determinationpeaks.m			-> Find peaks (maxIdx) and minima (minIdx) of Orthotimer data
- check_24h.m				-> Check if <24h between maxIdx and minIdx, if not, remove maxIdx. If there is no maxIdx before the minIdx, remove minIdx as well.

% Below functions are run twice in Orthotimer_algorithm.m
- peak_gap_first.m			-> Check if there is a (series of) last positive peak(s) before a gap or first a (series of) negative peak(s) after a gap.
- check_multiple_peaks.m		-> Check if there are multiple MaxIdx / MinIdx in a row
- double_max_1h.m			-> If double max indices are within 1h, keep first MaxIdx
- double_min_1h.m			-> If double min indices are within 1h, keep last MinIdx
- double_max_2.m			-> If double max indices are > 1h, keep MaxIdx based on temperature
- double_min_2.m			-> If double min indices are > 1h, keep MinIdx based on temperature
- peak_gap_second.m			-> Check if there is a (serie) last positive peak(s) before a gap or first a (serie) negative peak(s) after a gap

% Ends here

- firstMax_lastMin			-> First index should be a MaxIdx and last index should be a MinIdx



ADDITIONAL INFORMATION

We developed a script to combine wearing time of multiple sensors of one patient/participant. This script can be useful when a patient/participant has for example multiple pairs of footwear.

Please feel free to contact us for more information: innovatie@podotherapeut.nl, c.m.hulshof@amsterdamumc.nl. or j.j.vannetten@amsterdamumc.nl



REFERENCES

Link to Orthotimer site:

- https://orthotimer.com/en/

Original Groningen Algorithm:

- Lutjeboer T, Van Netten JJ, Postema K, Hijmans JM. Validity and feasibility of a temperature sensor for measuring use and non-use of orthopaedic footwear. J Rehabil Med. 2018;50(10):920–6. 



CONTRIBUTORS

Thijs Lutjeboer
Jaap J. van Netten
Klaas Postema
Juha M. Hijmans
Laurens van Kouwenhove
Stein H. Exterkate
Chantal M. Hulshof
Floris Rotteveel
Kim A. Tijhuis
