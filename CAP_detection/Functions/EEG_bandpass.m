% EEG_bandpass  Bandpass filter to filter EEG signals by applying 
%               FIR filter
% Usage:
%  >> [signal_filtered] = EEG_bandpass(signal, Fs, filter_order, Fc1, Fc2)
%
% Inputs:
%   signal        = raw EEG signal
%   Fs            = sample rate in Hz
%   order         = filter order
%   Fc1           = low cutoff frequency
%   Fc2           = high cutoff frequency
%
% Outputs:
%    signal_filtered    = filtered signal
%
% See also: filtfilt(), fir1(), kaiser()

function [signal_filtered] = EEG_bandpass(signal, Fs, filter_order, Fc1, Fc2)

N    = filter_order;       % Order
Beta = 0.5;      % Window Parameter
% Create the window vector for the design algorithm.
win = kaiser(N+1, Beta);

% Calculate the coefficients using the FIR1 function.
b  = fir1(N, [Fc1 Fc2]/(Fs/2), 'bandpass', win);

signal_filtered = filtfilt(b,1,signal);
end