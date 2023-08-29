classdef SignalEEG < handle
%SignalEEG: SignalEEG is the signal class for EEG recordings providing the
%raw signals, modified signals in relation to the manual scoring, 
%measurement information and scoring annotations

    properties
        path = '';              % String containing path of folder with data file
        filename = '';          % String of the filename
        name = '';              % String containing name of the file without file extension
        format = '';            % String of file extension
        channel = '';           % String of channel name
        raw_data = [];          % NxM double matrix containing N recordings of length M
        data = [];              % NxM double matrix containing N processed signals of length M
        eeg = [];               % 1xM double vector containing raw EEG recording
        ecg = [];               % 1xM double vector containing raw ECG recording
        eeg_features = [];      % NxL double vector containing N seconds of L features
        eog = [];               % 1xM double vector containing raw EOG recording
        fs = 0;                 % Double value of sample rate for EEG signal
        ecg_fs = 0;             % Double value of sample rate for ECG signal
        eog_fs = 0;             % Double value of sample rate for EOG signal
        info = struct;          % Structure providing information about measurement setup
        labels = {};            % 1xN cell array containing labels of N recordings
        unit = '';              % String of measurement unit
        starttime = 0;          % Double value indicating the start time of the measurement (in seconds!)
        stoptime = 0;           % Double value indicating the stop time of the measurement (in seconds!)
        scoringtime = 0;        % Double value indicating the start of the scoring (in seconds!)
        timediff = 0;           % Double value indicating the time difference between the scoring and the start of the measurement (in seconds!)
        epochs = 0;             % Number of seconds of entire EEG recording
        annotations = struct;   % Structure containing information from annotation file
        event = {};             % Cell array including scored events
        duration = [];          % Double array containing duration of each event 
        location = {};          % Cell array of location for each event
        eventtime = [];         % Double array containing starting second of each event
        arousals = [];          % Double array containing arousal vector
    end
    methods
        %% Constructor
        function this = SignalEEG(varargin)
        % SignalEEG     Constructor of SignalEEG class
        % Usage:
        %  >> SignalEEG()
        %  >> SignalEEG(path, filename, load_flag)
        %
        % Inputs:
        %   path           = String of folder containing measurement
        %                    (optional)
        %   filename       = String including filename and file extension of
        %                    measurement (optional, only in combination with path)
        %   load_flag      = Flag to load measurement file or not
        %                    (Default: True if path and filename passed)
        %
        
            % Set flag to False (default value if no parameters are passed)
            load_flag = 0;
            % Check numbers of input variables
            if nargin == 3
                % Set path and filename, extract name of measurement
                this.path = varargin{1};
                this.filename = varargin{2};
                this.channel = varargin{3};
                tmp = split(this.filename,'.');
                this.format = tmp{end};
                this.name = tmp{1:end-1};
                % Set flag to default True
                load_flag = true;
                channels = {};
            elseif nargin == 4 
                this.path = varargin{1};
                this.filename = varargin{2};
                this.channel = varargin{3};
                tmp = split(this.filename,'.');
                this.format = tmp{end};
                this.name = tmp{1:end-1};
                % If flag value was passed, set flag to last input variable
                load_flag = varargin{4};
                channels = {};
            elseif nargin == 5
                this.path = varargin{1};
                this.filename = varargin{2};
                this.channel = varargin{3};
                tmp = split(this.filename,'.');
                this.format = tmp{end};
                this.name = tmp{1:end-1};
                % If flag value was passed, set flag to last input variable
                load_flag = varargin{4};
                channels = varargin{5};
            end
            
            if load_flag
                disp('Start loading data!');
                % Check file extension, and load data
                if strcmp(this.format,'mat')
                    this.readMatlabFile(strcat(this.path,this.filename));
                    disp('Done loading data!');
                elseif strcmp(this.format,'edf')
                    this.readEDF(strcat(this.path,this.filename), channels);
                    disp('Done loading data!');      
                elseif strcmp(this.format,'rec')
                    this.readEDF(strcat(this.path,this.filename), channels);
                    disp('Done loading data!');
                else
                    % HERE: New file extensions can be easily added, just
                    % by copying and modifying one of the above examples
                    disp(['The file format ',this.format,' could not be loaded.']);
                end
                disp('Start loading annotation file!');
                % Check if annotation file exists in same folder, otherwise
                % file can be loaded manually with loadAnnotation(file)
                if exist(strcat(this.path,this.name,'.txt'),'file') == 2
                    this.loadAnnotation(strcat(this.path,this.name,'.txt'));
                    disp('Done loading annotation file!');
                elseif exist(strcat(this.path,this.name,'.evt'),'file') == 2
                    this.loadAnnotationHypnolab(strcat(this.path,this.name,'.evt'));
                    disp('Done loading annotation file!');
                elseif exist(strcat(this.path,this.name,'.xlsx'),'file') == 2
                    this.loadAnnotationExcel(strcat(this.path,this.name,'.xlsx'));
                    disp('Done loading annotation file!');    
                elseif exist(strcat(this.path,this.name,'.edf.XML'),'file') == 2
                    this.loadAnnotationXML(strcat(this.path,this.name,'.edf.XML'));
                    disp('Done loading annotation file!'); 
                elseif exist(strcat(this.path,this.name,'.edf.xml'),'file') == 2
                    this.loadAnnotationXML(strcat(this.path,this.name,'.edf.xml'));
                    disp('Done loading annotation file!');     
                elseif ~isempty(strcat(this.path,this.name(1:6),'*-Hypnogram.edf'))
                    filename = dir(strcat(this.path,this.name(1:6),'*-Hypnogram.edf'));
                    this.loadAnnotationEDF(strcat(this.path,filename.name));
                    disp('Done loading annotation file!');
                else
                    this.stoptime = length(this.eeg)/this.fs;
                    disp('Annotations could not be loaded!');
                    disp('Please specify the related annotation file and load it with loadAnnotation(file)');
                    error('Annotations could not be loaded!');
                end
            end
        end
        %% Main methods
        function readMatlabFile(this, file)
        % readMatlabFile    Method to load MATLAB file containing the
        %                   measurement recordings
        % Usage:
        %  >> SignalEEG.readMatlabFile(file)
        %
        % Inputs:
        %   file           = Entire path and filename of measurement
        %                    (Example: \U:\YOUR\PATH\measurement_123.mat)
        %
        % See also: load(), setEEG(), extractInfo(), alignSignal()
        
            % Load MATLAB file
            load(file,'channel');
            % Extract measurement information
            this.info = channel.info;
            this.raw_data = channel.signal';
            this.fs = channel.fs;
            this.extractInfo();
            % If file contains single recording, set the signal as EEG
            % signal, otherwise find index of EEG recording
            if size(this.raw_data, 1) == 1
                this.eeg = this.raw_data;
                this.unit = this.info.units(strcmp(this.info.label,'C4A1'));
            elseif size(this.raw_data, 1) == size(this.info.label, 2)
                this.setEEG();
            end
            % Align data to uV
            if strcmp(this.unit,'mV')
                this.eeg = SignalEEG.alignSignal(this.eeg, 1000);
            end
        end
        
        function readEDF(this, file, channels)
        % readEDF   Method to load EDF file containing the
        %           measurement recordings
        % Usage:
        %  >> SignalEEG.readEDF(file)
        %
        % Inputs:
        %   file           = Entire path and filename of measurement
        %                    (Example: \U:\YOUR\PATH\measurement_123.edf)
        %
        % See also: edfread(), setEEG(), extractInfo(), alignSignal()  
        
            % Read EDF file with edfread function
            % Function was written by Brett Shoelson and can be found in
            % the File Exchange section on the MATLAB webpage
            % https://au.mathworks.com/matlabcentral/fileexchange/31900-edfread
            if ~isempty(channels)
                [this.info,this.raw_data] = edfread(file,'targetSignals',channels);
            else
                [this.info,this.raw_data] = edfread(file);
            end
            this.setEEG();
            this.extractInfo();
            % Align data to uV
            if strcmp(this.unit,'mV')
                this.eeg = SignalEEG.alignSignal(this.eeg, 1000);
            end
        end
        
        function extractInfo(this)
        % extractInfo   Extract all the measurement information from the 
        %               info structure coming with the recordings    
        % Usage:
        %  >> SignalEEG.extractInfo()
        %         
        
            % Extract the labels related to the individual recordings
            this.labels = this.info.label;
            % Get starting time of measurement
            if contains(this.info.starttime,'.')
                tmp = strsplit(this.info.starttime,'.');
            else
                tmp = strsplit(this.info.starttime,':');
            end
            % Convert time into total amount of seconds
            this.starttime = str2double(tmp{1})*3600+str2double(tmp{2})*60+str2double(tmp{3});
            % Get total number of seconds
            this.epochs = this.info.records;
        end
        
        function setEEG(this)
        % setEEG       Find C4A1 or C3A2 channel in recordings and set it
        %              as EEG signal. Additionally extract unit and sample
        %              rate of EEG recording.
        % Usage:
        %  >> SignalEEG.setEEG()
        %
        % See also: getCell(), getRawSignal()
        if strcmp(this.channel,'auto')
            if any(strcmp(this.info.label,'C4A1'))
                this.fs = SignalEEG.getCell(this.info.frequency, this.info.label, 'C4A1');
                this.unit = SignalEEG.getCell(this.info.units, this.info.label, 'C4A1');
                this.eeg = this.getRawSignal(this.info.label,'C4A1');
            elseif any(strcmp(this.info.label,'C3A2'))
                this.fs = SignalEEG.getCell(this.info.frequency, this.info.label, 'C3A2');
                this.unit = SignalEEG.getCell(this.info.units, this.info.label, 'C3A2');
                this.eeg = this.getRawSignal(this.info.label,'C3A2');
            elseif any(strcmp(this.info.label,'C4G2'))
                this.fs = SignalEEG.getCell(this.info.frequency, this.info.label, 'C4G2');
                this.unit = SignalEEG.getCell(this.info.units, this.info.label, 'C4G2');
                this.eeg = this.getRawSignal(this.info.label,'C4G2');
            elseif any(strcmp(this.info.label,'C3G2'))
                this.fs = SignalEEG.getCell(this.info.frequency, this.info.label, 'C3G2');
                this.unit = SignalEEG.getCell(this.info.units, this.info.label, 'C3G2');
                this.eeg = this.getRawSignal(this.info.label,'C3G2');
            end
        else
            this.fs = SignalEEG.getCell(this.info.frequency, this.info.label, this.channel);
            this.unit = SignalEEG.getCell(this.info.units, this.info.label, this.channel);
            this.eeg = this.getRawSignal(this.info.label,this.channel);
        end
        end
        
        function findECG(this)
        % findECG      Find automatically label of ECG signal in recordings
        %              and set particular measurement as ECG signal
        % Usage:
        %  >> SignalEEG.findECG()
        %
        % See also: getCell(), getRawSignal(), setECG()   
        
            % Check different ECG labels
            % Add here potentially new labels and flag if no label was the
            % correct one
            if any(strcmp(this.info.label,'ECG'))
                ecg_label = 'ECG';
            elseif any(strcmp(this.info.label,'ECGL'))
                ecg_label = 'ECGL';
            elseif any(strcmp(this.info.label,'EKG'))
                ecg_label = 'EKG';
            elseif any(strcmp(this.info.label,'ECG1ECG2'))
                ecg_label = 'ECG1ECG2';
            elseif any(strcmp(this.info.label,'ECG1-ECG2'))
                ecg_label = 'ECG1-ECG2';
            elseif any(strcmp(this.info.label,'ECG1'))
                ecg_label = 'ECG1';
            elseif any(strcmp(this.info.label,'ekg'))
                ecg_label = 'ekg';
            elseif any(strcmp(this.info.label,'ECG3ECG3'))
                ecg_label = 'ECG3ECG3';
            elseif any(strcmp(this.info.label,'ECGLECGR'))
                ecg_label = 'ECGLECGR';
            elseif any(strcmp(this.info.label,'ECGRECGL'))
                ecg_label = 'ECGRECGL';    
            elseif any(strcmp(this.info.label,'ECGECG'))
                ecg_label = 'ECGECG';    
            end
            % Get ECG recording and set it as ECG signal
            sig_fs = SignalEEG.getCell(this.info.frequency, this.info.label, ecg_label);
            signal = this.getRawSignal(this.info.label,ecg_label);
            this.setECG(signal, sig_fs);
        end
        
        function findEOG(this)
        % findECG      Find automatically label of EOG signal in recordings
        %              and set particular measurement as EOG signal
        % Usage:
        %  >> SignalEEG.findEOG()
        %
        % See also: getCell(), getRawSignal(), setECG()   
        
            % Check different EOG labels
            % Add here potentially new labels and flag if no label was the
            % correct one
            if any(strcmp(this.info.label,'LOC'))
                eog_label = 'LOC';
            elseif any(strcmp(this.info.label,'ROC'))
                eog_label = 'ROC';
            elseif any(strcmp(this.info.label,'LOC-A1'))
                eog_label = 'LOC-A1';
            elseif any(strcmp(this.info.label,'ROC-A1'))
                eog_label = 'ROC-A1';
            elseif any(strcmp(this.info.label,'LOCA1'))
                eog_label = 'LOCA1';
            elseif any(strcmp(this.info.label,'ROCA1'))
                eog_label = 'ROCA1';    
            elseif any(strcmp(this.info.label,'ROC-LOC'))
                eog_label = 'ROC-LOC';
            elseif any(strcmp(this.info.label,'ROCLOC'))
                eog_label = 'ROCLOC';
            elseif any(strcmp(this.info.label,'EOGL'))
                eog_label = 'EOGL';
            elseif any(strcmp(this.info.label,'EOGdx'))
                eog_label = 'EOGdx';
            end
            % Get ECG recording and set it as ECG signal
            sig_fs = SignalEEG.getCell(this.info.frequency, this.info.label, eog_label);
            signal = this.getRawSignal(this.info.label,eog_label);
            this.setEOG(signal, sig_fs);
        end
        function setECG(this, signal, fs)
        % findECG      Find automatically label of ECG signal in recordings
        %              and set particular measurement as ECG signal
        % Usage:
        %  >> SignalEEG.findECG()
        %
        % Important: setECG() can only be called after EEG signal was set
        % and annotation file was loaded otherwise it will end in an error 
        
            % Check if EEG and ECG have same sample rate, if not assume 
            % that ECG sample rate is lower and extract shorter ECG signal.
            % Afterwards modify ECG signal the same way like EEG signal 
            % (remove time before and after manual scoring)
            this.ecg_fs = fs;
            if fs ~= this.fs
                if fs < this.fs
                    if length(signal) < length(this.eeg)
                       signal(end:length(this.eeg)) = zeros(1,length(this.eeg)-length(signal)); 
                    end
                    signal = signal(1:find(signal,1,'last'));
                    ecg_len = length(signal)/fs;
                    if ecg_len > this.stoptime
                        % Remove time before scoring
                        tmp = signal(this.timediff*fs+1:end);
                        ecg_len = length(tmp)/fs;
                        if ecg_len > this.stoptime
                            % Remove time after scoring
                            this.ecg = tmp(1:this.stoptime*fs);
                        else
                            this.ecg = tmp;
                        end
                    elseif ecg_len == this.stoptime
                        this.ecg = signal;
                    else
                        disp('Should not happen!');
                    end
                elseif fs > this.fs
                    % Remove time before scoring
                    tmp = signal(this.timediff*fs+1:end);
                    ecg_len = length(tmp)/fs;
                    if ecg_len > this.stoptime
                        % Remove time after scoring
                        this.ecg = tmp(1:this.stoptime*fs);
                    else
                        this.ecg = tmp;
                    end
                end
            else
                % Remove time before scoring
                tmp = signal(this.timediff*fs+1:end);
                ecg_len = length(tmp)/fs;
                if ecg_len > length(this.eeg)/this.fs
                    % Remove time after scoring
                    this.ecg = tmp(1:this.stoptime*fs);
                else
                    this.ecg = tmp;
                end
            end
        end

        function setEOG(this, signal, fs)
        % findECG      Find automatically label of EOG signal in recordings
        %              and set particular measurement as EOG signal
        % Usage:
        %  >> SignalEEG.findEOG()
        %
        % Important: setEOG() can only be called after EEG signal was set
        % and annotation file was loaded otherwise it will end in an error 
        
            % Check if EEG and EOG have same sample rate, if not assume 
            % that EOG sample rate is lower and extract shorter EOG signal.
            % Afterwards modify EOG signal the same way like EEG signal 
            % (remove time before and after manual scoring)
            this.eog_fs = fs;
            if fs ~= this.fs
                if fs < this.fs
                    if length(signal) < length(this.eeg)
                       signal(end:length(this.eeg)) = zeros(1,length(this.eeg)-length(signal)); 
                    end
                    signal = signal(1:find(signal,1,'last'));
                    eog_len = length(signal)/fs;
                    if eog_len > this.stoptime
                        % Remove time before scoring
                        tmp = signal(this.timediff*fs+1:end);
                        eog_len = length(tmp)/fs;
                        if eog_len > this.stoptime
                            % Remove time after scoring
                            this.eog = tmp(1:this.stoptime*fs);
                        else
                            this.eog = tmp;
                        end
                    elseif eog_len == this.stoptime
                        this.eog = signal;
                    else
                        disp('Should not happen!');
                    end
                elseif fs > this.fs
                    this.eog_fs = this.fs;
                    fs = this.fs;
                    % Remove time before scoring
                    tmp = signal(this.timediff*fs+1:end);
                    eog_len = length(tmp)/fs;
                    if eog_len > this.stoptime
                        % Remove time after scoring
                        this.eog = tmp(1:this.stoptime*fs);
                    else
                        this.eog = tmp;
                    end
                end
            else
                % Remove time before scoring
                tmp = signal(this.timediff*fs+1:end);
                eog_len = length(tmp)/fs;
                if eog_len > this.stoptime
                    % Remove time after scoring
                    this.eog = tmp(1:this.stoptime*fs);
                else
                    this.eog = tmp;
                end
            end
       end
        
        function loadAnnotation(this, file)
        % loadAnnotation    Load annotations from text file
        % Usage:
        %  >> SignalEEG.loadAnnotation(file)
        %
        % Input: 
        %   file        = Path and filename of textfile containing
        %                 scoring annotations
        %
        % Important: setECG() can only be called after EEG signal was set,
        % otherwise it will end in an error
        %
        % See also: readAnnotation(), setStartTime(), getEventTime(),
        % extractPeriodInfo(), cutSignal()
        
            % Read annotation file with textscan 
            % Annotation file must be structured like physionet.org
            % annotations, otherwise just replace this function with your
            % method
            this.annotations = readAnnotation(file);
            % Get time difference between measurement and scoring. Cut
            % signal to beginning of scoring
            this.setStartTime(strrep(this.annotations.time{1,1},'.',':'));
            % Create array with timestamps (in seconds) for all events
            % using an array containing the clock time of the events
            % (hh:mm:ss)
            this.getEventTime(this.annotations.time);
            % Extract event type, duration and location of each event from
            % beginning to the end of scoring
            [this.event, ~, this.duration, this.location] = extractPeriodInfo(this, 0, this.eventtime(end));
            % Get last second of scoring and cut signal to it
            this.stoptime = this.eventtime(end) + this.duration(end);
            if this.stoptime*this.fs < length(this.eeg)
                this.eeg = SignalEEG.cutSignal(this.eeg, 1, this.stoptime*this.fs);
                this.data = SignalEEG.cutSignal(this.data, 1, this.stoptime*this.fs);
            elseif length(this.eeg) < this.stoptime*this.fs
                this.stoptime = length(this.eeg)/this.fs;
                ind = find(this.eventtime >= this.stoptime,1);
                if ind
                    this.eventtime = this.eventtime(1:ind-1);
                else
                    this.eventtime = this.eventtime(1:end-1);
                end
                this.event = this.event(1:length(this.eventtime));
                this.duration = ceil(this.duration(1:length(this.eventtime)));
                %this.location = this.location(1:length(this.eventtime));
            end
        end
        
        function loadAnnotationHypnolab(this, file)
        % loadAnnotation    Load annotations from hypnolab file
        % Usage:
        %  >> SignalEEG.loadAnnotation(file)
        %
        % Input: 
        %   file        = Path and filename of textfile containing
        %                 scoring annotations
        %
        % Important: setECG() can only be called after EEG signal was set,
        % otherwise it will end in an error
        %
        % See also: readAnnotation(), setStartTime(), getEventTime(),
        % extractPeriodInfo(), cutSignal()
        
            % Read annotation file with textscan 
            % Annotation file must be structured like physionet.org
            % annotations, otherwise just replace this function with your
            % method
            this.annotations = readHypnolabAnnotation(file);
            % Get time difference between measurement and scoring. Cut
            % signal to beginning of scoring
            this.setStartTime(strrep(this.annotations.time{1,1},'.',':'));
            % Create array with timestamps (in seconds) for all events
            % using an array containing the clock time of the events
            % (hh:mm:ss)
            this.getEventTime(this.annotations.time);
            % Extract event type, duration and location of each event from
            % beginning to the end of scoring
            [ this.event, ~, this.duration ] = getInfoOfHypnolab( 0, this.eventtime(end), this.eventtime, this.annotations );
            % Get last second of scoring and cut signal to it
            this.stoptime = this.eventtime(end) + this.duration(end);
            if this.stoptime*this.fs < length(this.eeg)
                this.eeg = SignalEEG.cutSignal(this.eeg, 1, this.stoptime*this.fs);
                this.data = SignalEEG.cutSignal(this.data, 1, this.stoptime*this.fs);
            elseif length(this.eeg) < this.stoptime*this.fs
                this.stoptime = length(this.eeg)/this.fs;
                ind = find(this.eventtime >= this.stoptime,1);
                if ind
                    this.eventtime = this.eventtime(1:ind-1);
                else
                    this.eventtime = this.eventtime(1:end-1);
                end
                this.event = this.event(1:length(this.eventtime));
                this.duration = this.duration(1:length(this.eventtime));
                if ~isempty(this.location)
                    this.location = this.location(1:length(this.eventtime));
                end
            end
        end
        
        function loadAnnotationXML(this, file)
        % loadAnnotationXML    Load annotations from XML file
        %
        % Usage:
        %  >> SignalEEG.loadAnnotationXML(file)
        %
        % Input: 
        %   file        = Path and filename of textfile containing
        %                 scoring annotations
        %
        % Important: setECG() can only be called after EEG signal was set,
        % otherwise it will end in an error
        %
        % See also: readAnnotation(), setStartTime(), getEventTime(),
        % extractPeriodInfo(), cutSignal()
        
            % Read annotation file with xml2struct
            [epoch_length, this.event, this.arousals] = readXMLAnnotation(file);
            % Get time difference between measurement and scoring. Cut
            % signal to beginning of scoring
            this.setStartTime(strrep(this.info.starttime,'.',':'));
            % Create array with timestamps (in seconds) for all events
            % using an array containing the clock time of the events
            % (hh:mm:ss)
            this.eventtime = linspace(0,(length(this.event)-1)*epoch_length,length(this.event));
            this.duration = epoch_length*ones(size(this.eventtime,1),size(this.eventtime,2));
            this.stoptime = this.eventtime(end) + this.duration(end);
            if this.stoptime*this.fs < length(this.eeg)
                this.eeg = SignalEEG.cutSignal(this.eeg, 1, this.stoptime*this.fs);
            end
        end
 
        function loadAnnotationExcel(this, file)
        % loadAnnotationExcel    Load annotations from .xlsx file
        %
        % Usage:
        %  >> SignalEEG.loadAnnotationExcel(file)
        %
        % Input: 
        %   file        = Path and filename of textfile containing
        %                 scoring annotations
        %
        % Important: setECG() can only be called after EEG signal was set,
        % otherwise it will end in an error
        %
        % See also: readAnnotation(), setStartTime(), getEventTime(),
        % extractPeriodInfo(), cutSignal()
        
            % Read annotation file with xml2struct
            [epoch_length, this.event, clock_time, this.duration] = readXLSXAnnotation(file);
            % Get time difference between measurement and scoring. Cut
            % signal to beginning of scoring
            tmp_time = strsplit(clock_time{1},':');
            annotation_starttime = str2double(tmp_time{1})*3600+str2double(tmp_time{2})*60+str2double(tmp_time{3});
            if annotation_starttime < this.starttime
                l = 1;
                while annotation_starttime < this.starttime
                    l = l + 1;
                    tmp_time = strsplit(clock_time{l},':');
                    annotation_starttime = str2double(tmp_time{1})*3600+str2double(tmp_time{2})*60+str2double(tmp_time{3});
                end
                if annotation_starttime >= this.starttime
                    tmp_time = strsplit(clock_time{l},':');
                    annotation_starttime = str2double(tmp_time{1})*3600+str2double(tmp_time{2})*60+str2double(tmp_time{3}); 
                    this.event = this.event(l:end);
                    this.duration = this.duration(l:end);
                    this.eeg = SignalEEG.cutSignal(this.eeg, (annotation_starttime-this.starttime)*this.fs+1, length(this.eeg));
                    this.starttime = annotation_starttime;
                end                    
            elseif annotation_starttime > this.starttime
                this.eeg = SignalEEG.cutSignal(this.eeg, (annotation_starttime-this.starttime)*this.fs+1, length(this.eeg));
                this.starttime = annotation_starttime;
            end
            % Create array with timestamps (in seconds) for all events
            % using an array containing the clock time of the events
            % (hh:mm:ss)
            this.scoringtime = this.starttime;
            this.epochs = length(this.eeg)/this.fs;
            if floor(this.epochs/30) < length(this.event)
                this.event = this.event(1:floor(this.epochs/30));
                this.duration = this.duration(1:floor(this.epochs/30));
            end
            tmp = cumsum(this.duration);
            this.eventtime = [0 tmp(1:end-1)];
            this.stoptime = this.eventtime(end) + this.duration(end);
            if this.stoptime*this.fs < length(this.eeg)
                this.eeg = SignalEEG.cutSignal(this.eeg, 1, this.stoptime*this.fs);
            end
        end
        
        function loadAnnotationEDF(this, file)
        % loadAnnotationXML    Load annotations from XML file
        %
        % Usage:
        %  >> SignalEEG.loadAnnotationXML(file)
        %
        % Input: 
        %   file        = Path and filename of textfile containing
        %                 scoring annotations
        %
        % Important: setECG() can only be called after EEG signal was set,
        % otherwise it will end in an error
        %
        % See also: readAnnotation(), setStartTime(), getEventTime(),
        % extractPeriodInfo(), cutSignal()
        
            % Read annotation file with xml2struct
            [this.event, this.annotations] = readEDFAnnotation(file);
            % Get time difference between measurement and scoring. Cut
            % signal to beginning of scoring
            this.setStartTime(datestr(seconds(this.annotations.starttime(2)+this.starttime),'HH:MM:SS'));
            % Create array with timestamps (in seconds) for all events
            % using an array containing the clock time of the events
            % (hh:mm:ss)
            this.eventtime = this.annotations.starttime;
            this.duration = this.annotations.duration;
            this.stoptime = this.eventtime(end-1)-this.eventtime(2);
            if this.eventtime(end-1)*this.fs > length(this.eeg)
                this.eeg = SignalEEG.cutSignal(this.eeg, 1, this.stoptime*this.fs);
            end
            this.event = this.event(2:end-1);
            this.eventtime = this.eventtime(2:end-1)-this.eventtime(2);
            this.duration = this.duration(2:end-1);
        end
        function setStartTime(this, cuttime)
        % setStartTime  Calculate start time of scoring and set data to it
        %
        % Usage:
        %  >> SignalEEG.setStartTime()
        
            % Extract hours, minutes and seconds out of starting point
            [~,~,~, h_1, min_1, sec_1] = datevec(cuttime);
            this.scoringtime = h_1*3600+min_1*60+sec_1;
            if this.scoringtime < this.starttime
                this.timediff = (24*3600) - this.starttime + this.scoringtime;
            else
                this.timediff = this.scoringtime - this.starttime;
            end
            this.data = this.raw_data(:,this.timediff*this.fs+1:end);
            this.eeg = this.eeg(this.timediff*this.fs+1:end);            
        end
        
        function getEventTime(this, timevector)
        % getEventTime  Create array with timestamps of each event (in
        %               seconds)
        %
        % Usage:
        %  >> SignalEEG.getEventTime(timevector)
        %
        % Input:
        %       timevector      = Cell array containing clock time of each
        %                         event in hh:mm:ss
        %
        
            % Create first event at beginning of scoring
            tmp(1) = 0;
            % Get starting hour of measurement
            h_score = floor(this.scoringtime/3600);
            % Create timevector containing the timestamps of the events
            for i=2:length(timevector)
                [~,~,~, h_event, min_event, sec_event] = datevec(strrep(timevector{i,1},'.',':'));
                % Check if event is on same day as start of measurement
                if h_event >= h_score
                    tmp(i) = (h_event*3600+min_event*60+sec_event) - this.scoringtime;
                else
                    tmp(i) = (24*3600) - this.scoringtime + (h_event*3600+min_event*60+sec_event);
                end
            end
            this.eventtime = tmp;
        end
        
        function [ event, timestamp, duration, location ] = extractPeriodInfo(this, start, stop)
        % extractPeriodInfo     Get type, duration and location of each 
        %                       event in a specific time period 
        %
        % Usage:
        %  >> SignalEEG.extractPeriodInfo(start, stop)  
        %
        % Inputs:
        %       start       = Starting second of time period
        %       stop        = Ending second of time period
        %
        % See also: getInfoOfPeriod()
        
            [ event, timestamp, duration, location ] = getInfoOfPeriod( start, stop, this.eventtime, this.annotations );
        end
        
        function [descriptors, target, descriptors_equal, target_equal] = createCAPClassifierInput(this)
        % createCAPClassifierInput     Create input array and target vector
        %                              for CAP event classifier
        %                        
        %
        % Usage:
        %  >> SignalEEG.createCAPClassifierInput()  
        %
        % Outputs:
        %       descriptors            = Imbalanced dataset of features
        %       target                 = Imbalanced target vector (labelled
        %       data)
        %       descriptors_equal      = Balanced dataset of features
        %       target_equal           = Balanced target vector (labelled
        %       data)
        %
        % See also: balanceDataset()    
        
            % Calculate target vector
            target = zeros(1,this.stoptime);
            for i = 1:length(this.event)
                if this.event(i) > 5
                    if i == length(this.event)
                        target(this.eventtime(i)+1:end) = 1;
                    else
                        target(this.eventtime(i)+1:this.eventtime(i)+this.duration(i)) = 1;
                    end
                end    
            end

            % Remove REM and wake phases
            descriptors = this.eeg_features;
            for i = 1:length(this.event)
                if this.event(i) == 0 || this.event(i) == 5
                    if i == length(this.event)
                        descriptors(this.eventtime(i)+1:end,:) = nan;
                        target(this.eventtime(i)+1:end) = nan;
                    else
                        descriptors(this.eventtime(i)+1:this.eventtime(i)+this.duration(i),:) = nan;
                        target(this.eventtime(i)+1:this.eventtime(i)+this.duration(i)) = nan;
                    end
                end
            end
            descriptors = descriptors(~isnan(descriptors(:,1)),:);
            target = target(~isnan(target));
            
            [descriptors_equal, target_equal] = SignalEEG.balanceDataset(descriptors, target);
        end
        
        function [descriptors, target, descriptors_equal, target_equal] = createMultiClassInput(this)
        % createCAPClassifierInput     Create input array and target vector
        %                              for CAP event classifier
        %                        
        %
        % Usage:
        %  >> SignalEEG.createCAPClassifierInput()  
        %
        % Outputs:
        %       descriptors            = Imbalanced dataset of features
        %       target                 = Imbalanced target vector (labelled
        %       data)
        %       descriptors_equal      = Balanced dataset of features
        %       target_equal           = Balanced target vector (labelled
        %       data)
        %
        % See also: balanceDataset()    
        
            % Calculate target vector
            target = zeros(1,this.stoptime);
            for i = 1:length(this.event)
                if this.event(i) == 6
                    if i == length(this.event)
                        target(this.eventtime(i)+1:end) = 1;
                    else
                        target(this.eventtime(i)+1:this.eventtime(i)+this.duration(i)) = 1;
                    end
                elseif this.event(i) == 7
                    if i == length(this.event)
                        target(this.eventtime(i)+1:end) = 2;
                    else
                        target(this.eventtime(i)+1:this.eventtime(i)+this.duration(i)) = 2;
                    end    
                elseif this.event(i) == 8
                    if i == length(this.event)
                        target(this.eventtime(i)+1:end) = 3;
                    else
                        target(this.eventtime(i)+1:this.eventtime(i)+this.duration(i)) = 3;
                    end  
                end    
            end

            % Remove REM and wake phases
            descriptors = this.eeg_features;
            for i = 1:length(this.event)
                if this.event(i) == 0 || this.event(i) == 5 || this.event(i) > 8
                    if i == length(this.event)
                        descriptors(this.eventtime(i)+1:end,:) = nan;
                        target(this.eventtime(i)+1:end) = nan;
                    else
                        descriptors(this.eventtime(i)+1:this.eventtime(i)+this.duration(i),:) = nan;
                        target(this.eventtime(i)+1:this.eventtime(i)+this.duration(i)) = nan;
                    end
                end
            end
            descriptors = descriptors(~isnan(descriptors(:,1)),:);
            target = target(~isnan(target));
            target = target(1:size(descriptors,1));
            
            [descriptors_equal, target_equal] = SignalEEG.balanceDataset(descriptors, target);
        end
        
        function [descriptors, target] = createCNNInput(this)
        % createCAPClassifierInput     Create input array and target vector
        %                              for CAP event classifier
        %                        
        %
        % Usage:
        %  >> SignalEEG.createCAPClassifierInput()  
        %
        % Outputs:
        %       descriptors            = Imbalanced dataset of features
        %       target                 = Imbalanced target vector (labelled
        %       data)
        %       descriptors_equal      = Balanced dataset of features
        %       target_equal           = Balanced target vector (labelled
        %       data)
        %
        % See also: balanceDataset()    
        
            % Calculate target vector
            target = zeros(1,this.stoptime);
            for i = 1:length(this.event)
                if this.event(i) == 6
                    if i == length(this.event)
                        target(this.eventtime(i)+1:end) = 1;
                    else
                        target(this.eventtime(i)+1:this.eventtime(i)+this.duration(i)) = 1;
                    end
                elseif this.event(i) == 7
                    if i == length(this.event)
                        target(this.eventtime(i)+1:end) = 2;
                    else
                        target(this.eventtime(i)+1:this.eventtime(i)+this.duration(i)) = 2;
                    end    
                elseif this.event(i) == 8
                    if i == length(this.event)
                        target(this.eventtime(i)+1:end) = 3;
                    else
                        target(this.eventtime(i)+1:this.eventtime(i)+this.duration(i)) = 3;
                    end  
                end    
            end

            % Remove REM and wake phases
            descriptors = this.eeg_features;
            descriptors_inds = zeros(1, length(descriptors));
            for i = 1:length(this.event)
                if this.event(i) == 0 || this.event(i) == 5 || this.event(i) > 8
                    if i == length(this.event)
                        descriptors_inds(this.eventtime(i)+1:end) = 1;
                        target(this.eventtime(i)+1:end) = nan;
                    else
                        descriptors_inds(this.eventtime(i)+1:this.eventtime(i)+this.duration(i)) = 1;
                        target(this.eventtime(i)+1:this.eventtime(i)+this.duration(i)) = nan;
                    end
                end
            end
            descriptors(descriptors_inds>0) = [];
            target = target(~isnan(target));
            target = target(1:size(descriptors,1));
        end
        
        function plotEEG(this, start, stop, CAP)
        % plotEEG     Plot EEG signal 
        %
        % Usage:
        %  >> SignalEEG.plotEEG(start, stop, CAP)  
        %
        % Inputs:
        %       start       = Starting second of time period
        %       stop        = Ending second of time period
        %       CAP         = Flag to indicate CAP events in plot
        %
        % See also: plotSignal()    
            
            % Get time period of signal
            x = SignalEEG.cutSignal(this.eeg, start*this.fs+1, stop*this.fs);
            % Create figure
            figure('Position',[350,300,1250,500]);
            hold on   
            grid on
            this.plotSignal(x, start, stop, this.fs, this.unit{1}, CAP);
        end
        
        function plotEEG_ECG(this, start, stop, CAP)
        % plotEEG_ECG     Plot EEG and ECG signal 
        %
        % Usage:
        %  >> SignalEEG.plotEEG_ECG(start, stop, CAP)  
        %
        % Inputs:
        %       start       = Starting second of time period
        %       stop        = Ending second of time period
        %       CAP         = Flag to indicate CAP events in plot
        %
        % See also: plotSignal()  
        
            % Get time period of signal
            x_eeg = SignalEEG.cutSignal(this.eeg, start*this.fs+1, stop*this.fs);
            x_ecg = SignalEEG.cutSignal(this.ecg, start*this.ecg_fs+1, stop*this.ecg_fs);
            
            % Create figure
            figure('Position',[350,300,1250,500]);
            subplot(2,1,1);
            hold on   
            grid on            
            this.plotSignal(x_eeg, start, stop, this.fs, this.unit{1}, CAP);
            subplot(2,1,2);
            hold on   
            grid on            
            this.plotSignal(x_ecg, start, stop, this.ecg_fs, 'mV', CAP);
        end
        
        function plotChannels(this, labels_plot, start, stop, CAP)
        % plotEEG     Plot all channels mentioned in labels vector 
        %
        % Usage:
        %  >> SignalEEG.plotChannels(labels_plot, start, stop, CAP)  
        %
        % Inputs:
        %       labels_plot = Cell array containing labels of requested
        %       channels
        %       start       = Starting second of time period
        %       stop        = Ending second of time period
        %       CAP         = Flag to indicate CAP events in plot
        %
        % See also: plotSignal()  
        
            % Create figure
            figure('Position',[350,250,1250,750]);
            for i = 1 : length(labels_plot)
                x_tmp = this.getSignal(this.labels, labels_plot{i});
                fs_tmp = SignalEEG.getCell(this.info.frequency, this.info.label, labels_plot{i});
                unit_tmp = SignalEEG.getCell(this.info.units, this.info.label, labels_plot{i});
                x = SignalEEG.cutSignal(x_tmp, start*fs_tmp+1, stop*fs_tmp);
                subplot(length(labels_plot),1,i);
                hold on   
                grid on            
                this.plotSignal(x, start, stop, fs_tmp, unit_tmp{1}, CAP);
                title(labels_plot{i});
            end
        end
        
        function plotSpectrum(this,signal, start, stop, fs, unit, overlap, CAP)
        % Plot Multitaper Spectrum of specific time period    
            plotMultitaperSpectrum(this, signal, start, stop, fs, unit, overlap, CAP);
        end
        
        function x = getRawSignal(this, data, string)
        % Get raw channel of specific index
            ind = strcmp(data, string);
            x = this.raw_data(ind,:);
        end
        
        function x = getSignal(this, data, string)
        % Get signal of specific index
            ind = strcmp(data, string);
            x = this.data(ind,:);
        end
    end
    
    %% Additional minor methods
    methods(Static)
        function signal_cut = cutSignal(signal, start, stop)
        % Cut signal to start and stop sample
        % Start and stop are not passed in seconds, but as the actual
        % sample number (second*fs)
            if size(signal,1) > 1
                signal_cut = signal(:,start:stop);
            else
                signal_cut = signal(start:stop);
            end
        end
        
        function sig_mod = alignSignal(signal, factor)
        % Modify signal magnitude if unit is different
            sig_mod = signal*factor;
        end
        
        function x = getCell(data1, data2, string)
        % Get object in data1 at index which is the index of string in data2
            ind = strcmp(data2,string);
            x = data1(ind);
        end
        
        function [x, y] = balanceDataset(features, target)
        % Balance out the number of events and non-events in feature and
        % target vector
        % Select random number of timesteps for longer vector (event or
        % non-event)
            tmp_Event = [];
            tmp_NonEvent = [];
            for i = 1:size(features,2)
               tmp_Event(:,i) = features(target > 0,i);
               tmp_NonEvent(:,i) = features(target == 0,i);
            end
                       
            if length(tmp_Event) > length(tmp_NonEvent)
                indx = randperm(size(tmp_Event,1),size(tmp_NonEvent,1));
                x = [tmp_Event(indx,:); tmp_NonEvent];
                y = zeros(1,length(x));
                y(1:size(tmp_NonEvent,1)) = 1;
            else
                indx = randperm(size(tmp_NonEvent,1),size(tmp_Event,1));
                x = [tmp_Event; tmp_NonEvent(indx,:)];
                y = zeros(1,length(x)); 
                y(1:size(tmp_Event,1)) = 1;
            end
        end
    end
end