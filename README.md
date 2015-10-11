This code implement a neural network to simulate the neural response under binocular rivalry.
The network includs the following layers of neurons: monocular, summation, opponency and attention neurons.
-runModel.m: this is the main mfile for running the simulation
You can set the contrast os the two images (one for each eye) here by setting the variables 'contrasts' and 'rcontrast'.
You can set the stimulus and attention state here by setting 'rstim':
1 for binocular rivalry with attention. 
2 for binocular rivalry without attention. 
3 for monocular plaid with attention.
4 for monocular plaid without attention.
You can decide whether to save the simulated data in the Data folder by setting saveData as 1 or 0.
-n_model.m: this is the code running the simulation using Euler method.
-mfile starts with 'plot' reads the data saved in data folder and plot the results.

