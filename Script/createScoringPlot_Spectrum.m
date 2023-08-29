function [ ] = createScoringPlot_Spectrum(eeg,fs, overlap)

signal = eeg.eeg;
start = 0;
stop = length(signal)/fs;
% Define Multitaper parameter
bin_len = fs;
n_bins = floor(length(signal)/bin_len);
% Start calculating the spectra for each window
for i = 1 : 1/(1-overlap)*(n_bins-1)
    signal_spec = signal((i-1)*(1-overlap)*bin_len+1:(1+(i-1)*(1-overlap))*bin_len);
    [psd(:,i), ~] = pmtm(signal_spec, 4,0:0.1:fs/4,fs,'unity');
end
% Plot Multitaper spectrum
time_axis = start:(1-overlap):stop-(1+1-overlap);
f_pm = 0:0.1:fs/4;
imagesc(time_axis,f_pm,log(psd));
colormap jet;
colorbar;
caxis([-15 15]);
hold on;
ylim([0 fs/4]);
xlim([start stop]);
ylabel('Frequency [Hz]','FontSize',11);
xlabel('Time','FontSize',14);
% Get duration and set signalTick frequency
x_duration = stop - start;
xtick_freq = 3600;
% Calculate and set signalTicks of current subplot (show actual time of
% the measurement
xticks = start:xtick_freq:(start+x_duration);
t1 = datetime(datestr(eeg.starttime/86400, 'HH:MM:SS'),'InputFormat','HH:mm:ss');
t2 = t1 + seconds(start);
t3 = t2 + seconds(x_duration);
xticklabels = t2:seconds(xtick_freq):t3;
xticklabels.Format = 'HH:mm:ss';
xticklabels = cellstr(xticklabels);
h = gca;
set(h, 'YDir', 'normal');
set(h,'xTick',xticks);
set(h,'xTickLabel',xticklabels,'FontSize',11); 
