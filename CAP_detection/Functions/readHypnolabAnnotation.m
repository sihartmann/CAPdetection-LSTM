% readHypnolabAnnotation -  Read annotation from Hypnolab of a database recording (.evt files)
%                           Pass the filename of an annotation of a database 
%                           recording and the data will be stored in the output 
%                           parameters
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

function [ annotations ] = readHypnolabAnnotation( filename )

textfile = fopen(filename);
annotations = struct;

% Read first line and remove the content
text = fgets(textfile);
% Get patient/recording name, ID and the date
text = fgets(textfile);
annotations.patient = text(9:end);
% Read first line and remove the content
text = fgets(textfile);
% Get patient/recording name, ID and the date
text = fgets(textfile);
annotations.date = text(6:end);
% Get the scoring and save it in a struct
stop_flag = true;
% Get all scored data
while stop_flag
    text = fgets(textfile);
    % Find first line with scored data
    if numel(text)>20
        if strfind(text(1:20),'Time [h')
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
        case 'Time [hh:mm:ss.xxx]'
            annotations.time = tmp{1,i};
        case 'Time [hh:mm:ss]'
            annotations.time = tmp{1,i};
        case 'Event'
            annotations.event = tmp{1,i};
        case ['Duration[s]' char(13) newline]
            annotations.duration = tmp{1,i};  
        case 'Duration[s]'
            annotations.duration = tmp{1,i};              
        case 'Duration(s)'
            annotations.duration = tmp{1,i};
        case ['Duration(s)' char(13)]
            annotations.duration = tmp{1,i};
        case 'Duration (s)'
            annotations.duration = tmp{1,i};            
        case ['Extra' char(13) newline]
            annotations.location = tmp{1,i};
    end
end

fclose(textfile);   

if strfind(annotations.time{1},':')
    time_tmp = cellfun(@(x) strsplit(x,':'), annotations.time,'UniformOutput', false);
    annotations.time = cellfun(@(x) strcat(x(1),':', x(2),':', num2str(round(str2double(x(3))),'%02d')), time_tmp, 'UniformOutput', false);
    annotations.duration = cellfun(@(x) round(str2double(x)), annotations.duration,'UniformOutput', false); 
else
    time_tmp = cellfun(@(x) strsplit(x,'.'), annotations.time,'UniformOutput', false);
    annotations.time = cellfun(@(x) strcat(x(1),':', x(2),':', num2str(round(str2double(x(3))),'%02d')), time_tmp, 'UniformOutput', false);
    annotations.duration = cellfun(@(x) round(str2double(x)), annotations.duration,'UniformOutput', false);     
end
end
    