classdef ClassificationEEG < handle
%ClassificationEEG: Classification class including training and process for
%LDA, kNN, NN, LSTM and Bi-LSTM classifier. Moreover, the class contains 
%static methods (callable without a class object) to modify the datasets
%for training and testing (normalization, shuffling, LSTM sequence
%creation).

    properties
        train_input = [];       % KxN double array containing K feature rows of length N
        train_target = [];      % 1xN double vector of length N containing labelled data for training input
        class_name = '';        % Name of the classifier
        classifier ;            % Actual classifier
        parameter = struct;     % Structure containing parameter settings for classifier
        mu_train = [];          % Kx1 double array containing K mean values for each feature vector 
        sigma_train = [];       % Kx1 double array containing K standard variation values for each feature vector        
    end
    methods
        function this = ClassificationEEG(varargin)
        % ClassificationEEG -  Constructor for the class of the same name
        % Usage:
        %  >> obj = ClassificationEEG()
        %  >> obj = ClassificationEEG(classifier_name, classifier_parameter)
        %
        % Inputs:
        %   classifier_name           = name of classifier (LDA, kNN, NN,
        %   LSTM, BiLSTM)
        %   classifier_parameter      = parameter settings as struct
        %
        % Outputs:
        %   obj                      = class object

            if nargin == 2
                this.class_name = varargin{1};
                this.parameter = varargin{2};
            end       
        end
        
        function trainClassifier(this, train_input, train_target, norm_flag, varargin)
        % trainClassifier -  Method to train the classifier with passed
        % data
        %
        % Usage:
        %  >> obj.trainClassifier(train_input, train_target, norm_flag)
        %  >> obj.trainClassifier(train_input, train_target, norm_flag, mu, sigma)
        %
        % Inputs:
        %   train_input           = KxN double array containing K feature
        %   rows of length N for shallow classifier, or 1xM cell array with
        %   KxL double arrays containing the K features of length L for M
        %   subjects for LSTM classifier
        %
        %   train_target          = 1xN double vector of length N
        %   containing labelled data for training of shallow classifier, or
        %   or 1xM cell array with 1xN double vector of length N
        %   containing labelled data for M subjects to train deep
        %   classifier           
        %
        %   norm_flag             = Flag to normalize input data or not
        %   (true/false)
        %
        %   mu                    = If data already normalized, pass mu and
        %   sigma of training data for testing afterwards
        %
        %   sigma                 = If data already normalized, pass mu and
        %   sigma of training data for testing afterwards
        %
        % See also: lda(), knn(), train(), trainNetwork()

            if norm_flag 
                % Due to the sequence classification, data for LSTM
                % classifier is normalized for every subject
                if ~any(strcmp({'LSTM','BiLSTM','DeepNN','CNN-LSTM','CNN-LSTM2'}, this.class_name))
                    [train_input, this.mu_train, this.sigma_train] = ClassificationEEG.normalizeTrainingData(train_input);
                    [train_input, train_target] = ClassificationEEG.shuffleData(train_input, train_target);
                elseif ~any(strcmp({'CNN-LSTM','CNN-LSTM2'}, this.class_name))
                    this.mu_train =  mean(cell2mat(cellfun(@(x) mean(x,2), train_input,'UniformOutput', false)),2);
                    this.sigma_train = mean(cell2mat(cellfun(@(x) std(x,0,2), train_input,'UniformOutput', false)),2);
                elseif ~any(strcmp({'CNN-LSTM'}, this.class_name))
                    this.mu_train =  mean(mean(cell2mat(cellfun(@(x) mean(x,2), train_input,'UniformOutput', false)),2));
                    this.sigma_train = mean(mean(cell2mat(cellfun(@(x) std(x,0,2), train_input,'UniformOutput', false)),2));
                else 
                    tmp =  cellfun(@(x) mean(x,1), train_input,'UniformOutput', false);
                    tmp = cell2mat(permute(tmp,[2,1,3]));
                    this.mu_train = mean(tmp,1);
                    tmp =  cellfun(@(x) std(x,0,1), train_input,'UniformOutput', false);
                    tmp = cell2mat(permute(tmp,[2,1,3]));                    
                    this.sigma_train = mean(tmp,1);
                end
            else
                if nargin > 3               
                    this.mu_train = varargin{1};
                    this.sigma_train = varargin{2};
                end
            end
            
            if ~isempty(this.parameter)
                switch this.class_name
                    case 'LDA'
                        data = [train_input; train_target]';
                        % Train LDA classifier
                        this.classifier = lda(data, this.parameter);
                        this.train_input = train_input;
                        this.train_target = train_target;
                    case 'kNN'
                        data = [train_input; train_target]';
                        % Train kNN classifier
                        this.classifier = knn(data, this.parameter); 
                        this.train_input = train_input;
                        this.train_target = train_target;                        
                    case 'NN'
                        % Create neural network
                        net = createNN(this.parameter);
                        
                        if strcmp(this.parameter.GPU,'yes')
                            net.trainFcn = 'trainscg';  
                        end
                        
                        % Divide the dataset into a single training set
                        net.divideFcn = 'dividerand';
                        net.divideParam.trainRatio = 100/100;
                        net.divideParam.valRatio = 0/100;
                        net.divideParam.testRatio = 0/100;

                        % Configure network to set random initial weights
                        net = configure(net,train_input,train_target); 
                        
                        % Train network
                        [this.classifier,~] = train(net,train_input,train_target,nn7);
                        this.train_input = train_input;
                        this.train_target = train_target;   
                    case 'DeepNN'
                        x_train = [];
                        y_train = [];
                        for i = 1 : size(train_input,2)
                            if norm_flag
                                x_tmp = (train_input{i}-this.mu_train)./this.sigma_train;
                                y_tmp = train_target{i};
                            else
                                x_tmp = train_input{i};
                                y_tmp = train_target{i};
                            end
                            x_train = [x_train; x_tmp'];
                            y_train = [y_train; y_tmp'];
                        end
                        if strcmp(this.parameter.dataSet,'balanced')
                            [x_train, y_train] = ClassificationEEG.createBalancedLSTMData3(x_train, y_train);
                        end
                        % Create sequences for LSTM and concatenate measurements
                        x_train = x_train';
                        x_train = reshape(x_train, [size(x_train,1) 1 1 size(x_train,2)]);
                        y_train = y_train';
                        % Stack layers of LSTM classifier
                        DeepNN = createDeepNN(this.parameter);
                        % Specify training options
                        % To get more information about the parameters,
                        % check the documentation of trainingOptions()
                        options = trainingOptions('adam', ...
                            'ExecutionEnvironment',this.parameter.environment, ...
                            'MaxEpochs',this.parameter.maxEpochs, ...
                            'MiniBatchSize',this.parameter.miniBatchSize, ...
                            'SequenceLength','longest', ...
                            'InitialLearnRate', this.parameter.initialLearnRate, ...
                            'GradientDecayFactor', 0.9, ...
                            'SquaredGradientDecayFactor', 0.999, ...
                            'Epsilon', 1e-8, ...
                            'GradientThresholdMethod', 'l2norm', ...
                            'L2Regularization', this.parameter.L2Regularization, ...
                            'LearnRateSchedule', 'piecewise', ...
                            'LearnRateDropPeriod', this.parameter.learnRateDropPeriod, ...
                            'LearnRateDropFactor', this.parameter.learnRateDropFactor, ...
                            'Shuffle','once', ...
                            'Verbose',this.parameter.verbose, ...
                            'Plots','none');
                        % Target vector has to be from type categorical
                        y_train = categorical(y_train-1);
                        % Training
                        this.classifier = trainNetwork(x_train,y_train,DeepNN,options);
                        this.train_input = train_input;
                        this.train_target = train_target;                          
                    case 'LSTM'
                        % Create sequences for LSTM and concatenate measurements
                        x_train = [];
                        y_train = [];
                        for i = 1 : size(train_input,2)
                            if norm_flag
                                x_tmp = (train_input{i}-this.mu_train)./this.sigma_train;
                            else
                                x_tmp = train_input{i};
                            end
                            [x_tmp, y_tmp] = ClassificationEEG.createSequencesLSTM(x_tmp, train_target{i}, this.parameter.seqLen);
                            x_train = [x_train; x_tmp'];
                            y_train = [y_train; y_tmp'];
                        end
                        if strcmp(this.parameter.dataSet,'balanced')
                            [x_train, y_train] = ClassificationEEG.createBalancedLSTMData(x_train, y_train);
                        end
                        % Stack layers of LSTM classifier
                        LSTM = createLSTM(this.parameter);
                        % Specify training options
                        % To get more information about the parameters,
                        % check the documentation of trainingOptions()
                        options = trainingOptions('adam', ...
                            'ExecutionEnvironment',this.parameter.environment, ...
                            'MaxEpochs',this.parameter.maxEpochs, ...
                            'MiniBatchSize',this.parameter.miniBatchSize, ...
                            'SequenceLength','longest', ...
                            'InitialLearnRate', this.parameter.initialLearnRate, ...
                            'GradientDecayFactor', 0.9, ...
                            'SquaredGradientDecayFactor', 0.999, ...
                            'Epsilon', 1e-8, ...
                            'GradientThresholdMethod', 'l2norm', ...
                            'L2Regularization', this.parameter.L2Regularization, ...
                            'LearnRateSchedule', 'piecewise', ...
                            'LearnRateDropPeriod', this.parameter.learnRateDropPeriod, ...
                            'LearnRateDropFactor', this.parameter.learnRateDropFactor, ...
                            'Shuffle','once', ...
                            'Verbose',this.parameter.verbose, ...
                            'Plots','none');
                        % Target vector has to be from type categorical
%                         if strcmp(this.parameter.lossFunction, 'Fscore')
%                             y_train = categorical(y_train);    
%                         else
%                             y_CAP = cell2mat(cellfun(@(x) x(1), y_train,'UniformOutput', false));
%                             y_REM = cell2mat(cellfun(@(x) x(2), y_train,'UniformOutput', false));
%                             y_train = [y_CAP y_REM];
%                         end
                        y_train = categorical(y_train); 
                        % Training
                        this.classifier = trainNetwork(x_train,y_train,LSTM,options);
                        this.train_input = train_input;
                        this.train_target = train_target;                        
                end
                
            else
               disp('Define classifier and its parameter!'); 
            end
        end
        function output = testClassifier(this, test_input, test_target, norm_flag, metric_calc, post_proc)
        % testClassifier -  Method to test the classifier with passed
        % data
        %
        % Usage:
        %  >> output    = obj.testClassifier(test_input, test_target, metric_calc, post_proc)
        %
        % Inputs:
        %   test_input            = Cell array containing the KxL double
        %   vector of test data with K features of length L for each subject
        %
        %   test_target           = Cell array containing the 1xL double
        %   vector of labelled data of length L for each subject
        %
        %   norm_flag             = Flag to normalize input data or not
        %   (true/false)
        %
        %   metric_calc           = Flag to set if classifier performance
        %   is calculated and passed as output or predictions and labels
        %   are defined as output (true/false)
        %
        %   post_proc             = Flag to activate post-processing for
        %   CAP classification afterwards (if no CAP classification
        %   deactivate post-processing to get raw
        %   prediction)
        %
        % See also: getMetrics(), classify(), postProcessingCAP()
            
            if ~isempty(this.parameter)
                switch this.class_name
                    case 'LDA'
                        for i = 1 : numel(test_input)
                            if norm_flag
                                % Normalize test data based on mean and std from training dataset
                                x = ClassificationEEG.normalizeTestData(test_input{i}, this.mu_train, this.sigma_train);
                            else
                                x = test_input{i};
                            end
                            % Predict classification with trained
                            % classifier
                            y = this.classifier.predictFcn(x');
                            % Post-process classification
                            if post_proc
                                y_pred{:,i} = postProcessingCAP(y', x);
                            else
                                y_pred{:,i} = y';
                            end
                        end
                        if metric_calc
                            output = getMetrics(y_pred, test_target);
                        else
                            output = [y_pred, test_target];
                        end
                    case 'kNN'
                        for i = 1 : numel(test_input)
                            if norm_flag
                                % Normalize test data based on mean and std from training dataset
                                x = ClassificationEEG.normalizeTestData(test_input{i}, this.mu_train, this.sigma_train);
                            else
                                x = test_input{i};
                            end
                            % Predict classification with trained
                            % classifier
                            y = this.classifier.predictFcn(x');
                            % Post-process classification
                            if post_proc
                                y_pred{:,i} = postProcessingCAP(y', x);
                            else
                                y_pred{:,i} = y';
                            end
                        end
                        if metric_calc
                            output = getMetrics(y_pred, test_target);
                        else
                            output = [y_pred, test_target];
                        end                    
                    case 'NN'
                        for i = 1 : numel(test_input)
                            if norm_flag
                                % Normalize test data based on mean and std from training dataset
                                x = ClassificationEEG.normalizeTestData(test_input{i}, this.mu_train, this.sigma_train);
                            else
                                x = test_input{i};
                            end
                            % Predict with trained classifier
                            y = this.classifier(x,nn7);
                            % Calculate error percentage after thresholding output
                            % based on logsig distribution
                            y = y>=0.5; % Set 0.5 as decision threshold
                            % Post processing
                            if post_proc
                                y_pred{:,i} = postProcessingCAP(y, x);
                            else
                                y_pred{:,i} = y;
                            end 
                        end
                        if metric_calc
                            output = getMetrics(y_pred, test_target);
                        else
                            output = [y_pred, test_target];
                        end
                    case 'DeepNN'
                        for i = 1 : numel(test_input)
                            if norm_flag
                                % Normalize test data based on mean and std from training dataset
                                x = ClassificationEEG.normalizeTestData(test_input{i}, this.mu_train, this.sigma_train);
                            else
                                x = test_input{i};
                            end
                            % Create sequences for test set
                            x_nn = reshape(x, [size(x,1) 1 1 size(x,2)]);
                            y_nn = test_target{i};
                            % Predict with trained classifier
                            y = classify(this.classifier,x_nn, ...
                                'MiniBatchSize',this.parameter.miniBatchSize, ...
                                'SequenceLength','longest');
                            y = double(y)'-1;
                            % Post Processing
                            if post_proc
                                y_pred{:,i} = postProcessingCAP(y, x);
                            else
                                y_pred{:,i} = y;
                            end
                            labels{:,i} = y_nn;
                        end 
                        if metric_calc
                            output = getMetrics(y_pred, labels);
                        else
                            output = [y_pred, labels];
                        end 
                    case 'LSTM'
                        for i = 1 : numel(test_input)
                            if norm_flag
                                % Normalize test data based on mean and std from training dataset
                                x = ClassificationEEG.normalizeTestData(test_input{i}, this.mu_train, this.sigma_train);
                            else
                                x = test_input{i};
                            end
                            % Create sequences for test set
                            [x_lstm, y_lstm] = ClassificationEEG.createSequencesLSTM(x, test_target{i}, this.parameter.seqLen);
                            % Predict with trained classifier
                            y = classify(this.classifier,x_lstm, ...
                                'MiniBatchSize',this.parameter.miniBatchSize, ...
                                'SequenceLength','longest');
                            y = double(y)'-1;
                            % Post Processing
                            if post_proc
                                y_pred{:,i} = postProcessingCAP(y, x(:,this.parameter.seqLen:end));
                            else
                                y_pred{:,i} = y;
                            end
                            labels{:,i} = y_lstm;
                        end 
                        if metric_calc
                            output = getMetrics(y_pred, labels);
                        else
                            output = [y_pred, labels];
                        end 
                end
            else
               disp('Define classifier and its parameter!'); 
            end
        end
    end    
    methods(Static)
        
        function [input, target] = loadBalancedData(path, list, method)
        % Load processed balanced dataset of subjects on list from passed path
        % If method is 'LOO', output variables are passed as cell arrays,
        % otherwise they are concatenated double arrays
            for i = 1:numel(list)
                % Load saved inpute and target data
                tmp_input = load(strcat(path,'input_',list{i},'.mat'));
                tmp_target = load(strcat(path,'target_',list{i},'.mat'));
                % Store loaded data in input and target vector containing all subjects
                input{i} =  tmp_input.input_bal';
                target{i} =  tmp_target.target_bal;
            end
            if strcmp(method, 'Normal')
                % Concatenate double arrays in cell array
                input = cell2mat(input);
                target = cell2mat(target);                       
            end
        end
        
        function [input, target] = loadImbalancedData(path, list, method)
        % Load processed imbalanced dataset of subjects on list from passed path
        % If method is 'LOO', output variables are passed as cell arrays,
        % otherwise they are concatenated double arrays       
            for i = 1:numel(list)
                % Load saved inpute and target data
                tmp_input = load(strcat(path,'inputALL_',list{i},'.mat'));
                tmp_target = load(strcat(path,'targetALL_',list{i},'.mat'));
                % Store loaded data in input and target vector containing all subjects
                input{i} =  tmp_input.input';
                target{i} =  tmp_target.target;
            end
            if strcmp(method, 'Normal')
                % Concatenate double arrays in cell array
                input = cell2mat(input);
                target = cell2mat(target);                       
            end
        end     
        
        function [train_input, train_target, test_input, test_target] = createLOODataset(input, target, list, test_name)
        % Concatenate double arrays in cell array    
            ind = find(strcmp(list, test_name));
            % Create training dataset
            train_input = input;
            train_input(ind) = [];
            train_target = target;
            train_target(ind) = [];

            % Create test dataset
            test_input = input{ind};
            test_target = target{ind};
   
        end
        
        function [train_input, mu, sigma] = normalizeTrainingData(train_input)
        % Determine mean and std of input array and pass normalized data as
        % well as mu and sigma
            mu = mean(train_input, 2);
            sigma = std(train_input, 0, 2);
            train_input = (train_input-mu)./sigma;
        end
        
        function [input, target] = shuffleData(input, target)
        % Shuffle input and target data
            ind = randperm(size(input,2));
            input = input(:,ind);
            target = target(:,ind);
        end
        
        function [test_input] = normalizeTestData(test_input, mu, sigma)
        % Normalize data with passed mu and sigma
            test_input = (test_input-mu)./sigma;
        end
        
        function [ x_seq, y_seq ] = createSequencesLSTM( x, y, seq_len )
        % Based on time series, create sequences of specific length as
        % input for the LSTM classifier
        %   
        %   Sequence (last index is always current timestep):
        %
        %   x(t-seq_len+1) | x(t-seq_len+2) | ... | x(t-1) | x(t)
        %
        %   Label (label of current timestep):
        %
        %                                                    l(t)
        %
            for i = 1 : length(x)-seq_len+1
                tmp = x(:,i:i+seq_len-1);
                x_seq{i} = tmp;
                y_seq(i) = y(i+seq_len-1);    
            end
        end
        
        function [ x_seq, y_seq ] = createSequencesBiLSTM( x, y, seq_len )
        % Based on time series, create sequences of specific length as
        % input for the BiLSTM classifier
        %   
        %   Sequence (middle index is always current timestep, final length is 2*seq_len-1):
        %
        %   x(t-seq_len+1) | x(t-seq_len+2) | ... | x(t-1) | x(t) | x(t+1) | ... | x(t+seq_len-2) | x(t+seq_len-1)
        %
        %   Label (label of current timestep):
        %
        %                                                    l(t)
        %    
            for i = 1 : length(x)-2*(seq_len-1)
                tmp = x(:,i:i+2*(seq_len-1));
                x_seq{i} = tmp;
                y_seq(i) = y(i+seq_len-1);    
            end
        end

        function [x, y] = createBalancedLSTMData(features, target)
        % Balance out the number of events and non-events in feature and
        % target vector
        % Select random number of timesteps for longer vector (event or
        % non-event)

            tmp_Event = features(target > 0,:);
            tmp_NonEvent = features(target == 0,:);
                       
            if length(tmp_Event) > length(tmp_NonEvent)
                indx = randperm(size(tmp_Event,1),size(tmp_NonEvent,1));
                x = [tmp_Event(indx); tmp_NonEvent];
                y = zeros(length(x),1);
                y(1:size(tmp_NonEvent,1)) = 1;
            else
                indx = randperm(size(tmp_NonEvent,1),size(tmp_Event,1));
                x = [tmp_Event; tmp_NonEvent(indx,:)];
                y = zeros(length(x),1); 
                y(1:size(tmp_Event,1)) = 1;
            end
        end
        function [x, y] = createBalancedLSTMData2(features, target)
        % Balance out the number of events and non-events in feature and
        % target vector
        % Select random number of timesteps for longer vector (event or
        % non-event)
            x = [];
            y = [];
            class_0 = features(target == 0);
            class_1 = features(target == 1);
            class_2 = features(target == 2);
            class_3 = features(target == 3);
            
            class_0_len = numel(class_0);
            class_1_len = numel(class_1);
            class_2_len = numel(class_2);
            class_3_len = numel(class_3);
            
            [min_len, ~] = min([class_0_len class_1_len class_2_len class_3_len]);
            
            indx = randperm(size(class_0,1),min_len);
            x = [x; class_0(indx)];
            y = [y; 0*ones(min_len,1)];
            
            indx = randperm(size(class_1,1),min_len);
            x = [x; class_1(indx)];
            y = [y; ones(min_len,1)];
            
            indx = randperm(size(class_2,1),min_len);
            x = [x; class_2(indx)];
            y = [y; 2*ones(min_len,1)];
            
            indx = randperm(size(class_3,1),min_len);
            x = [x; class_3(indx)];
            y = [y; 3*ones(min_len,1)];
                       
        end
        
        function [x, y] = createBalancedLSTMData3(features, target)
        % Balance out the number of events and non-events in feature and
        % target vector
        % Select random number of timesteps for longer vector (event or
        % non-event)
            x = [];
            y = [];
            class_1 = features(target == 1, :);
            class_2 = features(target == 2, :);
            class_3 = features(target == 3, :);
            
            class_1_len = size(class_1,1);
            class_2_len = size(class_2,1);
            class_3_len = size(class_3,1);
            
            [min_len, ~] = min([class_1_len class_2_len class_3_len]);
                       
            indx = randperm(size(class_1,1),min_len);
            x = [x; class_1(indx,:)];
            y = [y; ones(min_len,1)];
            
            indx = randperm(size(class_2,1),min_len);
            x = [x; class_2(indx,:)];
            y = [y; 2*ones(min_len,1)];
            
            indx = randperm(size(class_3,1),min_len);
            x = [x; class_3(indx,:)];
            y = [y; 3*ones(min_len,1)];
                       
        end
    end
end
