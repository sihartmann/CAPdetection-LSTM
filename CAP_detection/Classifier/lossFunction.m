classdef lossFunction < nnet.layer.ClassificationLayer
        
    properties
        % (Optional) Layer properties
        beta = 3;
        % Layer properties go here
    end
 
    methods
        function layer = lossFunction(beta, name)           
            % Create own loss function
            % Set layer name
            layer.Name = name;
            % Set layer description
            layer.Description = 'Own loss function using Fscore';
            layer.beta = beta;
        end

        function loss = forwardLoss(layer, Y, T)
            % Return the loss between the predictions Y and the 
            % training targets T
            %
            % Inputs:
            %         layer - Output layer
            %         Y     – Predictions made by network
            %         T     – Training targets
            %
            % Output:
            %         loss  - Loss between Y and T
            tp = sum(sum(Y(2:end,:).*T(2:end,:),2));
            fp = sum(sum(Y(2:end,:).*(1-T(2:end,:)),2));
            fn = sum(sum((1-Y(2:end,:)).*T(2:end,:),2));
            pr = sum(tp)/sum(tp+fp);
            rc = sum(tp)/sum(tp+fn);
            loss = -(1+layer.beta^2)*(pr*rc)/(layer.beta^2*pr+rc);
        end
        
        function dLdY = backwardLoss(layer, Y, T)
            % Backward propagate the derivative of the loss function
            %
            % Inputs:
            %         layer - Output layer
            %         Y     – Predictions made by network
            %         T     – Training targets
            %
            % Output:
            %         dLdY  - Derivative of the loss with respect to the predictions Y
            
            %dLdY = (-2)*(T.*sum(T+Y,2)-sum(Y.*T,2).*ones(2,length(T(2,:))))./(sum(T+Y,2).^2);
            dLdY = (-1)*(((1+layer.beta^2)*T)./sum(layer.beta^2*T+Y,2) - ((1+layer.beta^2)*sum(Y.*T,2))./(sum(layer.beta^2*T+Y,2).^2));
        end
    end
end