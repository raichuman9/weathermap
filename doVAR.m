function [ PiByLag, avgPctErrByLag, XpredByLag ] = doVAR( Xtrain, Xtest, lags, useConstOffset, useLasso)

%DEBUGGING ONLY: Test set == training set
% Xtest = Xtrain;

%DEBUGGING ONLY: Actually, use full data set for training & reuse same for testing
% Xtest = X; Xtrain = X;

for p = lags 
    %Train the model
    PiByLag{p} = trainVAR(Xtrain, p, useConstOffset, useLasso);
    [avgPctErrByLag{p}, XpredByLag{p} ] = testVAR(PiByLag{p}, Xtest, useConstOffset);
    
    disp(['Avg test error pct for lag p = ', num2str(p), ': ']);
    disp(avgPctErrByLag{p});
end

end

