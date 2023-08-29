% get_metrics() -  Calculate performance measures for predicted values of
%                  classifier
% Usage:
%  >> [metrics] = get_metrics(predictions, targets)
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

function [metrics] = getMetrics(predictions, targets)

for j = 1 : size(predictions,2)
    if length(predictions{:,j}) < length(targets{:,j})
        lim = length(predictions{:,j});
    else
        lim = length(targets{:,j});
    end
    metrics.sensitivity(j) = sum(targets{j}(1:lim).*predictions{j}(1:lim))/sum(targets{j}(1:lim))*100;
    metrics.precision(j) = sum(targets{j}(1:lim).*predictions{j}(1:lim))/sum(predictions{j}(1:lim))*100;
    metrics.specificity(j) = sum((targets{j}(1:lim)<1).*(predictions{j}(1:lim)<1))/sum(targets{j}(1:lim)<1)*100;
    metrics.accuracy(j) = sum(targets{j}(1:lim) == double(predictions{j}(1:lim)))/numel(targets{j}(1:lim))*100;
    metrics.fscore(j) = 2*(metrics.precision(j)*metrics.sensitivity(j))/(metrics.precision(j)+metrics.sensitivity(j));
end

metrics.mean_tpr = mean(metrics.sensitivity);
metrics.mean_ppv = mean(metrics.precision);
metrics.mean_spe = mean(metrics.specificity);
metrics.mean_acc = mean(metrics.accuracy);
metrics.mean_fscore = mean(metrics.fscore);

metrics.std_tpr = std(metrics.sensitivity);
metrics.std_ppv = std(metrics.precision);
metrics.std_spe = std(metrics.specificity);
metrics.std_acc = std(metrics.accuracy);
metrics.std_fscore = std(metrics.fscore);
end