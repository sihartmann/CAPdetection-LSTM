% plotMultitaperSpectrum    Plot signal and multitaper spectrum for
%                           specific time period
%
% Usage:
%  >> SignalEEG.plotMultitaperSpectrum(signal, start, stop, fs, unit, overlap, CAP)  
%
% Inputs:
%       signal      = Original signal
%       start       = Starting second of time period
%       stop        = Ending second of time period
%       fs          = Sample rate of input signal
%       unit        = Magnitude unit of input signal (string)
%       overlap     = Overlap of between spectrum windows (between 0 and 1)
%       CAP         = Flag to indicate CAP events (true/false)
%
% See also: pmtm(), imagesc()

function [ ] = plotMultitaperSpectrum(this, signal, start, stop, fs, unit, overlap, CAP)
    % Cut signal to passed time period
    x = signal(start*fs+1:stop*fs);
    % Define Multitaper parameter
    bin_len = fs;
    n_bins = floor(length(x)/bin_len);
    % Start calculating the spectra for each window
    for i = 1 : 1/(1-overlap)*(n_bins-1)
        x_spec = x((i-1)*(1-overlap)*bin_len+1:(1+(i-1)*(1-overlap))*bin_len);
        [psd(:,i), ~] = pmtm(x_spec, 4,0:0.1:fs/4,this.fs,'unity');
    end
    % Create figure
    figure('Position',[350,300,1250,500]);
    subplot(2,1,1);
    hold on   
    grid on     
    % Plot original signal
    this.plotSignal(x, start, stop, fs, unit, CAP);
    % Plot Multitaper spectrum
    time_axis = start:(1-overlap):stop-(1+1-overlap);
    f_pm = 0:0.1:fs/4;
    subplot(2,1,2);
    imagesc(time_axis,f_pm,log(psd));
    colormap jet;
    colorbar;
    caxis([-15 15]);
    hold on;
    ylim([0 fs/4]);
    ylabel('Frequency [Hz]','FontSize',11);
    xlabel('Time [s]','FontSize',14);
    % Get duration and set XTick frequency
    x_duration = stop - start;
    if x_duration > 3599
        xtick_freq = 1800;
    elseif x_duration > 119
        xtick_freq = 60;
    else 
        xtick_freq = 10;
    end
    % Calculate and set XTicks of current subplot (show actual time of
    % the measurement
    xticks = start:xtick_freq:(start+x_duration);
    t1 = datetime(datestr(this.starttime/86400, 'HH:MM:SS'),'InputFormat','HH:mm:ss');
    t2 = t1 + seconds(start);
    t3 = t2 + seconds(x_duration);
    xticklabels = t2:seconds(xtick_freq):t3;
    xticklabels.Format = 'HH:mm:ss';
    xticklabels = cellstr(xticklabels);
    h = gca;
    set(h, 'YDir', 'normal');
    set(h,'XTick',xticks);
    set(h,'XTickLabel',xticklabels,'FontSize',11);         
end