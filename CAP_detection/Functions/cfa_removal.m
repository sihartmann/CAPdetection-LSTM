% cfa_removal  Algorithm to detect and remove Cardiac Field Artifact (CFA)
%              in EEG signal using FastICA and Wavelet decomposition
% Usage:
%  >> [ eeg_end ] = cfa_removal(eeg, ecg)
%
% Inputs:
%   eeg           = raw EEG signal
%   ecg           = ECG reference signal

%
% Outputs:
%    eeg_end      = artifact free signal
%
% See also: wavedec(), xcorr()

function [ eeg_end ] = cfa_removal(eeg, ecg)

% Wavelet decomposition
wave_fam = 'coif5';
% Decomposition
[c,l] = wavedec(eeg,6,wave_fam);

% Reconstruction
x_dec(1,:) = wrcoef('d',c,l,wave_fam,1); % 64 - 32 Hz
x_dec(2,:) = wrcoef('d',c,l,wave_fam,2); % 32 - 16 Hz
x_dec(3,:) = wrcoef('d',c,l,wave_fam,3); % 16 - 8 Hz
x_dec(4,:) = wrcoef('d',c,l,wave_fam,4); % 8 - 4 Hz
x_dec(5,:) = wrcoef('d',c,l,wave_fam,5); % 4 - 2 Hz
x_dec(6,:) = wrcoef('d',c,l,wave_fam,6); % 2 - 1 Hz
x_dec(7,:) = wrcoef('a',c,l,wave_fam,6); % 1 - 0 Hz
x_dec(8,:) = ecg; % Make sure EEG and ECG have same length

% Run ICA three times to get best correlation with ecg signal
for m = 1 : 1
    %% Perform ICA and reconstruct signals
    [icasig,A,~] = fastica(x_dec,'numOfIC',8,'verbose','off');

    % Reconstruct appearance of each source in original signal
    for i = 1 : size(A,2)
        tmp = zeros(size(A,2), length(eeg));
        tmp(i,:) = icasig(i,:);
        tmp_rec = A*tmp;
        x_rec(i,:) = sum(tmp_rec);    
    end

    % Calculate cross-correlation
    for i = 1 : size(x_rec,1)
       cross_corr(i,:) = xcorr(ecg,x_rec(i,:),'coeff');
    end
    
    % Get max values at zero lag
    cross_max = max(abs(cross_corr)');
    
    % Check if one correlation coeff is greater than 0.8
    % Threshold value was manually set
    % If no source is correlated to ecg signal, set similarity to 0
    ica_ecg = find(cross_max>0.80);
    
    if length(ica_ecg) > 1
        ica_ecg = find(cross_max == max(cross_max(ica_ecg)));
    end
    
    if ica_ecg ~= 0
        % Reconstruct filtered EEG signal and ECG signal
        ecg_rec = x_rec(ica_ecg,:);
        tmp = icasig;
        tmp(ica_ecg,:) = zeros(1,length(eeg));
        tmp_rec = A*tmp;
        eeg_rec(m,:) = sum(tmp_rec);

        % Determine difference of original EEG and filtered EEG 
        eeg_diff(m,:) = eeg - eeg_rec(m,:);

        % Check if artifacts look like ECG signal
        sim_art(m) = max(abs(xcorr(ecg,eeg_diff(m,:),'coeff')));
    else 
        disp('No source correlated to ECG signal!');
        disp('Check ICA!');
        sim_art(m) = 0;
    end
end

% Get best correlation between ECG and difference signal
[max_corr, max_ind] = max(sim_art);

% Check if difference between original and filtered EEG, looks like ECG
if max_corr > 0.70
    eeg_end = eeg_rec(max_ind,:);
    disp('Done with artifact removal');
else
    eeg_end = eeg;
    disp('No artifacts removed due to low correlation between removed signal parts and relevant signal!');
    disp(['Max correlation: ',num2str(max_corr)]);
end

end