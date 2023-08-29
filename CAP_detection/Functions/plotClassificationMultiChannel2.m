function [ ] = plotClassificationMultiChannel2(eeg, list, ind, labels, prediction, fs, start, stop, annotations)


    % Get duration and set XTick frequency
    x_duration = stop - start;
    if x_duration > 60
        xtick_freq = 60;
    else
        xtick_freq = 10;
    end
   
    % Plot defined time segment of current channel
    x_max = max(max(abs(eeg.data(ind,start*fs+1:stop*fs))));
    for i = 1 : length(list)
        x = eeg.data(ind(i),start*eeg.info.frequency(ind(i))+1:stop*eeg.info.frequency(ind(i)));
        x_norm = x./max(abs(x));
        x_norm = x_norm + i*2 + 6;
        % Calculate time axis for the plot
        time_axis = linspace(start, stop, x_duration*eeg.info.frequency(ind(i))); 
        plot(time_axis,x_norm, 'LineWidth',1,'Color','blue');
    end
    % Set axes limits of current plot            
    xlim([start stop]);
    ylim([0 length(list)*2+8]);
    % Set X- and Y-Lable of current plot
    %y = ylabel('Channel','FontSize',18);
%     set(y, 'Units', 'Normalized', 'Position', [-0.05, 0.5, 0]);
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
    set(gca,'XTickLabel',xticklabels,'FontSize',16);
    % Calculate and set YTicks of current subplot (show actual time of
    % the measurement
    yticks = [1,1.33,1.66,2,2.75,3.25,4,4.4,4.8,5.2,5.6,6,8,10,12];
    yticklabels = ['Non-CAP','A1','A2','A3','Non-Arousal','Arousal','Stage 0','Stage 1','Stage 2','Stage 3','Stage 4','Stage 5', list];
    set(gca,'YTick',yticks)
    set(gca,'YTickLabel',yticklabels,'FontSize',18);
    
    %% Plot sleep staging
    for i = 1 : length(eeg.event)
        sleep_stages((i-1)*30+1:i*30) = eeg.event(i);
    end
    sleep_stages_tmp = sleep_stages(start+1:stop);
    sleep_stages_tmp = sleep_stages_tmp./5*2;
    sleep_stages_tmp = sleep_stages_tmp + 4;
    % Calculate time axis for the plot
    time_axis = linspace(start, stop, x_duration); 
    plot(time_axis,sleep_stages_tmp,'LineWidth',2,'Color','green');   
    
    arousal_tmp = eeg.arousals(start+1:stop);
    arousal_tmp = arousal_tmp./1*0.5;
    arousal_tmp = arousal_tmp + 2.75;
    % Calculate time axis for the plot
    time_axis = linspace(start, stop, x_duration); 
    plot(time_axis,arousal_tmp,'LineWidth',2,'Color','magenta'); 
    
    cap_tmp = prediction(start+1:stop);
    cap_tmp = cap_tmp./3;
    cap_tmp = cap_tmp + 1;
    % Calculate time axis for the plot
    time_axis = linspace(start, stop, x_duration); 
    plot(time_axis,cap_tmp,'LineWidth',2,'Color',[0.5 0 0]);
    
    %% Plot CAP and sleep stage events into the plotted data
%     arousals_tmp = eeg.arousals(start+1:stop);
%     pred_tmp = prediction(start+1:stop);
%     diff_arousals = diff(arousals_tmp>0);
%     arousals_start = find(diff_arousals == 1)+start-1;
%     arousals_stop = find(diff_arousals == -1)+start-1;
%     y_label = 4*ones(1,size(arousals_start,2));
%     h_scor = plot(arousals_start, y_label ,'Color','green','LineStyle','none','Marker','>');
% %     classes = mat2cell(eeg.arousals(arousals_start+2),1,ones(1,length(arousals_start)));
% %     text(arousals_start,y_label*1.4,classes,'Color','green');
%     y_label = 4*ones(1,size(arousals_stop,2));
%     plot(arousals_stop, y_label ,'Color','green','LineStyle','none','Marker','<');
%     diff_pred = diff(pred_tmp>0);
%     pred_start = find(diff_pred == 1)+start-1;
%     pred_stop = find(diff_pred == -1)+start-1;
%     y_label = 2*ones(1,size(pred_start,2));
%     h_class = plot(pred_start, y_label ,'Color','red','LineStyle','none','Marker','>');
%     classes = mat2cell(prediction(pred_start+2),1,ones(1,length(pred_start)));
%     text(pred_start,y_label*1.2,classes,'Color','red');
%     y_label = 2*ones(1,size(pred_stop,2));
%     plot(pred_stop, y_label ,'Color','red','LineStyle','none','Marker','<');
% %     if ~isempty(label_start) || ~isempty(pred_start)
% %         legend([h_class, h_scor], {'Classification', 'Scoring'},'Location','northeast');
% %     end
end