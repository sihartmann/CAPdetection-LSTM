function [length_mean, length_std, number] = getScoringStatistics(labels)

stats = struct;

labels_tmp = labels > 0;

labels_diff = diff(labels_tmp);
start_pos = find(labels_diff == 1);
end_pos = find(labels_diff == -1);

if labels_tmp(1) == 1
    start_pos = [1 start_pos];
end
if labels_tmp(end) == 1
    end_pos = [end_pos length(labels_tmp)];
end

CAP_length = end_pos - start_pos;
number = length(CAP_length);
length_mean = mean(CAP_length);
length_std = std(CAP_length);

end