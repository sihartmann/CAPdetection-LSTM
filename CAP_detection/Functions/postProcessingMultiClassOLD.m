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

function [y_post] = postProcessingMultiClassOLD( y )

step = 1;
y_post = y;
CAP_start = [];
CAP_stop = [];
while step <= 2
    
    %% Determine duration of A-phases
    CAP_flag = false;
    score_flag = false;
    ind = 1;
    for i = 1 : length(y_post)
        if CAP_flag
            if y_post(i) == 0
                CAP_flag = false;
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


    %% Remove isolated zeros
    if ~isempty(CAP_stop)
        for i = 1 : length(CAP_stop)-1
            if (CAP_start(i+1) - CAP_stop(i)) == 1
                if y_post(CAP_stop(i)-1) == y_post(CAP_stop(i)+1)
                    y_post(CAP_stop(i)) = y_post(CAP_stop(i)-1);
                else
                    y_post(CAP_stop(i)-1) = 0;
                end
            end
        end
    end

    %% Repeat first four steps
    step = step + 1;
end
