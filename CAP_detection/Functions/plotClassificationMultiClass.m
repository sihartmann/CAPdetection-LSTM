function [ ] = plotClassificationMultiClass(x, labels, prediction, fs, start, stop, starttime)

    % Get duration and set XTick frequency
    x_duration = stop - start;
    if x_duration > 3599
        xtick_freq = 1800;
    elseif x_duration > 119
        xtick_freq = 60;
    else 
        xtick_freq = 10;
    end
    % Calculate time axis for the plot
    time_axis = linspace(start, stop, x_duration*fs);
    % Plot defined time segment of current channel
    plot(time_axis, x(start*fs+1:stop*fs));
    min_data = min(x(start*fs+1:stop*fs));
    max_data = max(x(start*fs+1:stop*fs));
    % Set axes limits of current plot            
    xlim([start stop]);
    ylim([min_data*0.95 max_data*1.3]);
    % Set X- and Y-Lable of current plot
    y = ylabel('$\mu$V','FontSize',14,'interpreter','latex');
    set(y, 'Units', 'Normalized', 'Position', [-0.025, 0.5, 0]);
    ax = gca;
    ax.GridLineStyle = ':';
    % Calculate and set XTicks of current subplot (show actual time of
    % the measurement
    xticks = start:xtick_freq:(start+x_duration);
    t1 = datetime(datestr(starttime/86400, 'HH:MM:SS'),'InputFormat','HH:mm:ss');
    t2 = t1 + seconds(start);
    t3 = t2 + seconds(x_duration);
    xticklabels = t2:seconds(xtick_freq):t3;
    xticklabels.Format = 'HH:mm:ss';
    xticklabels = cellstr(xticklabels);
    set(gca,'XTick',xticks)
    set(gca,'XTickLabel',xticklabels,'FontSize',11);
    % Plot CAP and sleep stage events into the plotted data
    labels_tmp = labels(start+1:stop);
    pred_tmp = prediction(start+1:stop);
    diff_label = diff(labels_tmp>0);
    label_start = find(diff_label == 1)+start-1;
    label_stop = find(diff_label == -1)+start-1;
    y_label = max_data*1.1*ones(1,size(label_start,2));
    plot(label_start, y_label ,'Color','green','LineStyle','none','Marker','>');
    classes = mat2cell(labels(label_start+2),1,ones(1,length(label_start)));
    text(label_start,y_label*0.85,classes,'Color','green');
    y_label = max_data*1.1*ones(1,size(label_stop,2));
    plot(label_stop, y_label ,'Color','green','LineStyle','none','Marker','<');
    diff_pred = diff(pred_tmp>0);
    pred_start = find(diff_pred == 1)+start-1;
    pred_stop = find(diff_pred == -1)+start-1;
    y_label = max_data*1.3*ones(1,size(pred_start,2));
    plot(pred_start, y_label ,'Color','red','LineStyle','none','Marker','>');
    classes = mat2cell(prediction(pred_start+2),1,ones(1,length(pred_start)));
    text(pred_start,y_label*1.15,classes,'Color','red');
    y_label = max_data*1.3*ones(1,size(pred_stop,2));
    plot(pred_stop, y_label ,'Color','red','LineStyle','none','Marker','<');
end