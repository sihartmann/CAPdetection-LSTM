function [input, report, eeg, CFA] = preProcessingChannel(channel, eeg, CFA, report)

x = eeg.getRawSignal(eeg.info.label,channel);
if ~isempty(x)
    eeg.eeg = x;
else
    eeg.eeg = 0;
    report.WrongChannel = report.WrongChannel + 1;
    report.Error = report.Error + 1;
    report.ErrorFiles{end+1} = eeg.filename;
    report.Stop = true;
    input = [];
end


if ~report.Stop
    eeg.fs = SignalEEG.getCell(eeg.info.samples, eeg.info.label, channel);
    eeg.unit = SignalEEG.getCell(eeg.info.units, eeg.info.label, channel);
    if eeg.stoptime*eeg.fs < length(eeg.eeg)
        eeg.eeg = SignalEEG.cutSignal(eeg.eeg, 1, eeg.stoptime*eeg.fs);
    end

    if strcmp(eeg.unit,'mV')
        eeg.eeg = SignalEEG.alignSignal(eeg.eeg, 1000);
    end

    if CFA
        try
            % Get ECG signal
            eeg.findECG;
            % Pre-Process EEG signal
            [eeg.eeg, eeg.fs] = SignalDenoising.preProcessing(eeg, {'Resampling','CFA','Notch','BandpassFiltering'});
        catch
            report.NoECG = report.NoECG + 1;
            CFA = 0;
            % Pre-Process EEG signal
            [eeg.eeg, eeg.fs] = SignalDenoising.preProcessing(eeg, {'Resampling','Notch','BandpassFiltering'});        
        end
    else
        % Pre-Process EEG signal
        [eeg.eeg, eeg.fs] = SignalDenoising.preProcessing(eeg, {'Resampling','Notch','BandpassFiltering'});    
    end

    % Calculate features
    eeg.eeg_features = SignalFeatures.getFeaturesPaper(eeg.eeg, eeg.fs, eeg.event, eeg.duration, eeg.eventtime);
    % Create input and target vector for classifier
    [input, ~, ~, ~] = eeg.createMultiClassInput;
end
