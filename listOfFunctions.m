% listOfFunctions

%% wrappers
*runrun          % quickly run model with certain parameters, calculate cost, plot model and data
runModelParallel % runs model on different conditions with parfor, calls runModelTA

%% model
runModelTA      % main function to run the model. loops through multiple attention conds, contrasts, soas, seqs, etc
setParametersFA % sets parameters, contains all default parameters
n_model_FA      % the core model function, computes all time series
initTimeSeriesFA % initializes all timeseries with zeros
setStimTA       % makes the stimulus time series
setTaskTA       % makes the task input to voluntary attention
distributeAttention % controls distribution of attention in neutral condition and span models
setDecisionWindowsTA % sets decision windows
accumulateTA    % accumulate evidence
decodeEvidence  % decode the CW/CCW decision

%% visualization
plotPerformanceTA % plots model performance, called by runModelTA
plotFA2         % plots model timeseries, called by runModelTA
*plotTaskTA      % plots task input, can show distribution of voluntary attention
*plotFit         % makes nice plot of fit from fit file, data + model for d-prime each condition and valid-invalid 

%% optimization
optimModel      % main optimization function: fits the model
modelCost       % runs the model with given parameters and computes the cost
x2opt           % converts an x vector to an opt structure, also sets initial x values, controls which parameters are being fit

%% statistics
*resampleData    % calculates d-prime based on a bootstrapped sample of subject data
*analyzeBootstrap % gets CIs for parameter estimates from bootstrap fits

%% helper
makeBiphasic
makeGamma
halfExp         % called by n_model_FA
distance2curve  % called by decodeEvidence
ideal_response_vector

%% cluster
job_optimModel.sh % main script for fitting on the cluster
job_optimModel_resample.sh % for bootstrapped parameter estimates, calls resampleData

