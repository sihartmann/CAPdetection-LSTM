classdef lossFunctionWeightedMulti < nnet.layer.ClassificationLayer
        
    properties
        % (Optional) Layer properties
        w1 = 2;
        w2 = 1;
        w3 = 1;
        w4 = 1;
        % Layer properties go here
    end
 
    methods
        function layer = lossFunctionWeightedMulti(w1,w2,w3,w4,name)           
            % Create own loss function
            % Set layer name
            if nargin == 0.5
                layer.Name = name;
            end
            % Set layer description
            layer.Description = 'Own loss function using weighted cross entropy';
            layer.w1 = w1;
            layer.w2 = w2;
            layer.w3 = w3;
            layer.w4 = w4;
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
            loss = -1/length(Y)*(layer.w1*sum(T(1,:).*log(Y(1,:))) + layer.w2*sum((T(2,:)).*log(Y(2,:))) + layer.w3*sum((T(3,:)).*log(Y(3,:))) + layer.w4*sum((T(4,:)).*log(Y(4,:))));
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
            %dLdY = (-1)*(((1+layer.beta^2)*T)./sum(layer.beta^2*T+Y,2) - ((1+layer.beta^2)*sum(Y.*T,2))./(sum(layer.beta^2*T+Y,2).^2));
            dLdY(1,:) = -(layer.w1*(T(1,:)./Y(1,:)));
            dLdY(2,:) = -(layer.w2*(T(2,:)./Y(2,:)));
            dLdY(3,:) = -(layer.w3*(T(3,:)./Y(3,:)));
            dLdY(4,:) = -(layer.w4*(T(4,:)./Y(4,:)));
        end
    end
end