% postProcessingMultiClass() -  Remove isolated A phases and set A phases
%                               to dominant subtype
% Usage:
%  >> [y_post] = postProcessingMultiClass( y )
%
% Script for postprocessing classified data
% Processing:   1. Determine duration of detected A-phases
%               3. Remove isolated classes
%               5. Repeat step 1+2+3+4
%
% Inputs:
%   y           = predicted values of classifier
%
% Outputs:
%   y_post      = post-processed predicted values
%
% See also: createNN_PostProcess()

function [y_post] = postProcessingMultiClass( y, x )

step = 1;
y_post = y;
while step <= 4
    
    %% Determine duration of A-phases
    CAP_flag = false;
    score_flag = false;
    ind = 1;
    CAP_start = [];
    CAP_stop = [];
    duration = [];
    for i = 1 : length(y_post)
        if CAP_flag
            if y_post(i) == 0
                CAP_flag = false;
                score_flag = true;
                CAP_stop(ind) = i;
                duration(ind) = i - CAP_start(ind);
                if duration(ind) == 1
                    y_post(i-1) = 0;
                else
                    [~, index] = max(classes);
                    y_post(CAP_start(ind):CAP_stop(ind)-1) = index(1);
                end
                ind = ind + 1;
            else
                classes(y_post(i)) = classes(y_post(i)) + 1;
            end
        else
            if y_post(i) > 0 
                classes = [0; 0; 0];
                CAP_flag = true;
                CAP_start(ind) = i;
                classes(y_post(i)) = classes(y_post(i)) + 1;
            end
        end
    end
    if CAP_flag
        CAP_flag = false;
        CAP_stop(ind) = i;
        duration(ind) = i - CAP_start(ind);
        if duration(ind) == 1
            y_post(end) = 0;
        else
            [~, index] = max(classes);
            y_post(CAP_start(ind):end) = index(1);
        end
        ind = ind + 1;        
    end

    if score_flag 
        %% Re-classifiy A-phases longer than 60 seconds
        if ~isempty(CAP_stop) && step < 4
            net_postprocess = postProcessNNMultiClass;
            % Statistics
            %counter = 0;
            for i = 1 : length(duration)
                if duration(i) > 60
                    %counter = counter + 1;
                    % Configure network to set random initial weights
                    %net = configure(net_postprocess,x(CAP_start(i):CAP_stop(i)-1)); 
                    % Train network
                    if size(x,1) > 14
                        [net_tmp,~] = train(net_postprocess,x([8, 12, 21, 26],CAP_start(i):CAP_stop(i)-1));
                        % Test trained neural network
                        tmp = net_tmp(x([8, 12, 21, 26],CAP_start(i):CAP_stop(i)-1));
                    else
			
			[net_tmp,~] = train(net_postprocess,x([8, 12],CAP_start(i):CAP_stop(i)-1));
                        % Test trained neural network
                        tmp = net_tmp(x([8, 12],CAP_start(i):CAP_stop(i)-1));                        
                    end
                    tmp = tmp(2,:) + 2*tmp(3,:) + 3*tmp(4,:);
                    y_post(CAP_start(i):CAP_stop(i)-1) = tmp;
                end
            end
        end

        %% Remove isolated zeros
        if ~isempty(CAP_stop)
            y_diff = diff(y_post>0);
            A_start = find(y_diff == 1)+1;
            A_stop = find(y_diff == -1);
            for i = 1 : length(A_stop)-1
                if (A_start(i+1) - A_stop(i)) == 2
                    if y_post(A_stop(i)) == y_post(A_start(i+1))
                        % If preceding and succeeding A-phase are from the
                        % same class
                        y_post(A_stop(i)+1) = y_post(A_stop(i));
                    else
                        y_post(A_stop) = 0;
                    end
                end
                if (A_stop(i) - A_start(i)) > 60 && step == 4
                    k = A_start(i);
                    while k + 60 <= A_stop(i)
                        y_post(k:k+60) = y_post(A_start(i));
                        y_post(k+61:k+62) = 0;
                        k = k+62;
                    end
                    if k < A_stop(i)
                        y_post(k:A_stop(i)) = y_post(A_start(i));
                    end
                end
            end
            if (A_stop(end) - A_start(end)) > 60 && step == 4
                k = A_start(end);
                while k + 60 <= A_stop(end)
                    y_post(k:k+60) = y_post(A_start(end));
                    y_post(k+61:k+62) = 0;
                    k = k+62;
                end
                if k < A_stop(end)
                    y_post(k:A_stop(end)) = y_post(A_start(end));
                end                
            end
        end
    end
    %% Repeat first four steps
    step = step + 1;
end
