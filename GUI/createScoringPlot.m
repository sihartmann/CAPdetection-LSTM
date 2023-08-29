function [ ] = createScoringPlot(eeg, prediction, filename)


figure1 = figure;
set(figure1, 'units','normalized','outerposition',[0 0 1 1],'Color',[1 1 1]);
set(figure1,'Visible','Off');
hold on   
grid on
subplot(3,1,1);
hold on   
grid on
createScoringPlot_Signal(eeg,eeg.fs,eeg.unit{1});
subplot(3,1,2);
hold on   
grid on
createScoringPlot_Hypnogram(eeg,prediction);
subplot(3,1,3);
hold on   
grid on
createScoringPlot_Spectrum(eeg,eeg.fs,0.25)

export_fig(strcat(filename,'.pdf'),'-pdf',figure1);
%saveas(figure1, strcat(filename,'.fig'));
close(figure1);
