function [ECGlabel, CFA_flag, report] = findECGchannel(header, CFA_flag, report)

labels = {'ECG';'ECGL';'EKG';'ECG1ECG2';'ECG1-ECG2';'ECG1';'ekg';'ECG3ECG3';'ECGLECGR';'ECGRECGL';'ECGECG';'ecg';'ECGR'};

for i = 1 : length(labels)
    if any(strcmp(header.label,labels{i}))
        ECGlabel = labels{i};
        break;
    end
    if i == length(labels)
        CFA_flag = 0;
        report.NoECG = report.NoECG + 1;
    end
end