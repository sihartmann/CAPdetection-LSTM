function [ ] = createScoringPlot_Signal(eeg,fs,unit)

start = 0;
stop = length(eeg.eeg)/fs;
x = eeg.eeg;
% Get duration and set XTick frequency
x_duration = stop - start;
xtick_freq = 3600;

% Calculate minimum and maximum limit of data
min_data = min(x);
max_data = max(x);

% Calculate time axis for the plot
time_axis = linspace(start, stop, x_duration*fs);
% Plot defined time segment of current channel
plot(time_axis, x);
% Set axes limits of current plot            
xlim([start stop]);
ylim([min_data*1.05 max_data*1.05]);
% Set X- and Y-Lable of current plot
% xlabel('Time [s]','FontSize',14);
ylabel('Magnitude [uV]','FontSize',11);
title(eeg.name,'FontSize',14);

% Plot CAP and sleep stage events into the plotted data
% pred_tmp = prediction;
% diff_pred = diff(pred_tmp>0);
% pred_start = find(diff_pred == 1)+1;
% pred_stop = find(diff_pred == -1);
% y_min = min_data*1.05*ones(1,size(pred_start,2));
% y_max = max_data*1.05*ones(1,size(pred_start,2));
% line([pred_start; pred_start], [y_min; y_max] ,'Color','red','LineStyle','--');
% line([pred_stop; pred_stop], [y_min; y_max] ,'Color','red','LineStyle','--');
% classes = mat2cell(prediction(pred_start),1,ones(1,length(pred_start)));
% text(pred_start+1,y_max,classes,'Color','red');

% Calculate and set XTicks of current subplot (show actual time of
% the measurement
xticks = start:xtick_freq:(start+x_duration);
t1 = datetime(datestr(eeg.starttime/86400, 'HH:MM:SS'),'InputFormat','HH:mm:ss');
t2 = t1 + seconds(start);
t3 = t2 + seconds(x_duration);
xticklabels = t2:seconds(xtick_freq):t3;
xticklabels.Format = 'HH:mm:ss';
xticklabels = cellstr(xticklabels);
set(gca,'XTick',xticks)
set(gca,'XTickLabel',[]);

