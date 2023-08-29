function [labels_rec, x_rec] = labelReconstruction(eeg, labels, x, seq_length)

labels_rec = [zeros(1,seq_length-1) labels];
x_rec = x;
for i = 1 : length(eeg.event)
    if eeg.event(i) == 0 || eeg.event(i) == 5 || eeg.event(i) > 8
        if eeg.eventtime(i) == 0
            labels_rec = [zeros(1,eeg.duration(i)) labels_rec];
            x_rec = [zeros(size(x_rec,1),eeg.duration(i)) x_rec];
        elseif eeg.eventtime(i) > length(labels_rec)
            labels_rec = [labels_rec zeros(1,eeg.duration(i))];
            x_rec = [zeros(size(x_rec,1),eeg.duration(i))];
        else
            labels_rec = [labels_rec(1:eeg.eventtime(i)) zeros(1,eeg.duration(i)) labels_rec(eeg.eventtime(i)+1:end)];
            x_rec = [x_rec(:,1:eeg.eventtime(i)) zeros(size(x_rec,1),eeg.duration(i)) x_rec(:,eeg.eventtime(i)+1:end)];
        end
    end 
end