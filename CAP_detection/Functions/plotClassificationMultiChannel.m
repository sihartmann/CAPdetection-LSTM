function [ ] = plotClassificationMultiChannel(eeg, list, ind, labels, prediction, fs, start, stop, annotations)

    % Get duration and set XTick frequency
    x_duration = stop - start;
    if x_duration > 60
        xtick_freq = 30;
    else
        xtick_freq = 10;
    end
   
    % Plot defined time segment of current channel
    x_max = max(max(abs(eeg.data(ind,start*fs+1:stop*fs))));
    for i = 1 : length(list)
        x = eeg.data(ind(i),start*eeg.info.frequency(ind(i))+1:stop*eeg.info.frequency(ind(i)));
        x_norm = x./max(abs(x));
        x_norm = x_norm + i*2 + 2;
        % Calculate time axis for the plot
        time_axis = linspace(start, stop, x_duration*eeg.info.frequency(ind(i))); 
        plot(time_axis,x_norm);
    end
    % Set axes limits of current plot            
    xlim([start stop]);
    ylim([0 length(list)*2+4]);
    % Set X- and Y-Lable of current plot
    y = ylabel('Channel','FontSize',18);
    set(y, 'Units', 'Normalized', 'Position', [-0.05, 0.5, 0]);
    ax = gca;
    ax.GridLineStyle = ':';
    % Calculate and set XTicks of current subplot (show actual time of
    % the measurement
    xticks = start:xtick_freq:(start+x_duration);
    t1 = datetime(datestr(seconds(eeg.scoringtime),'HH:mm:ss'),'InputFormat','HH:mm:ss');
    t2 = t1 + seconds(start);
    t3 = t2 + seconds(x_duration);
    xticklabels = t2:seconds(xtick_freq):t3;
    xticklabels.Format = 'HH:mm:ss';
    xticklabels = cellstr(xticklabels);
    set(gca,'XTick',xticks)
    set(gca,'XTickLabel',xticklabels,'FontSize',11);
    % Calculate and set YTicks of current subplot (show actual time of
    % the measurement
    yticks = 2:2:length(list)*2+2;
    yticklabels = ['Classification', list];
    set(gca,'YTick',yticks)
    set(gca,'YTickLabel',yticklabels,'FontSize',11);
    % Plot CAP and sleep stage events into the plotted data
    labels_tmp = labels(start+1:stop);
    pred_tmp = prediction(start+1:stop);
    diff_label = diff(labels_tmp>0);
    label_start = find(diff_label == 1)+start-1;
    label_stop = find(diff_label == -1)+start-1;
    y_label = 1*ones(1,size(label_start,2));
    h_scor = plot(label_start, y_label ,'Color','green','LineStyle','none','Marker','>');
    classes = mat2cell(labels(label_start+2),1,ones(1,length(label_start)));
    text(label_start,y_label*1.4,classes,'Color','green');
    y_label = 1*ones(1,size(label_stop,2));
    plot(label_stop, y_label ,'Color','green','LineStyle','none','Marker','<');
    diff_pred = diff(pred_tmp>0);
    pred_start = find(diff_pred == 1)+start-1;
    pred_stop = find(diff_pred == -1)+start-1;
    y_label = 2*ones(1,size(pred_start,2));
    h_class = plot(pred_start, y_label ,'Color','red','LineStyle','none','Marker','>');
    classes = mat2cell(prediction(pred_start+2),1,ones(1,length(pred_start)));
    text(pred_start,y_label*1.2,classes,'Color','red');
    y_label = 2*ones(1,size(pred_stop,2));
    plot(pred_stop, y_label ,'Color','red','LineStyle','none','Marker','<');
    if ~isempty(label_start) || ~isempty(pred_start)
        legend([h_class, h_scor], {'Classification', 'Scoring'},'Location','northeast');
    end
end