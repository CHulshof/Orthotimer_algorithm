%% Orthotimer sensor analyses for multiple sensors

%% Change folder directory to directory with .csv files of Orthotimer sensor
folder_dir = 'C:\FOLDER_WITH_CSV_FILES';

% Add path of sensor folder
addpath(folder_dir);

% Select all .csv files in that folder
list_files_analysis = dir([folder_dir,'/*.csv']);

n = length(list_files_analysis);
for i = 1:2 %: n
    fprintf ('\nProcessing file %d of %d (%s)\n', i, n, list_files_analysis(i).name);
    Mtemp = Orthotimer_algorithm(list_files_analysis(i).name);
    Mname = fieldnames(Mtemp);
    M.(char(Mname)) = Mtemp.(char(Mname));
end
