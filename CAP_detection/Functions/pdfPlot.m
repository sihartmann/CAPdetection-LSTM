% plotSignal    Plot signal in defined figure environment
%
% Usage:
%  >> SignalEEG.plotSignal(signal, start, stop, fs, unit, CAP)  
%
% Inputs:
%       signal      = Original signal
%       start       = Starting second of time period
%       stop        = Ending second of time period
%       fs          = Sample rate of input signal
%       unit        = Magnitude unit of input signal
%       CAP         = Flag to indicate CAP events
%
% See also: plot()

function [ ] = pdfPlot(eeg, labels, prediction, window, plot_number, save_path)
    counter = 1;
    for i = 0 : plot_number*window : eeg.stoptime
        stop = i + plot_number*window;
        if stop > eeg.stoptime
            figure1 = figure;
            set(figure1, 'units','normalized','outerposition',[0 0 1 1],'Color',[1 1 1]);
            set(figure1,'Visible','Off');
            for j = 1 : plot_number
                if i+j*window >= eeg.stoptime
                    subplot(plot_number,1,j);
                    hold on   
                    grid on            
                    plotClassificationMultiClass(eeg.eeg, labels, prediction, eeg.fs, i+(j-1)*window, eeg.stoptime, eeg.starttime)
                    break;
                else
                    subplot(plot_number,1,j);
                    hold on   
                    grid on            
                    plotClassificationMultiClass(eeg.eeg, labels, prediction, eeg.fs, i+(j-1)*window, i+j*window, eeg.starttime)
                end
            end
            x = xlabel('Time','FontSize',14,'interpreter','latex');
            set(x, 'Units', 'Normalized', 'Position', [0.5 -0.3, 0]);
            export_fig(strcat(save_path,eeg.name,'_',num2str(counter),'.pdf'),'-pdf',figure1);
            counter = counter + 1;
        else      
            figure1 = figure;
            set(figure1, 'units','normalized','outerposition',[0 0 1 1],'Color',[1 1 1]);
            set(figure1,'Visible','Off');
            % Calculate minimum and maximum limit of data
            for j = 1 : plot_number
                subplot(plot_number,1,j);
                hold on   
                grid on            
                plotClassificationMultiClass(eeg.eeg, labels, prediction, eeg.fs, i+(j-1)*window, i+j*window, eeg.starttime)
            end
            x = xlabel('Time','FontSize',14,'interpreter','latex');
            set(x, 'Units', 'Normalized', 'Position', [0.5 -0.3, 0]);
            export_fig(strcat(save_path,eeg.name,'_',num2str(counter),'.pdf'),'-pdf',figure1);
            counter = counter + 1;
        end
    end
end