function [pred_out, CAP_start, CAP_stop] = CAPsequences(pred, events)

pred_bin = pred > 0;

pred_diff = diff(pred_bin);
A_start = find(pred_diff == 1)+1;
A_stop = find(pred_diff == -1);
CAP_start = [];
CAP_stop = [];
if ~isempty(A_stop) 
    if A_stop(1) < A_start(1) 
        A_start = [1 A_start];
    end
    if A_start(end) > A_stop(end)
        A_stop = [A_stop length(pred)];
    end    
    i = 1;
    CAP_status = 0;
    pred_out = pred;
    while i <= length(A_start)
        if A_stop(i) - A_start(i) <= 60 
            if CAP_status > 0
                if A_start(i) - A_stop(i-1) - 1 <= 60 && ~any(events(A_stop(i-1):A_start(i))==0 | events(A_stop(i-1):A_start(i))>4)
                    CAP_status = CAP_status + 1;                    
                elseif CAP_status > 2
                    CAP_start = [CAP_start A_start(i-CAP_status)];
                    CAP_stop = [CAP_stop A_start(i-1)-1];
                    pred_out(A_start(i-1):A_stop(i-1)) = 0;
                    CAP_status = 1;
                else
                    for j = 1 : CAP_status
                        pred_out(A_start(i-j):A_stop(i-j)) = 0;
                    end 
                    CAP_status = 1;
                end           
            else
                CAP_status = 1;
            end 
        else
            if CAP_status > 0                   
                if CAP_status > 2
                    CAP_start = [CAP_start A_start(i-CAP_status)];
                    CAP_stop = [CAP_stop A_stop(i-1)];
                else
                    for j = 1 : CAP_status
                        pred_out(A_start(i-j):A_stop(i-j)) = 0;
                    end
                end
            end
            pred_out(A_start(i):A_stop(i)) = 0;
            CAP_status = 0;
        end
        i = i + 1;
    end 
    
    if CAP_status > 2
        CAP_start = [CAP_start A_start(i-CAP_status)];
        CAP_stop = [CAP_stop A_stop(i-1)];
    end
else
    pred_out = pred;
end
