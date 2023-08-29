% getInfoOfPeriod -  Get timestamps, duration, location and event for 
%                      selected time period in EEG recording from physionet
% Usage:
%  >> [ event, timestamp, duration,  location ] = getInfoOfPeriod( start, stop, 
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
%   location    = vector including location of events in specific time period
%
% See also: readAnnotation()

function [ event, timestamp, duration,  location ] = getInfoOfPeriod( start, stop, timevector, annotations )

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
    if length(tmp) > 3
        if tmp(1:4) == 'MCAP'
            if tmp(end) == '1'
                event(ind) = 6;
            elseif tmp(end) == '2'
                event(ind) = 7;
            else
                event(ind) = 8;
            end
        elseif tmp(1:4) == 'Wake'
            event(ind) = 0;
        elseif tmp(1:5) == 'SLEEP'
            if tmp(end) == '0'
                event(ind) = 0;
            elseif tmp(end) == '1'
                event(ind) = 1;
            elseif tmp(end) == '2'
                event(ind) = 2;
            elseif tmp(end) == '3'
                event(ind) = 3;
            elseif tmp(end) == '4' 
                event(ind) = 4;
            else
                event(ind) = 5;
            end
        else
            event(ind) = 0;
        end
    else
        if tmp(1) == 'A'
            if tmp(end) == '1'
                event(ind) = 6;
            elseif tmp(end) == '2'
                event(ind) = 7;
            else
                event(ind) = 8;
            end
        elseif tmp(1) == 'R'
            event(ind) = 5;    
        elseif tmp(1) == 'S'
            if tmp(end) == '0'
                event(ind) = 0;
            elseif tmp(end) == '1'
                event(ind) = 1;
            elseif tmp(end) == '2'
                event(ind) = 2;
            elseif tmp(end) == '3'
                event(ind) = 3;
            elseif tmp(end) == '4' 
                event(ind) = 4;
            else
                event(ind) = 5;
            end
        else
            event(ind) = 0;
        end
    end
    duration(ind) = str2num(annotations.duration{i,1});
    timestamp(ind) = timevector(i);
    % Remove 'EEG' from location string to get compatible string with the
    % labels in the EDF file
    if isfield(annotations,'location')
        if annotations.location{i,1}(1) == 'E'
            location{1,ind} = annotations.location{i,1}(5:end);
            location{1,ind} = regexprep(location{1,ind},'[-]','');
        else
            location{1,ind} = regexprep(annotations.location{i,1},'[-]','');
        end
    end
    ind = ind + 1;
end
duration = round(duration);
end

