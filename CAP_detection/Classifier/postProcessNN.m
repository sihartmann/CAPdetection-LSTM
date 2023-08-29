% createNN_PostProcess() -  Initialize self-organizing map for 
%                           post-processing like it is described in 
%                           publication of Mariani (2012)
% Usage:
%  >> [ net ] = createNN_PostProcess( )
%
% Inputs:
%
% Outputs:
%   net       = configured neural network for clustering
%
% See also: selforgmap()

function [ net ] = postProcessNN( )
% Create a Neural Network for post-processing

% Create a Self-Organizing Map
dimension1 = 2;
dimension2 = 1;
net = selforgmap([dimension1 dimension2]);

% Choose Plot Functions
% For a list of all plot functions type: help nnplot
% net.plotFcns = {'plotsomtop','plotsomnc','plotsomnd', ...
%     'plotsomplanes', 'plotsomhits', 'plotsompos'};
net.trainParam.epochs = 500;

% % Disable graphic output for training stage
net.trainParam.showWindow = false;
end

