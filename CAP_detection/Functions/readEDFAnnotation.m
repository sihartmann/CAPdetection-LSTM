function [events, annotations] = readEDFAnnotation(file)

[~, header] = readEDF(file);
annotations = header.annotation;
for i = 1 : length(annotations.event)
   if strcmp(annotations.event{i}, 'Sleep stage W')
       events(i) = 0;
   elseif strcmp(annotations.event{i}, 'Sleep stage 1')
       events(i) = 1;
   elseif strcmp(annotations.event{i}, 'Sleep stage 2')
       events(i) = 2;
   elseif strcmp(annotations.event{i}, 'Sleep stage 3')
       events(i) = 3;
   elseif strcmp(annotations.event{i}, 'Sleep stage 4')
       events(i) = 4;
   elseif strcmp(annotations.event{i}, 'Sleep stage R')
       events(i) = 5;
   else
       events(i) = 6;
   end
end
end