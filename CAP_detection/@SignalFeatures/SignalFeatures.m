classdef SignalFeatures
%SignalFeatures: The class SignalFeatures contains all methods to extract
%specific features from an EEG signal to classify particular events in the
%recordings

    properties
    end
    methods(Static)
        
        function [descriptor] = getFeaturesPaper(signal, fs, event, duration, eventtime)
            % Calculate power descriptors of each band
            [~,~,delta] =  evalc("extractEEGBands(signal,fs,'delta');");
            [~,~,theta] =  evalc("extractEEGBands(signal,fs,'theta');");
            [~,~,alpha] =  evalc("extractEEGBands(signal,fs,'alpha');");
            [~,~,sigma] =  evalc("extractEEGBands(signal,fs,'sigma');");
            [~,~,beta] =  evalc("extractEEGBands(signal,fs,'beta');");

            % 1. Feature: Hjorth Activity (3 second window, 66% overlap => 1 second
            % values)
            descriptor(:,1) = SignalFeatures.getHjorthActivity(delta,fs,3);

            % 2. Feature: Shannon Entropy (2 second window, 50% overlap => 1 second
            % values)
            descriptor(:,2) = SignalFeatures.getShannonMATLAB(signal,fs,2);

            % 3. Feature: TEO (for each band, average value in one second windows)
            descriptor(:,3) = SignalFeatures.getTEO(delta,fs);
            descriptor(:,4) = SignalFeatures.getTEO(theta,fs);
            descriptor(:,5) = SignalFeatures.getTEO(alpha,fs);
            descriptor(:,6) = SignalFeatures.getTEO(sigma,fs);
            descriptor(:,7) = SignalFeatures.getTEO(beta,fs);

            % 4. Feature: Band Power Feature (for each band, smoothing off for delta band)
            descriptor(:,8) = SignalFeatures.getPowerBandFeature(delta, fs, false);
            descriptor(:,9) = SignalFeatures.getPowerBandFeature(theta, fs, true);
            descriptor(:,10) = SignalFeatures.getPowerBandFeature(alpha, fs, true);
            descriptor(:,11) = SignalFeatures.getPowerBandFeature(sigma, fs, true);
            descriptor(:,12) = SignalFeatures.getPowerBandFeature(beta, fs, true);

            % 5. Feature: EEG variance difference (1 second window, 50% overlap => 1 second
            % values)
            descriptor(:,13) = SignalFeatures.getEEGVarDiff(signal,fs);

            % 6. Feature: Time Feature
            descriptor(:,14) = SignalFeatures.getDistance(signal, fs, event, duration, eventtime);   
        end

        function [descriptor] = getFeaturesPaperOLD(signal, fs)
            % Calculate power descriptors of each band
            [~,~,delta] =  evalc("extractEEGBands(signal,fs,'delta');");
            [~,~,theta] =  evalc("extractEEGBands(signal,fs,'theta');");
            [~,~,alpha] =  evalc("extractEEGBands(signal,fs,'alpha');");
            [~,~,sigma] =  evalc("extractEEGBands(signal,fs,'sigma');");
            [~,~,beta] =  evalc("extractEEGBands(signal,fs,'beta');");

            % 1. Feature: Hjorth Activity (3 second window, 66% overlap => 1 second
            % values)
            descriptor(:,1) = SignalFeatures.getHjorthActivity(delta,fs,3);

            % 2. Feature: Shannon Entropy (2 second window, 50% overlap => 1 second
            % values)
            descriptor(:,2) = SignalFeatures.getShannonMATLAB(signal,fs,2);

            % 3. Feature: TEO (for each band, average value in one second windows)
            descriptor(:,3) = SignalFeatures.getTEO(delta,fs);
            descriptor(:,4) = SignalFeatures.getTEO(theta,fs);
            descriptor(:,5) = SignalFeatures.getTEO(alpha,fs);
            descriptor(:,6) = SignalFeatures.getTEO(sigma,fs);
            descriptor(:,7) = SignalFeatures.getTEO(beta,fs);

            % 4. Feature: Band Power Feature (for each band, smoothing off for delta band)
            descriptor(:,8) = SignalFeatures.getPowerBandFeature(delta, fs, false);
            descriptor(:,9) = SignalFeatures.getPowerBandFeature(theta, fs, true);
            descriptor(:,10) = SignalFeatures.getPowerBandFeature(alpha, fs, true);
            descriptor(:,11) = SignalFeatures.getPowerBandFeature(sigma, fs, true);
            descriptor(:,12) = SignalFeatures.getPowerBandFeature(beta, fs, true);

            % 5. Feature: EEG variance difference (1 second window, 50% overlap => 1 second
            % values)
            descriptor(:,13) = SignalFeatures.getEEGVarDiff(signal,fs);
        end
        
        function [descriptor] = getFeaturesSpectrogram(signal, fs)

            % Calculate Multitaper spectrum (4 second window, 50% overlap => 1 second
            % values)
            descriptor = SignalFeatures.getSpectrogram(signal,fs,4); 
        end
        
        function [descriptor] = getFeaturesSignal(signal, fs)

            % Calculate Multitaper spectrum (2 second window, 50% overlap => 1 second
            % values)
            descriptor = SignalFeatures.getSignal(signal,fs); 
        end
        
        function [hjorth_max] = getHjorthActivity(signal, fs, overlap)
        % getHjorthActivity() -  Calculate Hjorth activity of EEG signal in 
        %                        overlapping windows
        % Usage:
        %  >> [hjorth_max] = getHjorthActivity(signal,fs,t)
        %
        % Inputs:
        %   signal        = raw EEG signal
        %   fs            = sample rate in Hz
        %   overlap       = window length
        %
        % Outputs:
        %   hjorth_max    = hjorth activity sampled in 1 Hz
        %
        % See also: var()    

            for i = fs:fs:length(signal)
                if i <= (overlap/2)*fs
                    hjorth(i/fs) = var([signal(1:i) signal(i+1:i+(overlap/2)*fs)]);
                elseif i > length(signal) - fs*(overlap/2)
                    hjorth(i/fs) = var([signal(i-fs*(overlap/2)+1:i) signal(i+1:end)]);
                else
                    hjorth(i/fs) = var(signal(i-fs*(overlap/2)+1:i+(overlap/2)*fs));
                end
            end

            % Hold local max value of 3-seconds window to smooth data
            for i = 2:length(hjorth)-1
                hjorth_max(i) = max(hjorth(i-1:i+1));
            end

            hjorth_max(1) = max(hjorth(1),hjorth(2));
            hjorth_max(end+1) = max(hjorth(end-1),hjorth(end));

            hjorth_max(isnan(hjorth_max)) = 0;
        end
       
        function [shan_entr] = getShannonMATLAB(signal, fs, overlap)
        % getShannon() -  Calculate Shannon Entropy in overlapping windows sampled in
        %                 1 Hz
        % Usage:
        %  >> [e] = getShannon(signal,fs,t)
        %
        % Inputs:
        %   signal        = raw EEG signal
        %   fs            = sample rate in Hz
        %   t             = window length
        %
        % Outputs:
        %   e             = Shannon Entropy in 1 Hz
        %
        % See also: wentropy()    

        % Calculate Shannon Entropy in overlapping windows
            for i = fs:fs:length(signal)
                if i <= (overlap/2)*fs
                    sh_entr = wentropy([signal(1:i) signal(i+1:i+(overlap/2)*fs)],'shannon');
                    shan_entr(i/fs) = sh_entr/log(length([signal(1:i) signal(i+1:i+(overlap/2)*fs)]));
                elseif i > length(signal) - fs*(overlap/2)
                    sh_entr = wentropy([signal(i-fs*(overlap/2)+1:i) signal(i+1:end)],'shannon');
                    shan_entr(i/fs) = sh_entr/log(length([signal(i-fs*(overlap/2)+1:i) signal(i+1:end)]));
                else
                    sh_entr = wentropy(signal(i-fs*(overlap/2)+1:i+(overlap/2)*fs),'shannon');
                    shan_entr(i/fs) = sh_entr/log(length(signal(i-fs*(overlap/2)+1:i+(overlap/2)*fs)));
                end
            end
            shan_entr(isnan(shan_entr)) = 0;
        end

        function [shan_entr] = getShannon(signal, fs, overlap)
        % getShannon() -  Calculate Shannon Entropy in overlapping windows sampled in
        %                 1 Hz
        % Usage:
        %  >> [e] = getShannon(signal,fs,t)
        %
        % Inputs:
        %   signal        = raw EEG signal
        %   fs            = sample rate in Hz
        %   t             = window length
        %
        % Outputs:
        %   e             = Shannon Entropy in 1 Hz
        %
        % See also: wentropy()    

        % Calculate Shannon Entropy in overlapping windows
            for i = fs:fs:length(signal)
                if i <= (overlap/2)*fs
                    h1 = histogram([signal(1:i) signal(i+1:i+(overlap/2)*fs)],'NumBins', 25, 'Normalization', 'Probability');
                    p = h1.Values;
                    shan_entr(i/fs) = -sum(p.*log2(p+eps));
                elseif i > length(signal) - fs*(overlap/2)
                    h1 = histogram([signal(i-fs*(overlap/2)+1:i) signal(i+1:end)], 'NumBins', 25, 'Normalization', 'Probability');
                    p = h1.Values;
                    shan_entr(i/fs) = -sum(p.*log2(p+eps));
                else
                    h1 = histogram(signal(i-fs*(overlap/2)+1:i+(overlap/2)*fs), 'NumBins', 25, 'Normalization', 'Probability');
                    p = h1.Values;
                    shan_entr(i/fs) = -sum(p.*log2(p+eps));
                end
            end
            shan_entr(isnan(shan_entr)) = 0;
        end

        function [teo_ma] = getTEO(signal,fs)
        % getTEO() -  Calculate Teager Energy Operator in one second windows
        % Usage:
        %  >> [teo_ma] = getTEO(signal,fs)
        %
        % Inputs:
        %   signal        = raw EEG signal
        %   fs            = sample rate in Hz
        %
        % Outputs:
        %   teo_ma        = Teager Energy Operator sampled in 1 Hz
        %
        % See also: 
        % Calculate Teager Energy Operator for entire signal
        % TEO: [x[n]] = x^2[n] - x[n - 1]x[n + 1] 
            x_dot = signal(2:length(signal)-1);
            x = signal(1:length(signal)-2);
            x_dotdot = signal(3:length(signal));
            teo = x_dot.^2 - (x.*x_dotdot);
            teo = [teo(1) teo teo(length(signal)-2)];

            % Get moving average value of TEO in one second frames
            for i = fs:fs:length(signal)
                if i > length(signal) - fs
                    teo_ma(i/fs) = mean([teo(i-fs+1:i) teo(i+1:end)]);
                else
                    teo_ma(i/fs) = mean(teo(i-fs+1:i+fs));
                end
            end
            teo_ma(isnan(teo_ma)) = 0;
        end

        function [power_band_max] = getPowerBandFeature(signal, fs, smooth)
        % getPowerBandFeature() -  Calculate band power features out of 2-seconds
        %                          and 64-seconds windows
        % Usage:
        %  >> [power_band_max] = getPowerBandFeature(signal, fs, smooth)
        %
        % Inputs:
        %   signal        = raw EEG signal
        %   Fs            = sample rate in Hz
        %   smooth        = holding max value in three seconds window
        %
        % Outputs:
        %   power_band_max    = normalized band power sampled in 1 Hz
        %
        % See also: mean()
        
            % Calculate normed power for specific band
            signal_power = (signal.^2)/max(signal.^2);

            % Calculate 2-s window mean power
            for i = fs:fs:length(signal_power)
                if i > length(signal_power) - fs
                    p_signalS(i/fs) = mean(signal_power(end-fs+1:end));
                else
                    p_signalS(i/fs) = mean(signal_power(i-fs+1:i+fs));
                end
            end

            % Calculate 64-s window mean power delta(1:i) delta(i+1:i+1.5*fs-1)
            for i = fs:fs:length(signal_power)
                if i < 32*fs
                    p_signalL(i/fs) = mean([signal_power(1:i) signal_power(i+1:i+32*fs)]);
                elseif i > length(signal_power) - 32*fs
                    p_signalL(i/fs) = mean([signal_power(i-fs*32+1:i-1) signal_power(i:end)]);
                else
                    p_signalL(i/fs) = mean(signal_power(i-32*fs+1:i+32*fs));
                end
            end

            % Calculate band descriptors
            power_band = (p_signalS - p_signalL)./p_signalL;

            % Smooth data by holding the max value of 3-seconds windows
            if smooth
                for i = 1:size(power_band,2)
                    if i < 3
                        power_band_max(i) = max(power_band(1:i+2));     
                    elseif i > size(power_band,2)-2
                        power_band_max(i) = max(power_band(i-2:end));       
                    else
                        power_band_max(i) = max(power_band(i-2:i+2));
                    end
                end
            else
                power_band_max = power_band;
            end
            power_band_max(isnan(power_band_max)) = 0;
        end
        
        function [power_band_max] = getMultitaperPowerBandFeature(signal, range, fs)
        % getPowerBandFeature() -  Calculate multitaper band power features out of 2-seconds
        %                          and 64-seconds windows
        % Usage:
        %  >> [power_band_max] = getPowerBandFeature(signal, fs, smooth)
        %
        % Inputs:
        %   signal        = raw EEG signal
        %   Fs            = sample rate in Hz
        %   smooth        = holding max value in three seconds window
        %
        % Outputs:
        %   power_band_max    = normalized band power sampled in 1 Hz
        %
        % See also: mean()
        
            % Calculate 2-s window mean power
            for i = fs:fs:length(signal)
                if i > length(signal) - fs
                    [pxx,~] = pmtm(signal(end-fs+1:end),4,range(1):0.1:range(2),fs,'adapt');
                    p_signalS(i/fs) = sum(pxx);
                else
                    [pxx,~] = pmtm(signal(i-fs+1:i+fs),4,range(1):0.1:range(2),fs,'adapt');
                    p_signalS(i/fs) = sum(pxx);
                end
            end

            % Calculate 64-s window mean power delta(1:i) delta(i+1:i+1.5*fs-1)
            for i = fs:fs:length(signal)
                if i < 32*fs
                    [pxx,~] = pmtm([signal(1:i) signal(i+1:i+32*fs)],4,range(1):0.1:range(2),fs,'adapt');
                    p_signalL(i/fs) = sum(pxx);
                elseif i > length(signal) - 32*fs
                    [pxx,~] = pmtm([signal(i-fs*32+1:i-1) signal(i:end)],4,range(1):0.1:range(2),fs,'adapt');
                    p_signalL(i/fs) = sum(pxx);
                else
                    [pxx,~] = pmtm(signal(i-32*fs+1:i+32*fs),4,range(1):0.1:range(2),fs,'adapt');
                    p_signalL(i/fs) = sum(pxx);
                end
            end

            % Calculate band descriptors
            power_band = (p_signalS - p_signalL)./p_signalL;

            % Smooth data by holding the max value of 3-seconds windows
            for i = 1:size(power_band,2)
                if i < 3
                    power_band_max(i) = max(power_band(1:i+2));     
                elseif i > size(power_band,2)-2
                    power_band_max(i) = max(power_band(i-2:end));       
                else
                    power_band_max(i) = max(power_band(i-2:i+2));
                end
            end
            power_band_max(isnan(power_band_max)) = 0;
        end

        function [EEG_var_diff] = getEEGVarDiff(signal,fs)
        % getEEGVarDiff() -  Calculate difference of variance in EEG signal out of
        %                    one second windows
        % Usage:
        %  >> [EEG_var_diff] = getEEGVarDiff(signal,fs)
        %
        % Inputs:
        %   signal        = raw EEG signal
        %   Fs            = sample rate in Hz
        %
        % Outputs:
        %    EEG_var_diff    = difference of variance in EEG as extracted feature
        %
        % See also: var()
        % Calculate variance of signals in one second windows
        
            for i = fs:fs:length(signal)
               signal_var(i/fs) = var(signal(i-fs+1:i));
            end
            % Get the difference of the variance
            var_diff = diff(signal_var);
            % Normalize the difference based on max value
            EEG_var_diff = var_diff./max(var_diff);
            % Diff function removes one sample, add one sample to get same length
            EEG_var_diff(end+1) = EEG_var_diff(end);
            % Get absoulute value
            EEG_var_diff = abs(EEG_var_diff);

            EEG_var_diff(isnan(EEG_var_diff)) = 0;
        end
        
        function [distance] = getDistance(signal, fs, stages, duration, time)
        % getDistance() -  Get distance to latest REM period
        % Usage:
        %  >> [e] = getDistance(signal,fs,stages, duration, time)
        %
        % Inputs:
        %   signal        = raw EEG signal
        %   fs            = sample rate in Hz
        %   stages        = vector with sleep annotation information
        %   duration      = vector with duration information for each stage
        %   time          = timepoints for each stage
        %
        % Outputs:
        %   distance     = Distance to latest REM period in 1 Hz
            if iscolumn(stages)
                stages = stages';
                time = time';
                duration = duration';
            end
            stages_new = stages;
            stages_new(stages > 5) = [];
            duration(stages > 5) = [];
            time(stages > 5) = [];
            time_diff = diff(time);
            ind = find(time_diff > 30);
            for i = 1 : length(ind)
               if ind(i) == 1
                   stages_new = [stages_new(1) stages_new];
                   duration = [30 duration];
                   time = [0 time];
               elseif ind(i) == length(time)
                   stages_new = [stages_new stages_new(end)];
                   duration = [duration 30];
                   time = [time time(end)+30];                   
               else
                   stages_new = [stages_new(1:ind(i)-1) stages_new(ind(i)-1) stages_new(ind(i):end)];
                   duration = [duration(1:ind(i)-1) 30 duration(ind(i):end)];
                   time = [time(1:ind(i)-1) time(ind(i))+30 time(ind(i):end)];                   
               end
            end
            wake_rem = stages_new == 0 | stages_new ==5;
            wake_rem = double(wake_rem);
            ind_rem = strfind(double(wake_rem),[0 1 0]);
            for i = 1 : length(ind_rem)
                wake_rem(ind_rem(i) : ind_rem(i)+2) = 0;
            end
            ind_rem = strfind(double(wake_rem),[0 1 1 0]);
            for i = 1 : length(ind_rem)
                wake_rem(ind_rem(i) : ind_rem(i)+3) = 0;
            end
            ind_nrem = strfind(double(wake_rem),[1 0 1]);
            for i = 1 : length(ind_nrem)
                wake_rem(ind_nrem(i) : ind_nrem(i)+2) = 1;
            end
            ind_nrem = strfind(double(wake_rem),[1 0 0 1]);
            for i = 1 : length(ind_nrem)
                wake_rem(ind_nrem(i) : ind_nrem(i)+3) = 1;
            end
            wake_rem_long = zeros(1,length(wake_rem)*30);
            for i = 1 : length(wake_rem)
                wake_rem_long((i-1)*30+1:i*30) = wake_rem(i); 
            end
            if length(signal)/fs > length(wake_rem_long)
                wake_rem_long(end:length(signal)/fs) = 1;
            elseif length(signal)/fs < length(wake_rem_long)
                wake_rem_long = wake_rem_long(1:floor(length(signal)/fs));
            end
            distance = zeros(1,length(wake_rem_long));
            for i = 1: length(distance)
                if wake_rem_long(i) == 1
                    distance(i) = 0;
                else
                    tmp = find(wake_rem_long(i:end),1,'first');
                    if isempty(tmp)
                        tmp = length(wake_rem_long);
                    end
                    distance(i) = tmp;
                end
            end
        end
        
        function [distance] = getDistancePerc(signal, fs, stages, duration, time)
        % getDistance() -  Get distance to latest REM period in percentage
        % Usage:
        %  >> [e] = getDistance(signal,fs,stages, duration, time)
        %
        % Inputs:
        %   signal        = raw EEG signal
        %   fs            = sample rate in Hz
        %   stages        = vector with sleep annotation information
        %   duration      = vector with duration information for each stage
        %   time          = timepoints for each stage
        %
        % Outputs:
        %   distance     = Distance in percentage to latest REM period in 1 Hz
            if iscolumn(stages)
                stages = stages';
                time = time';
                duration = duration';
            end
            stages_new = stages;
            stages_new(stages > 5) = [];
            duration(stages > 5) = [];
            time(stages > 5) = [];
            time_diff = diff(time);
            ind = find(time_diff > 30);
            for i = 1 : length(ind)
               if ind(i) == 1
                   stages_new = [stages_new(1) stages_new];
                   duration = [30 duration];
                   time = [0 time];
               elseif ind(i) == length(time)
                   stages_new = [stages_new stages_new(end)];
                   duration = [duration 30];
                   time = [time time(end)+30];                   
               else
                   stages_new = [stages_new(1:ind(i)-1) stages_new(ind(i)-1) stages_new(ind(i):end)];
                   duration = [duration(1:ind(i)-1) 30 duration(ind(i):end)];
                   time = [time(1:ind(i)-1) time(ind(i))+30 time(ind(i):end)];                   
               end
            end
            wake_rem = stages_new == 0 | stages_new ==5;
            wake_rem = double(wake_rem);
            ind_rem = strfind(double(wake_rem),[0 1 1 0]);
            ind_nrem = strfind(double(wake_rem),[1 0 0 1]);
            for i = 1 : length(ind_rem)
                wake_rem(ind_rem(i) : ind_rem(i)+3) = 0;
            end
            for i = 1 : length(ind_nrem)
                wake_rem(ind_nrem(i) : ind_nrem(i)+3) = 1;
            end
            wake_rem_long = zeros(1,length(wake_rem)*30);
            for i = 1 : length(wake_rem)
                wake_rem_long((i-1)*30+1:i*30) = wake_rem(i); 
            end
            if length(signal)/fs > length(wake_rem_long)
                wake_rem_long(end:length(signal)/fs) = 1;
            elseif length(signal)/fs < length(wake_rem_long)
                wake_rem_long = wake_rem_long(1:floor(length(signal)/fs));
            end
            distance = zeros(1,length(wake_rem_long));
            for i = 1: length(distance)
                if wake_rem_long(i) == 1
                    distance(i) = 0;
                else
                    tmp = find(wake_rem_long(1:i),1,'last');
                    if isempty(tmp)
                        tmp = 1;
                    end
                    tmp2 = find(wake_rem_long(i:end),1,'first');
                    if isempty(tmp2)
                        tmp2 = length(wake_rem_long);
                    end
                    tmp2 = (i+tmp2)-1;
                    distance(i) = (i-tmp)/(tmp2-tmp);
                end
            end
        end
    end
end