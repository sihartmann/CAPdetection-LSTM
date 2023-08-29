% readHypnolabAnnotation -  Get timestamps, duration, and event for 
%                           selected time period in EEG recording 
% Usage:
%  >> [ event, timestamp, duration ] = getInfoOfPeriod( start, stop, 
%                                                 timevector, annotations )
%
% Inputs:
%   start           = starting point in seconds
%   stop            = end point in seconds
%   timevector      = vector containing all timestamps of events
%   annotations     = structure containing all annotations of annotation
%                     file
%
% Outputs:
%   event       = vector including event types in specific time period
%   timestamp   = vector including timestamps of each even in time period
%   duration    = vector including duration of events in specific time period
%
% See also: readHypnolabAnnotation()

function [ event, timestamp, duration ] = getInfoOfHypnolab( start, stop, timevector, annotations )

% Get start and stop indices
start_ind = find(timevector >= start,1);
% If stop value is greater than last value of timevector, get last index
if timevector(end) <= stop
    stop_ind = length(timevector);
else
    stop_ind = find(timevector >= stop,1)-1;
end
% Extract events, duration and timestamp
ind = 1;
event = [];
duration = [];
location = [];
for i=start_ind:stop_ind
    % Determine type of event
    tmp = annotations.event{i,1};
    % Check if CAP event and if so which type of CAP, otherwise check which
    % kind of sleep stage it is
    cap_flag = false;
    if strcmp(tmp(1),'A')
        cap_flag = true;
        if tmp(end) == '1'
            event(ind) = 6;
        elseif tmp(end) == '2'
            event(ind) = 7;
        else
            event(ind) = 8;
        end
    elseif strcmp(tmp(1),'S')
        if tmp(end) == '1'
            event(ind) = 1;
        elseif tmp(end) == '2'
            event(ind) = 2;
        elseif tmp(end) == '3'
            event(ind) = 3;
        elseif tmp(end) == '4' 
            event(ind) = 4;
        end
    elseif strcmp(tmp(1:2),'UN')
        event(ind) = 9; 
    elseif strcmp(tmp(1:2),'MT')
        event(ind) = 10;
    elseif strcmp(tmp(1:3),'REM')
        event(ind) = 5;
    elseif strcmp(tmp(1:4),'Wake')
        event(ind) = 0;
    else
        event(ind) = 0;
    end
    duration(ind) = annotations.duration{i,1};
    timestamp(ind) = timevector(i);
    ind = ind + 1;
end
end

