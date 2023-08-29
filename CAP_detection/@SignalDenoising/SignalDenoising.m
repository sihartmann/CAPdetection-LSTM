classdef SignalDenoising
%SignalDenoising: The class SignalDenoising contains several methods to
%increase the quality of the signal. In addition to the classic denoising
%method with Wavelet Transformation, cardiac field artifacts can be removed
%and motion artifacts can be detected

    properties
    end
    methods(Static)

        function [tmp_signal, fs] = preProcessing(eegObj, steps)
        
            tmp_signal = eegObj.eeg;
            fs = eegObj.fs;
            for i = 1 : numel(steps)
                step = steps{i};
                switch step
                case 'BandpassFiltering'
                    tmp_signal = SignalDenoising.eegFiltering(tmp_signal, fs, 20, 1, 30);
                case 'Normalisation'
                    tmp_signal = SignalDenoising.eegNormalisation(tmp_signal);
                case 'Notch'
                    tmp_signal = SignalDenoising.eegNotchFiltering(tmp_signal, fs, 100);
                case 'Denoising'
                    tmp_signal = SignalDenoising.eegDenoising(tmp_signal);
                case 'CFA'
                    if fs == eegObj.ecg_fs
                        tmp_signal = SignalDenoising.artifactRemoval(tmp_signal, eegObj.ecg);
                    else
                        disp('EEG and ECG signal must have same sampling frequency!');
                    end
                case 'EOG'
                    if fs == eegObj.eog_fs
                        tmp_signal = SignalDenoising.artifactRemoval(tmp_signal, eegObj.eog);
                    else
                        disp('EEG and EOG signal must have same sampling frequency!');
                    end                   
                case 'Resampling'
                    tmp_signal = SignalDenoising.eegResample(tmp_signal, 200, fs);
                    fs = 200;
                    if eegObj.ecg_fs > 0
                        eegObj.ecg = SignalDenoising.eegResample(eegObj.ecg, 200, eegObj.ecg_fs);
                        eegObj.ecg_fs = 200;
                    end
                    if eegObj.eog_fs > 0
                        eegObj.eog = SignalDenoising.eegResample(eegObj.eog, 200, eegObj.eog_fs);
                        eegObj.eog_fs = 200;
                    end                    
                end
            end
        end
        %% Signal filtering
        function sig_filt = eegFiltering(signal, fs, order, Fc1, Fc2)
        %eegFiltering   Method to apply bandpass FIR filter to EEG signal
        %(See more information at EEG_bandpass)
        % See also: EEG_bandpass()
            sig_filt = EEG_bandpass(signal, fs, order, Fc1, Fc2);
        end
        %% Signal notch filtering
        function sig_filt = eegNotchFiltering(signal, fs, Nfir)
        %eegNotchFiltering   Method to apply notch filter to EEG signal
            b_notch1 = fir1(Nfir,[(50-1) (50+1)].*2/fs,'stop');
            b_notch2 = fir1(Nfir,[(60-1) (60+1)].*2/fs,'stop');
            sig_filt = filtfilt(b_notch1,1,signal); % Activate filter depending on location
            %sig_filt = filtfilt(b_notch2,1,signal);
        end

        %% WT Denoising
        function sig_den = eegDenoising(signal)
        %eegDenoising   Method to apply WT denoising to EEG signal (See more 
        %information at wdenoise)
        % See also: wdenoise()
            sig_den = wdenoise(signal,7,'Wavelet','db2','DenoisingMethod','UniversalThreshold','ThresholdRule','Soft');
        end
        %% Cardiac field removal
        function sig_proc = artifactRemoval(signal, ecg)
        % artifactRemoval   Method to remove Cardiac Field Artifact (See more 
        % information at cfa_removal())
        % See also: cfa_removal()
            sig_proc = cfa_removal(signal, ecg);
        end
        %% Resampling
        function sig_res = eegResample(signal,f_final, fs)
        % eegResample   Method to resample signal
        % See also: resample()
            sig_res = resample(signal,f_final,fs);
        end
        %% Normalisation
        function sig_norm = eegNormalisation(signal)
        % eegNormalisation Method to standardise eeg signal
            sig_norm = zscore(signal);
        end
    end
end
