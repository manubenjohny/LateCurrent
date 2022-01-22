
function [Efit,S,E,A,De,obj] = FitExpD(X,tau,time,idx_start,idx_exact,lam,num_iter, De)
%[Efit,S,E,A,De,obj] = FitExpD(X,tau,time,idx_start,idx_exact,lam,num_iter)
%
%This function fits exponential signals to data with the possibility that
%there are sparse outliers in the data.  Specifically the function solves
%the problem:
%
% minimize f(A,E,S) with respect to A, E, and S
% subject to A(not(idx_exact))=0, S<=0, E>=0, and S(time<time(idx_start))=0
%
% where f(A,E,S) = 0.5*|X-De*E-S-A|_F^2 + lam*|S|_1
%
%Here X is the data matrix, and De is a dictionary of decaying exponential
%signals that is generated using the time constants supplied in the tau
%parameter.  The other variables are output variables.
%
%Inputs:
%   X - The data matrix (should be t x N) where t is the number of time
%       points and N is the number of traces being fit (each trace is in a 
%       column of X).  Note that because the exponential fit is done
%       assuming non-negative data the baseline of the signals should be
%       non-negative.
%
%   tau - A vector of decay constants to use to construct the exponential
%         fit.  Should be in the same units as the 'time' input vector.
%
%   time - A (t x 1) vector containing the time points when the data was
%          sampled.
%
%   idx_start - The index of the time vector when the exponential signal
%               starts (assumed known).  For example, suppose 
%               time = [0 0.1 0.2 0.3 0.4 ...] and the signal starts at 
%               t=0.2, then idx_start = 3.
%
%   idx_exact - The indecies of the time vector when the algorithm should
%               apply an exact fit.  The is typically to remove artifacts
%               associated with the onset of the exponential and prevent 
%               them from being incorporated into the overall fit.  For
%               example idx_exact = idx_start + (-w:w); would be a typical
%               value to apply an exact fit for w time points in either
%               direction of the signal onset.  If no exact fit is to be
%               used then pass in [] for this parameter.
%
%   lam - Regularization parameter for the optimization problem.  This sets
%         the sensitivity of the algorithm to outliers.  Typically set
%         this to be roughly proportional to the std of the noise.
%
%   num_iter - The number of iterations to perform in the optimization.
%              Future versions will have more principled stopping criteria.
%
%Outputs:
%   Efit - (t x N) Matrix. The exponential fits for each signal.  Each 
%          column contains the exponential fit for the corresponding column
%          of the data matrix.  Efit = De*E+A
%
%   S - (t x N) Matrix.  Estimation of negative outliers (in single channel
%       recordings this would be roughly the channel opening events).
%
%   E - (size(De,2) x N) Matrix. Coefficients used to fit the expnential 
%       signal (De*E is the purely exponential fit).
%
%   A - (t x N) Matrix.  The 'exact fit' coefficients during the idx_exact
%       period.
%
%   De - The Dictionary used in the fit.
%
%   obj - (num_iter x 1) vector.  The value of the objective function at
%         each iteration.
%
%
%Ben Haeffele - Aug 4, 2014



%Make the dictionary
%De = MakeExpDict(tau,time,idx_start);

numE = size(De,2);
[nT,nS] = size(X);

%Allocate space for variables
S_old = zeros(nT,nS);
E_old = zeros(numE,nS);

S_extrap = S_old;
E_extrap = E_old;

obj = zeros(num_iter,1);

t_old = 1;

%Pre-calculate this to slightly speed up the iterations.
DtX = De'*X;

%Lipschitz constant of the square loss term.
L = norm(De,2)^2+1;

%Calculate indices for when S must be = 0
idx_nosig = true(nT,1);
idx_nosig(idx_exact) = false;
idx_nosig(idx_start:end) = false;

%Indices for when S can be non-zero
idx_L1 = true(nT,1);
idx_L1(idx_exact) = false;
idx_L1(1:idx_start-1) = false;

%The main calculation loop
for i=1:num_iter
    %Comment this out if it gets annoying having the iteration number
    %displayed.
    %disp(i)
    
    %Calculate the gradients of the smooth loss term
    DeE = De*E_extrap;
    
    gradE = De'*(DeE+S_extrap)-DtX;
    gradS = S_extrap+DeE-X;
    
    %Apply proximal operators
    E = E_extrap-gradE/L;
    E(E<0) = 0;
    
    S = S_extrap-gradS/L;
    
    S(idx_L1,:) = min(S(idx_L1,:)+lam/L,0);
    
%     indicator = S(idx_L1);
%     indicator = (indicator <= 0); %only the negatives
%     S(idx_L1,:) = indicator.*min(S(idx_L1,:)+lam/L,0) + ~(indicator).*max(S(idx_L1,:)-lam/L,0);
    
%     figure(4);
%     cla;
%     plot(S(idx_L1,:));
    
    S(idx_nosig,:) = 0;
    
    %Calculate the residual
    res = X-De*E-S;
    S(idx_exact,:) = S(idx_exact,:)+res(idx_exact,:);
    res(idx_exact,:) = 0;
    
    %Calculate objective function value for this iteration
    obj(i) = 0.5*norm(X-De*E-S,'fro')^2+lam*sum(abs(S(:)));
    
    %Apply simple extrapolation for the next search point
    t = (1+sqrt(1+4*t_old^2))/2;
    
    E_extrap = E+(t_old-1)/t*(E-E_old);
    S_extrap = S+(t_old-1)/t*(S-S_old);
    
    E_old = E;
    S_old = S;
    t_old = t;

end

%We actually solve the optimization with just S and E and then split out A
%at the end.  Essentially A is just S for the indices in idx_exact and 0
%everywhere else.  During the main optimization S is unregularized at the
%idx_exact indices so it will fit the data exactly.
A = zeros(size(S));
A(idx_exact,:) = S(idx_exact,:);
S = S-A;

Efit = De*E+A;




function [D] = MakeExpDict(tau,time,idx_start)
%[D] = MakeExpDict(tau,time,idx_start)
%
%Creates a dictionary of decaying exponetial signals with a given decay
%constant and start time.
%
%Inputs:
%   tau - A vector of decay constants (n x 1).
%   time - A vector containing the time points to generate (t x 1).
%   idx_start - The index of the time vector where the expenential starts.
%
%Output:
%   D - (t x (n+2)) Matrix containing the decaying exponential signals plus
%   two step functions.  The two step functions are added to the last two
%   columns to help fit any DC offset before/after the start time.
%   Specifically, the i'th (i <= length(tau)) column of D is given by:
%   d(t) = exp(-(t-time(idx_start))/tau(i)).*(t>=time(idx_start));
%
%
% Ben Haeffele - Aug 4, 2014

global SCSTEPLATE;

%Make sure the decay constant vector is a column vector
tau = tau(:);

nT = numel(tau);

%Shift the time points to start at t(idx_start) = 0
t = time-time(idx_start);
t = t(:);

%Make the step function at the start time.
t_step = t>=0;

szTS = sum(t_step);

%Make the decaying exponentials
D(t_step,:) = exp(repmat(-t(t_step),1,nT)./repmat(tau',szTS,1));

%Add step functions to fit any DC offset before/after the voltage clamp
%onset.
D = [D double(t_step(:)) double(not(t_step))];