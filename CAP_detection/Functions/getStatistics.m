% getStatistics    Track differen sleep stages and CAP events in EEG
%                  recordings
%
% Usage:
%  >> getStatistics(tracker, eegSignal, excel, verbose)
%   
%  One input: 
%  getStatistics(tracker, eegSignal) -> Only statistics calculation
%  getStatistics(tracker, excel) -> Only Excel file creation (True/False)
%
%  Two inputs: 
%  getStatistics(tracker, eegSignal, verbose) -> Statistics calculation and
%  statistics display(True/False)
%
%  Three input: 
%  getStatistics(tracker, eegSignal, verbose, excel) -> All three parameter
%
%
% Inputs:
%       tracker         = Structure containing information of previous
%                         signals
%       eegSignal       = Object of SignalEEG class
%       excel           = Flag to write tracker data to an Excel sheet (True/False)
%       verbose         = Display statistics of current measurement (True/False)
%
% Output:
%       tracker         = Updated version of tracker structure
%
% See also: pmtm(), imagesc()

function [ tracker ] = getStatistics( tracker, varargin )

excel_flag = 0;
disp_flag = 0;
calc_flag = 0;
if nargin == 2
    if isa(varargin{1},'char')
        excel_flag = strcmp(varargin{1},'True');
    elseif isa(varargin{1},'SignalEEG')
        eegSignal = varargin{1};
        calc_flag = 1;
    end
elseif nargin == 3
    calc_flag = 1;
    eegSignal = varargin{1};
    target = varargin{2};    
elseif nargin == 4
    calc_flag = 1;
    eegSignal = varargin{1};
    target = varargin{2}; 
    disp_flag = strcmp(varargin{3},'True');
elseif nargin == 5
    calc_flag = 1;
    eegSignal = varargin{1};
    target = varargin{2}; 
    disp_flag = strcmp(varargin{3},'True');
    excel_flag = strcmp(varargin{4},'True');
end

if calc_flag
    [Wake, REM, Wake_REM, NREM, Other, A1, A2, A3] = deal(0, 0, 0, 0, 0, 0, 0, 0);

    for i=1:length(eegSignal.event)
        % Check if CAP event and if so which type of CAP, otherwise check which
        % kind of sleep stage it is
        switch eegSignal.event(i)
            case 0
                Wake = Wake + eegSignal.duration(i);
            case 1
                NREM = NREM + eegSignal.duration(i);
            case 2
                NREM = NREM + eegSignal.duration(i);
            case 3
                NREM = NREM + eegSignal.duration(i);
            case 4
                NREM = NREM + eegSignal.duration(i);
            case 5
                REM = REM + eegSignal.duration(i);
            case 6
                A1 = A1 + eegSignal.duration(i);
            case 7 
                A2 = A2 + eegSignal.duration(i);        
            case 8
                A3 = A3 + eegSignal.duration(i);
            otherwise
                Other = Other + eegSignal.duration(i);
        end
    end
    
    NREM = length(target);
    A1 = sum(target==1);
    A2 = sum(target==2);
    A3 = sum(target==3);
    Wake_REM = eegSignal.stoptime - NREM;
    name = eegSignal.name(isstrprop(eegSignal.name,'alphanum')==1);
    tracker.(name).name = eegSignal.name;
    tracker.(name).Wake = Wake;
    tracker.(name).NREM = NREM;
    tracker.(name).REM = REM;
    tracker.(name).Wake_REM = Wake_REM;
    tracker.(name).Other = Other;
    tracker.(name).A1 = A1;
    tracker.(name).A2 = A2;
    tracker.(name).A3 = A3;
    tracker.(name).Total = eegSignal.stoptime;
    tracker.(name).TotalScored = Wake+NREM+REM;

    if disp_flag
        disp('-------------------------------------------------');
        disp('Measurement statistics:');
        disp(['Total Time: ',num2str(eegSignal.stoptime)]);
        disp(['Wake Time: ',num2str(Wake)]);
        disp(['REM Time: ',num2str(REM)]);
        disp(['NREM Time: ',num2str(NREM)]);
        disp(['Wake_REM Time: ',num2str(Wake_REM)]);
        disp(['Other Time: ',num2str(Other)]);
        disp(['Total Calculated Time: ',num2str(Wake+NREM+REM)]);
        disp(['A1 Time: ',num2str(A1)]);
        disp(['A2 Time: ',num2str(A2)]);
        disp(['A3 Time: ',num2str(A3)]);
        disp('-------------------------------------------------');
    end
end

if excel_flag
    % Create Excel filename
    get_datetime = datestr(now,'dd-mmm-yyyy');
    excel_name = ['Statistics_',get_datetime,'.xlsx'];
    % Write headline
    xlswrite(excel_name, {'Measurement statistics'}, 'D2:D2');
    % Write header of table
    xlswrite(excel_name, {'Name','Wake','REM','Wake_REM','NREM','Other','A1','A2','A3','Total Time','Total calculated time'}, 'A4:K4');
    % Write tracker data to Excel sheet
    names = fieldnames(tracker); 
    for ind = 1:numel(names)
        name = names{ind}(isstrprop(names{ind},'alphanum')==1);
        tmp_name = tracker.(name);
        col_range = ['A',num2str(ind+5),':K',num2str(ind+5)];
        xlswrite(excel_name, {tmp_name.name,tmp_name.Wake,tmp_name.REM,tmp_name.Wake_REM,tmp_name.NREM,tmp_name.Other,tmp_name.A1,tmp_name.A2,tmp_name.A3,tmp_name.Total,tmp_name.TotalScored}, col_range);
    end 
end
end