function [stats] = getOutputStatistics(predictions, rec_pred, CAP_start, CAP_stop, name)

stats{1} = name;
stats{2} = length(predictions)+13;

pred_diff = diff(rec_pred>0);
A_start = find(pred_diff == 1)+1;
A_stop = find(pred_diff == -1);

if ~isempty(A_stop)
    if A_stop(1) < A_start(1) 
        A_start = [0 A_start];
    end
    if A_start(end) > A_stop(end)
        A_stop = [A_stop length(rec_pred)];
    end
    A_dur = A_stop - A_start+1;
    A_type = rec_pred(A_start);
else
    A_start = [];
    A_stop = []; 
    A_dur = [];
    A_type = [];
end

stats{3} = length(A_start);
stats{4} = sum(rec_pred>0);
stats{5} = stats{4}/stats{3};
stats{6} = stats{3}/stats{2}*3600;
stats{7} = stats{4}/stats{2};

pred_1 = rec_pred==1;
A1_start = find(diff(pred_1) == 1);
A1_stop = find(diff(pred_1) == -1);
if ~isempty(A1_stop)
    if A1_stop(1) < A1_start(1) 
        A1_start = [0 A1_start];
    end
    if A1_start(end) > A1_stop(end)
        A1_stop = [A1_stop length(rec_pred)];
    end
    stats{8} = length(A1_start);
    stats{11} = sum(pred_1>0);
    stats{14} = stats{11}/stats{8};
    stats{17} = stats{8}/stats{3};
    stats{20} = stats{11}/stats{2};
    stats{23} = stats{8}/stats{2}*3600;
else
    stats{8} = 0;
    stats{11} = 0;
    stats{14} = 0;  
    stats{17} = 0;
    stats{20} = 0;
    stats{23} = 0;
end


pred_2 = rec_pred==2;
A2_start = find(diff(pred_2) == 1);
A2_stop = find(diff(pred_2) == -1);
if ~isempty(A2_stop) && ~isempty(A2_start) 
    if A2_stop(1) < A2_start(1) 
        A2_start = [0 A2_start];
    end
    if A2_start(end) > A2_stop(end)
        A2_stop = [A2_stop length(rec_pred)];
    end
    stats{9} = length(A2_start);
    stats{12} = sum(pred_2>0);
    stats{15} = stats{12}/stats{9};
    stats{18} = stats{9}/stats{3};
    stats{21} = stats{12}/stats{2};
    stats{24} = stats{9}/stats{2}*3600;
else
    stats{9} = 0;
    stats{12} = 0;
    stats{15} = 0;  
    stats{18} = 0;
    stats{21} = 0;
    stats{24} = 0;
end

pred_3 = rec_pred==3;
A3_start = find(diff(pred_3) == 1);
A3_stop = find(diff(pred_3) == -1);
if ~isempty(A3_stop)
    if A3_stop(1) < A3_start(1) 
        A3_start = [0 A3_start];
    end
    if A3_start(end) > A3_stop(end)
        A3_stop = [A3_stop length(rec_pred)];
    end
    stats{10} = length(A3_start);
    stats{13} = sum(pred_3>0);
    stats{16} = stats{13}/stats{10};
    stats{19} = stats{10}/stats{3};
    stats{22} = stats{13}/stats{2};
    stats{25} = stats{10}/stats{2}*3600;
else
    stats{10} = 0;
    stats{13} = 0;
    stats{16} = 0;  
    stats{19} = 0;
    stats{22} = 0;
    stats{25} = stats{8}/stats{2}*3600;
end

if ~isempty(CAP_start)
    stats{26} = length(CAP_start);
    CAP_duration = 0;
    B_phase_duration = [];
    CAP_cycle_duration = [];
    for i = 1 : length(CAP_start)
        CAP_duration = CAP_duration + CAP_stop(i) - CAP_start(i);
        pred_tmp = rec_pred(CAP_start(i):CAP_stop(i));
        CAP_diff = diff(pred_tmp>0);
        CAP_A_start = find(CAP_diff == 1)+1;
        CAP_A_start1 = [1 CAP_A_start length(pred_tmp)];
        CAP_A_start2 = [CAP_A_start length(pred_tmp)];
        CAP_A_stop = find(CAP_diff == -1);
        if length(CAP_A_start2) > length(CAP_A_stop)
            CAP_A_start2(end) = [];
        end
        CAP_cycle_duration = [CAP_cycle_duration diff(CAP_A_start1)];
        B_phase_duration = [B_phase_duration CAP_A_start2 - CAP_A_stop]; 
    end
    stats{27} = CAP_duration;
    stats{28} = stats{27}/stats{2}*100;
    stats{29} = stats{27}/stats{26};
    stats{30} = mean(CAP_cycle_duration);
    stats{31} = mean(B_phase_duration);
else
    stats{26} = 0;
    stats{27} = 0;
    stats{28} = 0;   
    stats{29} = 0; 
    stats{30} = 0;
    stats{31} = 0;
end
