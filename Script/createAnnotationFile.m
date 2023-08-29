function [] = createAnnotationFile(eeg, pred, save_path)

% Get all A phases
diff_pred = diff(pred>0);
pred_start = find(diff_pred == 1);
pred_stop = find(diff_pred == -1);
if length(pred_stop) < length(pred_start)
    pred_stop = [pred_stop length(pred)];
end
pred_duration = pred_stop - pred_start;

% Get classes
classes = mat2cell(pred(pred_start+2),1,ones(1,length(pred_start)));
classes = cellfun(@(x) strcat('A',num2str(x)), classes, 'UniformOutput', false);

% Get timestamps
t1 = datetime(datestr(seconds(eeg.scoringtime),'HH:MM:SS'),'InputFormat','HH:mm:ss');
time_labels = t1 + seconds(pred_start);
time_labels.Format = 'HH:mm:ss.SSS';
time_labels = cellstr(time_labels);

filename = strcat(save_path,eeg.name,'.txt');

fid = fopen(filename,'wt');
fprintf(fid, '%s\t%s\t%s\t%s\n', 'Time [hh:mm:ss.xxx]','Event','Duration(s)','Extra');
for i = 1 : length(time_labels)
    fprintf(fid, '%s\t%s\t%s\t\n', time_labels{i},classes{i},num2str(pred_duration(i)));
end
fclose(fid);
