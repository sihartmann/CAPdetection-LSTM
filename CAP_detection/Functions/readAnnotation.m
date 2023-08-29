% readAnnotation -  Read annotation of a database recording (.txt files)
%                     Pass the filename of an annotation of a database 
%                     recording and the data will be stored in the output 
%                     parameters
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

function [ annotations ] = readAnnotation( filename )

textfile = fopen(filename);
annotations = struct;

% Read first line and remove the content
text = fgets(textfile);
% Get patient/recording name, ID and the date
text = fgets(textfile);
annotations.patient = text(9:end);
% Get patient/recording name, ID and the date
text = fgets(textfile);
annotations.patientID = text(12:end);
% Get patient/recording name, ID and the date
text = fgets(textfile);
annotations.date = text(16:end);
% Get the scoring and save it in a struct
stop_flag = true;
% Get all scored data
while stop_flag
    text = fgets(textfile);
    % Find first line with scored data
    if numel(text)>25
        if strfind(text(1:27),'Time [')
            headers = strsplit(text,'\t');
            scan_string = '';
            for i = 1:length(headers)
                scan_string = strcat(scan_string,'%s');
            end
            % Read all the data and store it in structure
            tmp = textscan(textfile,scan_string,'Delimiter','\t');
            % Set flag that all data was read
            stop_flag = false;
        end
    end
end
% Sort data
for i = 1:length(headers)
    switch headers{i}
        case 'Sleep Stage'
            annotations.stage = tmp{1,i};
        case 'Time [hh:mm:ss]'
            annotations.time = tmp{1,i};
        case 'Time [hh:mm:ss.xxx]'
            tmp2 = tmp{1,i};
            annotations.time = cellfun(@(x) x(1:8),tmp2,'UniformOutput',false);
            annotations.time = cellfun(@(x) replace(x,'.',':'),annotations.time,'UniformOutput',false);
        case 'Position'
            annotations.position = tmp{1,i};
        case 'Event'
            annotations.event = tmp{1,i};
        case 'Duration[s]'
            annotations.duration = tmp{1,i};
        case ['Duration[s]' char(13) newline]
            annotations.duration = tmp{1,i};
        case 'Duration [s]'
            annotations.duration = tmp{1,i};            
        case ['Location' char(13) newline]
            annotations.location = tmp{1,i};
    end
end
fclose(textfile);       
end

