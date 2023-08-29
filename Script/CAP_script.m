%% Initialization
% Set path to sleep recordings
file_path = 'C:\path\to\folder\with\eegfiles\';
% Select files
% Individually
% [file_list, file_path]=uigetfile({'*.edf';'*.rec'}, 'File Selector','MultiSelect', 'on');
% Or entire folder
file_list = dir(strcat(file_path,'*.edf'));
if isempty(file_list)
    file_list = dir(strcat(file_path,'*.rec'));
end
file_list = {file_list(1:length(file_list)).name};
            
% Set channels
%channels = {{'C4A1'};{'C3A2'}};
% Or derivations 
channels = {{'EEGC4','EEG94'},{'EEGC3','EEG190'}};

n = length(file_list); 
fprintf("#####\n%d subjects will be scored. Loading each edf file will take some time.\nThe progress bar below will show an update on the current status.\nA full scoring report will be provided at the end of the analysis.\n",n);
pause(.5);
% Initialize report
report = struct;
report.Success = 0;
report.WrongChannel = 0;
report.NoStageScoring = 0;
report.NoECG = 0;
report.Error = 0;
report.ErrorFiles = {};

% Set flags
CFA_flag = true;
flags.AgeGroup = 'Adults';
flags.Scoring = 'CAP';
flags.Excel = true;
flags.Plot = false;
flags.Text = true;
%% Start scoring
for i = 1:n
    disp('####');
    disp(strcat('Processing dataset: ',file_list{i})); 
    report.Stop = false;
    if CFA_flag
        header = edfread(strcat(file_path, file_list{i}));
        % Find ECG channel
        [ECGlabel, CFA_flag, report] = findECGchannel(header, CFA_flag, report);
        channel_list = horzcat(channels{:});
        channel_list{end+1} = ECGlabel;
    else
        channel_list = horzcat(channels{:});
    end
    try
        eeg = SignalEEG(file_path, file_list{i}, '', 'True', channel_list);
    catch
        report.Error = report.Error + 1;
        report.NoStageScoring = report.NoStageScoring + 1;
        report.ErrorFiles{end+1} = file_list{i};
        report.Stop = true;
    end
    for j = 1 : length(channels)
        if ~report.Stop
            % If derivations
            [input{j}, report, eeg, CFA_flag] = preProcessingDerivation(channels{j}, eeg, CFA_flag, report);
            % If channels
            %[input{j}, report, eeg, CFA_flag] = preProcessingChannel(channels{j}, eeg, CFA_flag, report);
        end
    end
    if ~report.Stop
        [report] = CAPclassification(input, eeg, i, flags, report);
    end
    report.EEG = [];
end
fprintf("#####\n%d subjects were successfully scored.\n%d subjects could not be scored.\n%d subjects did not have a sleep staging annotation file.\n%d subjects did not contain the selected derivations.\n%d subjects did not contain an ECG for CFA removal.\nFollowing subjects could not be scored: %s\n",report.Success, report.Error, report.NoStageScoring, report.WrongChannel, report.NoECG, strjoin(report.ErrorFiles,', '));
