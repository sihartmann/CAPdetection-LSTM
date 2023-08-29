% extractEEGBands() -  Bandpass filter to extract EEG-specific frequency band 
%                      from EEG signals 
% Usage:
%  >> [Hd, signal_filtered] = FIRfilter_bandpass(signal, Fs, type)
%
% Inputs:
%   signal        = raw EEG signal
%   Fs            = sample rate in Hz
%   type          = name of frequency band in EEG signal
%                   (delta|theta|alpha|sigma|beta) (default: delta)
%
% Outputs:
%    Hd                 = filter coefficients
%    signal_filtered    = filtered signal
%
% See also: filtfilt(), eegfilt_eeglab()

function [Hd, signal_filtered] = extractEEGBands(signal, Fs, type)

switch type
    case 'delta'
        Fc1 = 0.5;
        Fc2 = 4;
    case 'theta'
        Fc1 = 4;
        Fc2 = 8;
    case 'alpha'
        Fc1 = 8;
        Fc2 = 12;
    case 'sigma'
        Fc1 = 12;
        Fc2 = 16;
    case 'beta'
        Fc1 = 16;
        Fc2 = 25;
    otherwise
        Fc1 = 0.5;
        Fc2 = 4;
end

[signal_filtered,Hd] = eegfilt_eeglab(signal,Fs,Fc1,Fc2,0);