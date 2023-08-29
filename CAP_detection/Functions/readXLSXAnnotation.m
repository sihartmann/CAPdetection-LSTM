% readXLSXAnnotation -  Read annotations from .xlsx file 
%                      Pass the filename of an annotation 
%                      and the data will be stored in the output 
%                      parameters
% Usage:
%  >> [ annotations ] = readAnnotation( filename )
%
% Inputs:
%   filename          = full path name of annotation file
%
% Outputs:
%   annotations       = structure including all annotations of the
%                       annotation file
%
% See also: getInfoOfPeriod()

function [ epoch_length, event, epochs, duration2 ] = readXLSXAnnotation( filename )

[num,~,raw] = xlsread(filename);
time = num(:,2);
%%
epochs = cellstr(datestr( time, 'HH:MM:SS' ))';
epochs_tmp = datetime(epochs);
epochs_tmp = timeofday(epochs_tmp);
duration = seconds(epochs_tmp);
duration2 = [diff(duration) 30];
if any(duration2 > -86000)
    ind  = find(duration2 < -86000);
    duration2(ind) = 86400 - duration(ind) + duration(ind+1);
end
sleep_stages = raw(2:end,3)';
epoch_length = 30;

event = [];
for ind = 1 : length(sleep_stages)
    tmp = sleep_stages{ind};
    if isnan(tmp)
        event(ind) = 11;
    elseif strcmp(tmp(1),'N')
        if tmp(end) == '1'
            event(ind) = 1;
        elseif tmp(end) == '2'
            event(ind) = 2;
        elseif tmp(end) == '3'
            event(ind) = 3;
        elseif tmp(end) == '4' 
            event(ind) = 4;
        end
    elseif strcmp(tmp(1),'W')
        event(ind) = 0; 
    elseif strcmp(tmp(1),'R')
        event(ind) = 5;
    else
        event(ind) = 0;
    end
end
        
end
