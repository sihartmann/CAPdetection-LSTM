% getMultiClassMetrics() -  Calculate performance measures for predicted values of
%                           classifier
% Usage:
%  >> [metrics] = getMultiClassMetrics(predictions, targets)
%
% Objective measures:
%           - Sensitivity
%           - Precision
%           - Specificity
%           - Accuracy
%           - F-score
%
% Inputs:
%   predictions       = predicted values of classifier
%   targets           = labeled data, reference values
%
% Outputs:
%   metrics           = structure containing mean and std of all measure
%                       values
%
% See also: 

function [metrics] = getMultiClassMetrics(predictions, targets, numberClasses)

for j = 1 : size(predictions,2)
    if length(predictions{:,j}) < length(targets{:,j})
        lim = length(predictions{:,j});
    else
        lim = length(targets{:,j});
    end
    weighted_accuracy = 0;
    for i = 0 : numberClasses
        name = strcat('Class_',num2str(i));
        if sum((targets{j}(1:lim)==i)) > 0
            metrics.(name).sensitivity(j) = sum((targets{j}(1:lim)==i).*(predictions{j}(1:lim)==i))/sum((targets{j}(1:lim)==i))*100;
        else
            metrics.(name).sensitivity(j) = 100;
        end
        metrics.(name).precision(j) = sum((targets{j}(1:lim)==i).*(predictions{j}(1:lim)==i))/sum((predictions{j}(1:lim)==i))*100;
        metrics.(name).specificity(j) = sum((targets{j}(1:lim)~=i).*(predictions{j}(1:lim)~=i))/sum(targets{j}(1:lim)~=i)*100;
        tp = sum((targets{j}(1:lim)==i).*double(predictions{j}(1:lim)==i));
        metrics.(name).class_accuracy(j) = (tp)/sum((targets{j}(1:lim)==i))*100;    
        weighted_accuracy = weighted_accuracy + metrics.(name).class_accuracy(j);
        metrics.(name).accuracy(j) = sum(targets{j}(1:lim) == double(predictions{j}(1:lim)))/numel(targets{j}(1:lim))*100;
        if (metrics.(name).precision(j)+metrics.(name).sensitivity(j)) > 0
            metrics.(name).fscore(j) = 2*(metrics.(name).precision(j)*metrics.(name).sensitivity(j))/(metrics.(name).precision(j)+metrics.(name).sensitivity(j));
        else
            metrics.(name).fscore(j) = 0;
        end
    end
    metrics.(name).weighted_accuracy(j) = weighted_accuracy/(numberClasses+1);
end

for i = 0 : numberClasses
    name = strcat('Class_',num2str(i));
    metrics.(name).mean_tpr = mean(metrics.(name).sensitivity);
    metrics.(name).mean_ppv = mean(metrics.(name).precision);
    metrics.(name).mean_spe = mean(metrics.(name).specificity);
    metrics.(name).mean_acc = mean(metrics.(name).accuracy);
    metrics.(name).mean_fscore = mean(metrics.(name).fscore);

    metrics.(name).std_tpr = std(metrics.(name).sensitivity);
    metrics.(name).std_ppv = std(metrics.(name).precision);
    metrics.(name).std_spe = std(metrics.(name).specificity);
    metrics.(name).std_acc = std(metrics.(name).accuracy);
    metrics.(name).std_fscore = std(metrics.(name).fscore);
end
metrics.(name).mean_wacc = mean(metrics.(name).weighted_accuracy);
metrics.(name).std_wacc = std(metrics.(name).weighted_accuracy);
end