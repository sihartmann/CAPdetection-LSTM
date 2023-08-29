% plotSignal    Plot signal in defined figure environment
%
% Usage:
%  >> SignalEEG.plotSignal(signal, start, stop, fs, unit, CAP)  
%
% Inputs:
%       signal      = Original signal
%       start       = Starting second of time period
%       stop        = Ending second of time period
%       fs          = Sample rate of input signal
%       unit        = Magnitude unit of input signal
%       CAP         = Flag to indicate CAP events
%
% See also: plot()

function [ ] = plotSignal(this, x, start, stop, fs, unit, CAP)

    % Calculate minimum and maximum limit of data
    min_data = min(x);
    max_data = max(x);
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
    plot(time_axis, x);
    % Set axes limits of current plot            
    xlim([start stop]);
    ylim([min_data*0.95 max_data*1.05]);
    % Set X- and Y-Lable of current plot
    xlabel('Time [s]','FontSize',14);
    ylabel(['Magnitude [', unit,']'],'FontSize',11);
    % Calculate and set XTicks of current subplot (show actual time of
    % the measurement
    xticks = start:xtick_freq:(start+x_duration);
    t1 = datetime(datestr(this.starttime/86400, 'HH:MM:SS'),'InputFormat','HH:mm:ss');
    t2 = t1 + seconds(start);
    t3 = t2 + seconds(x_duration);
    xticklabels = t2:seconds(xtick_freq):t3;
    xticklabels.Format = 'HH:mm:ss';
    xticklabels = cellstr(xticklabels);
    set(gca,'XTick',xticks)
    set(gca,'XTickLabel',xticklabels,'FontSize',11);
    % Plot CAP and sleep stage events into the plotted data
    if CAP
        [ tmp_event, tmp_timestamp, tmp_duration, ~ ] = this.extractPeriodInfo(start, stop);
        for i = 1 : length(tmp_event)
            if tmp_event(i) > 5
                CAP_begin = tmp_timestamp(i);
                CAP_end = tmp_timestamp(i) + tmp_duration(i);
                line([CAP_begin CAP_begin], [min_data*0.95 max_data*1.05],'Color','green','LineStyle','--','LineWidth',2);
                if tmp_event(i) == 6
                    text(CAP_begin+1, max_data*0.9,'A1','Color','green');
                elseif tmp_event(i) == 7
                    text(CAP_begin+1, max_data*0.9,'A2','Color','green');
                elseif tmp_event(i) == 8
                    text(CAP_begin+1, max_data*0.9,'A3','Color','green');
                end
                if CAP_end <= stop
                    line([CAP_end CAP_end], [min_data*0.95 max_data*1.05], 'Color','green','LineStyle','--','LineWidth',2);
                end
            end
        end
    end 
end