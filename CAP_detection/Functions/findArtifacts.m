function [e_thresh] = findArtifacts(e, alpha, min_break, period)

start_thresh = mean(e);

e_thresh = zeros(1, length(e));
marker = period;
start = [];
stop = [];
if mean(e(1:period)) < alpha*start_thresh
    e_mean = mean(e(1:period));
else
    while e(marker+1) > mean(e)
        marker = marker + 1;
    end
    e_thresh(1:marker) = 1;
    e_mean = mean(e(marker:marker+period));   
end

counter = 0;
art_flag = false;
for i = marker : length(e)
    if e(i) > alpha*e_mean
        if ~art_flag
            start = i-2;
            art_flag = true;
        else
            counter = 0;
        end            
    else
        if art_flag && counter <= min_break
            counter = counter + 1;                   
        else 
            if art_flag
                art_flag = false;
                counter = 0;
                e_thresh(start:i-period+1) = 1;
            end
            e_mean = mean(e(i-period+1:i));
        end
    end    
end
if art_flag
    art_flag = false;
    counter = 0;
    e_thresh(start:end) = 1;
end