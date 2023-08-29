% readXMLAnnotation -  Read annotations from XML file 
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

function [ epoch, sleep_stages, episode ] = readXMLAnnotation( filename )

xml_content = xml2struct(filename);

epoch = str2num(xml_content.CMPStudyConfig.EpochLength.Text);

sleep_stages = cellfun(@(x) str2num(x.Text), xml_content.CMPStudyConfig.SleepStages.SleepStage,'UniformOutput',false);
sleep_stages = cell2mat(sleep_stages);
if isfield(xml_content.CMPStudyConfig.ScoredEvents,'ScoredEvent')
    episode.name = cellfun(@(x) x.Name.Text, xml_content.CMPStudyConfig.ScoredEvents.ScoredEvent,'UniformOutput',false);
    episode.start = cellfun(@(x) str2num(x.Start.Text), xml_content.CMPStudyConfig.ScoredEvents.ScoredEvent,'UniformOutput',false);
    episode.duration = cellfun(@(x) str2num(x.Duration.Text), xml_content.CMPStudyConfig.ScoredEvents.ScoredEvent,'UniformOutput',false);
    for i = 1 : numel(xml_content.CMPStudyConfig.ScoredEvents.ScoredEvent)
        try
            episode.input{i} = xml_content.CMPStudyConfig.ScoredEvents.ScoredEvent{1,i}.Input.Text;
        catch
            episode.input{i} = 'NA';
        end
    end
else
    episode = struct;
end

% arousal_index = find(not(cellfun('isempty',strfind(episode.name,'Arousal ()'))));
% episode.name = episode.name(arousal_index); 
% episode.start = episode.start(arousal_index);
% episode.duration = episode.duration(arousal_index);
% episode.input = episode.input(arousal_index);
% arousals = zeros(1, length(sleep_stages)*30);
% for i = 1 : length(episode.start)
%     arousals(round(episode.start{i}):round(episode.start{i})+round(episode.duration{i})-1) = 1;
% end
%arousals = struct;