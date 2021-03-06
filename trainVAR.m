function [ Pi ] = trainVAR( X, p, useConstOffset, useLasso)
%TRAINVAR Trains a VAR model for given meteorological data
%   X is an T x N vector, where N is the number of distinct variables per
%       timestep, T is the number of timesteps used for training.
%   p defines the lag order of the VAR model that will be trained
%   Note that the model will only be trained on elements (p+1...T); the
%   first (1 ... p) timesteps are used only as observational history for
%   the p+1'st element (the first used for a VAR equation).
%   useConstOffset: If 1, a linear offset is included in the model
%   OUTPUT: Pi is a (k x N) matrix specifying the trained VAR model:
%       X(t,:) = Pi(1,:) + sum_over_i=1:p(Pi((2+(i-1)*N):(2+(i+N)),:) * X(t-i,:)) + eps_t
%       k=N*p (+1 if useConstOffset is true)

% Reformulate as a SUR problem and do OLS for each variable
% See http://faculty.washington.edu/ezivot/econ584/notes/varModels.pdf

[T, N] = size(X);

%The t'th row of Z is comprised of the lagged observations for timestep t
%Version w/ const offset
if (useConstOffset)
    k = N*p + 1;
    reshapeColRange = 2:k;
else
    k = N*p;
    reshapeColRange = 1:k;
end

Z = zeros(T-p, k);  
if (useConstOffset)
    Z(:,1) = 1; %constant offset term
end

for t=1:T-p
    %NOTE the transpose after flipud... very important so that 
    %we transform the data to a row vector by flattening all *rows* to a
    %single vector rather than all *columns* (incorrect regression results otherwise)
   Z(t,reshapeColRange) = reshape(flipud(X(t:t+p-1,:))', 1, N*p);
end

%Now, we do OLS for each observation across all timesteps separately
Pi = zeros(k,N);
for i=1:N
    disp(['Running regression for i=', num2str(i)]);
    x_i = X(1+p:end,i); %time series of observations for variable i

    %System to be solved: x_i = Z*pi_i
    if (useLasso)
        Pi(:,i) = lasso(Z, X(1+p:end,i), 'Lambda', 0.045);  %Lasso version (slower, but prevents overfitting)
%         lambdas = 10.^[-1:1];
%         [B, FitInfo] = lasso(Z, X(1+p:end,i), 'Lambda', lambdas, 'CV',2);
%         Pi(:,i) = B(:,FitInfo.IndexMinMSE);
    else
        Pi(:,i) = double(Z) \ x_i; %OLS
    end
    
end
    
end

