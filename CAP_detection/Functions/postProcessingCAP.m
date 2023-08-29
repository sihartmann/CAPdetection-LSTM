% postProcessingCAP() -  Remove A-phases shorter than 2 seconds and 
%                        longer than 60 seconds
% Usage:
%  >> [y_post] = postProcessingCAP( y, x )
%
% Script for postprocessing classified data
% Processing:   1. Determine duration of detected A-phases
%               2. Re-classify A-phases longer than 60 seconds
%               3. Remove isolated zeros
%               4. Remove isolated ones
%               5. Repeat step 1+2+3+4
%
% Inputs:
%   y           = predicted values of classifier
%   x           = raw signal
%
% Outputs:
%   y_post      = post-processed predicted values
%
% See also: createNN_PostProcess()

function [y_post] = postProcessingCAP( y, x )

step = 1;
y_post = y;
while step <= 3
    
    %% Determine duration of A-phases
    CAP_flag = false;
    score_flag = false;
    ind = 1;
    for i = 1 : length(y_post)
        if CAP_flag
            if y_post(i) == 0
                CAP_flag = false;
                score_flag = true;
                CAP_stop(ind) = i;
                duration(ind) = i - CAP_start(ind);
                ind = ind + 1;
            end
        else
            if y_post(i) == 1 
                CAP_flag = true;
                CAP_start(ind) = i;
            end
        end
    end
    if CAP_flag
        CAP_flag = false;
        CAP_stop(ind) = i;
        duration(ind) = i - CAP_start(ind);
        ind = ind + 1;        
    end

    if score_flag
        %% Re-classifiy A-phases longer than 60 seconds
        net_postprocess = postProcessNN;
        % Statistics
        counter = 0;
        for i = 1 : length(duration)
            if duration(i) > 60
                counter = counter + 1;
                % Configure network to set random initial weights
                net = configure(net_postprocess,x(CAP_start(i):CAP_stop(i)-1)); 
                % Train network
                [net_tmp,~] = train(net_postprocess,x([1, 5],CAP_start(i):CAP_stop(i)-1));
                % Test trained neural network
                tmp = net_tmp(x([1, 5],CAP_start(i):CAP_stop(i)-1));
                y_post(CAP_start(i):CAP_stop(i)-1) = tmp(1,:);
            end
        end
        %disp(['Number of A-phases longer than 60 seconds: ',num2str(counter)]);
        %disp(['Percentage of A-phases longer than 60 seconds: ',num2str(counter/length(duration)*100),'%']);
        %% Remove isolated zeros
        for i = 1 : length(CAP_stop)-1
            if (CAP_start(i+1) - CAP_stop(i)) == 1
                y_post(CAP_stop(i)) = 1;
            end
        end
        %% Remove isolated ones
        for i = 1 : length(CAP_start)
            if (CAP_stop(i) - CAP_start(i)) == 1
                y_post(CAP_start(i)) = 0;
            end
        end
    end
    %% Repeat first four steps
    step = step + 1;
end

