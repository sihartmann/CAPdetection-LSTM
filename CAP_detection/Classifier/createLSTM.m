function [layers] = createLSTM(LSTM_para)
    
    numLayers = length(LSTM_para.numHidden);
    if strcmp(LSTM_para.lossFunction, 'Fscore')
        if numLayers == 1
            layers = [ ...
                sequenceInputLayer(LSTM_para.inputSize)
                lstmLayer(LSTM_para.numHidden,'OutputMode','last')
                fullyConnectedLayer(448)
                reluLayer
                fullyConnectedLayer(LSTM_para.numClasses)
                softmaxLayer
                lossFunction(LSTM_para.beta,'loss')];
        elseif numLayers == 2
            layers = [ ...
                sequenceInputLayer(LSTM_para.inputSize)
                lstmLayer(LSTM_para.numHidden(1))
                lstmLayer(LSTM_para.numHidden(2),'OutputMode','last')
                fullyConnectedLayer(448)
                reluLayer
                fullyConnectedLayer(LSTM_para.numClasses)
                softmaxLayer
                lossFunction(LSTM_para.beta,'loss')];    
        else 
            layers = [ ...
                sequenceInputLayer(LSTM_para.inputSize)
                lstmLayer(LSTM_para.numHidden(1))
                lstmLayer(LSTM_para.numHidden(2))
                lstmLayer(LSTM_para.numHidden(3),'OutputMode','last')
                fullyConnectedLayer(448)
                reluLayer
                fullyConnectedLayer(LSTM_para.numClasses)
                softmaxLayer
                lossFunction(LSTM_para.beta,'loss')];    
        end
    else
        if numLayers == 1
            layers = [ ...
                sequenceInputLayer(LSTM_para.inputSize)
                lstmLayer(LSTM_para.numHidden,'OutputMode','last')
                fullyConnectedLayer(448)
                reluLayer
                fullyConnectedLayer(LSTM_para.numClasses)
                softmaxLayer
                classificationLayer];
        elseif numLayers == 2
            layers = [ ...
                sequenceInputLayer(LSTM_para.inputSize)
                lstmLayer(LSTM_para.numHidden(1))
                lstmLayer(LSTM_para.numHidden(2),'OutputMode','last')
                fullyConnectedLayer(448)
                reluLayer
                fullyConnectedLayer(LSTM_para.numClasses)
                softmaxLayer
                classificationLayer];    
        else 
            layers = [ ...
                sequenceInputLayer(LSTM_para.inputSize)
                lstmLayer(LSTM_para.numHidden(1))
                lstmLayer(LSTM_para.numHidden(2))
                lstmLayer(LSTM_para.numHidden(3),'OutputMode','last')
                fullyConnectedLayer(448)
                reluLayer
                fullyConnectedLayer(LSTM_para.numClasses)
                classificationLayer];
                %regressionLayer];
                %myRegressionLayer(LSTM_para.beta,'loss')];    
        end
    end
end

