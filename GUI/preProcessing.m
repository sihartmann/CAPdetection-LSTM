function [input] = preProcessingDerivation(derivation, eeg)

eeg.eeg = eeg.getRawSignal(eeg.info.label,derivation{1})-eeg.getRawSignal(eeg.info.label,derivation{2});
if eeg.stoptime*eeg.fs < length(eeg.eeg)
    eeg.eeg = SignalEEG.cutSignal(eeg.eeg, 1, eeg.stoptime*eeg.fs);
end

if strcmp(eeg.unit,'mV')
    eeg.eeg = SignalEEG.alignSignal(eeg.eeg, 1000);
end

% Get ECG signal
eeg.findECG;

% Pre-Process EEG signal
[eeg.eeg, eeg.fs] = SignalDenoising.preProcessing(eeg, {'Resampling','CFA','BandpassFiltering'});
% Calculate features
eeg.eeg_features = SignalFeatures.getFeaturesPaper(eeg.eeg, eeg.fs);
% Create input and target vector for classifier
[input, ~, ~, ~] = eeg.createMultiClassInput;
