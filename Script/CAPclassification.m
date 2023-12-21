function [report] = CAPclassification(input, eeg, n, flags, report)


% Load classifier
if strcmp(flags.AgeGroup,'Children')
    classifier = load('TrainedCAPClassifier_28-02-2023_16-12.mat');
    class_trained = classifier.classifier.LSTM;
else
    classifier = load('TrainedCAPClassifier_28-02-2023_16-12.mat');
    class_trained = classifier.classifier.LSTM;
end

%% Prepare input
input = cellfun(@(x) x',input,'UniformOutput',false);
empty_target = cellfun(@(x) 0*x(1,:),input,'UniformOutput',false);
input = cellfun(@(x) normalize(x','medianiqr')',input,'UniformOutput',false);
%% Validation
output = class_trained.testClassifier(input, empty_target, false, false, false);
prediction = output(1:size(input,2));

% Sum of classification
pred = zeros(1,size(prediction{1},2));
pred_1 = zeros(1,size(prediction{1},2));
pred_2 = zeros(1,size(prediction{1},2));
pred_3 = zeros(1,size(prediction{1},2));
for k = 1 : numel(prediction)
    pred_1 = pred_1 + double(prediction{k}==1);
    pred_2 = pred_2 + double(prediction{k}==2);
    pred_3 = pred_3 + double(prediction{k}==3);
end
% Majority classification
majority_1 = pred_1 > floor(numel(prediction)/2);
majority_2 = pred_2 > floor(numel(prediction)/2);
majority_3 = pred_3 > floor(numel(prediction)/2);
pred = pred + majority_1 + 2*majority_2 + 3*majority_3;

x = [input{1}];

[pred_rec, x_rec] = labelReconstruction(eeg, pred, x, 30);
pred_rec = postProcessingMultiClass(pred_rec, x_rec);
for m = 1 : length(eeg.event)
    events_vec((m-1)*30+1:m*30) = eeg.event(m);
end
if  strcmp(flags.Scoring,'CAP')
    [pred_rec, CAP_start, CAP_stop] = CAPsequences(pred_rec, events_vec);
else
    CAP_start = [];
    CAP_stop = [];
end
stats  = getOutputStatistics(pred, pred_rec, CAP_start, CAP_stop, eeg.name);
report.Success = report.Success + 1;
if flags.Excel
    get_datetime = datestr(now,'dd-mmm-yyyy');
    file_list = dir(strcat(eeg.path,'Statistics\',get_datetime,'\'));
    if ~exist(strcat(eeg.path,'Statistics\',get_datetime,'\'),'dir')
        mkdir(strcat(eeg.path,'Statistics\',get_datetime,'\'));
    end
    varNames = {'ID','SLDUR','NRAPH','APHDUR','AVGAPHDUR','NRAPHPH','RAPHSL','NRA1','NRA2','NRA3','A1DUR','A2DUR','A3DUR','AVGA1DUR','AVGA2DUR','AVGA3DUR','RA1APH','RA2APH','RA3APH','RA1NRE','RA2NRE','RA3NRE','A1IND','A2IND','A3IND','NRCAP','CAPDUR','RCAPSL','AVGCAPDUR','AVGCYCLEDUR','AVGBPHADUR'};
    if n > 1
        excel_name = ['CAP_analysis',num2str(length(file_list)-2),'_',get_datetime,'.xlsx'];
        full_name = strcat(eeg.path,'Statistics\',get_datetime,'\',excel_name);
        statsTable = cell2table(stats,'VariableNames',varNames);
        writetable(statsTable,full_name,'WriteVariableNames',false,'Range',strcat('A',num2str(n+1),':AE',num2str(n+1)));  
    else
        if isempty(file_list)
            excel_name = ['CAP_analysis1_',get_datetime,'.xlsx'];
        else
            excel_name = ['CAP_analysis',num2str(length(file_list)-1),'_',get_datetime,'.xlsx'];
        end
        full_name = strcat(eeg.path,'Statistics\',get_datetime,'\',excel_name);
        statsTable = cell2table(stats,'VariableNames',varNames);
        writetable(statsTable,full_name);
        varNames2 = {'CAP Variables','Description'};
        varDescription = [  "subject's ID";...
                            "total duration of NREM sleep in seconds";...
                            "total number of A-phases";...
                            "total duration of A-phases in seconds";...
                            "average duration of A-phases in seconds";...
                            "number of A-phases per hour of NREM sleep";...
                            "total duration of A-phases/total duration of NREM sleep";...
                            "total number of A1-phases";...
                            "total number of A2-phases";...
                            "total number of A3-phases";...
                            "total duration of A1-phases in seconds";...
                            "total duration of A2-phases in seconds";...
                            "total duration of A3-phases in seconds";...
                            "average duration of A1-phases in seconds";...
                            "average duration of A2-phases in seconds";...
                            "average duration of A3-phases in seconds";...
                            "total number of A1-phases/total number of A-phases";...
                            "total number of A2-phases/total number of A-phases";...
                            "total number of A3-phases/total number of A-phases";...
                            "total duration of A1-phases/total duration of NREM sleep";...
                            "total duration of A2-phases/total duration of NREM sleep";...
                            "total duration of A3-phases/total duration of NREM sleep";...
                            "A1 index (number of A1-phases per hour)";...
                            "A2 index (number of A2-phases per hour)";...
                            "A3 index (number of A3-phases per hour)";...
                            "total number of CAP sequences";...
                            "total duration of CAP sequences in seconds";...
                            "CAP rate (percentage of NREM sleep occupied by CAP)";...
                            "average duration of CAP sequences in seconds";...
                            "average duration of CAP cycles in seconds";...
                            "average duration of B-phases in seconds"];
        infoTable = table(varNames',varDescription,'VariableNames',varNames2);
        writetable(infoTable,full_name,'Sheet',2);
    end
end

if flags.Plot
    if ~exist(strcat(eeg.path,'Plots\'),'dir')
        mkdir(strcat(eeg.path,'Plots\'));
    end
    filename = strcat(eeg.path,'Plots\',eeg.name);
    createScoringPlot(eeg, pred_rec, filename);
end

if flags.Text
    if ~exist(strcat(eeg.path,'Annotations\'),'dir')
        mkdir(strcat(eeg.path,'Annotations\'));
    end
    createAnnotationFile(eeg, pred_rec, strcat(eeg.path,'Annotations\'));
end
