function [ ] = pdfPlotMultiChannel(eeg, channel_list, labels, prediction, window, save_path)
    
    for i = 1 : length(channel_list)
        channel_ind(i) = find(strcmp(eeg.labels,channel_list{i}) == 1);
    end
    counter = 1;
    for i = 0 : window : eeg.stoptime
        stop = i + window;
        if stop > eeg.stoptime
            figure1 = figure;
            set(figure1, 'units','normalized','outerposition',[0 0 1 1],'Color',[1 1 1]);
            set(figure1,'Visible','Off');
            hold on   
            grid on            
            plotClassificationMultiChannel(eeg, channel_list, channel_ind, labels, prediction, eeg.fs, i, eeg.stoptime, eeg.annotations)
            x = xlabel('Time','FontSize',14,'interpreter','latex');
            set(x, 'Units', 'Normalized', 'Position', [0.5 -0.3, 0]);
            export_fig(strcat(save_path,eeg.name,'_',num2str(counter),'.pdf'),'-pdf',figure1);
            counter = counter + 1;
        else      
            figure1 = figure;
            set(figure1, 'units','normalized','outerposition',[0 0 1 1],'Color',[1 1 1]);
            set(figure1,'Visible','Off');
            % Calculate minimum and maximum limit of data
            hold on   
            grid on            
            plotClassificationMultiChannel(eeg, channel_list, channel_ind, labels, prediction, eeg.fs, i, i+window, eeg.annotations)
            x = xlabel('Time','FontSize',14);
            set(x, 'Units', 'Normalized', 'Position', [0.5 -0.05, 0]);
            export_fig(strcat(save_path,eeg.name,'_',num2str(counter),'.pdf'),'-pdf',figure1);
            counter = counter + 1;
        end
    end
end