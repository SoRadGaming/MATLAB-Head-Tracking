function y = exppuls(t,T)
%EXPPULS Sampled decaying exponential pulse generator.
%   EXPPULS(t) generates samples of a continuous, aperiodic,
%   unity-height decaying exponential pulse at the points specified in array t, 
%   starting at t=0.  By default, the decaying exponential has time constant 1.
%   EXPPULS(t,T) generates a decaying exponential pulse of time constant T.
%   Author: PMcL
%   Date: 2015-02-24
%   Revision: 1.0

error(nargchk(1,2,nargin));
if nargin<2, T=1;   end

% Compute decaying exponential function output:
y=zeros(size(t));
i=find(t>=0);
y(i)=exp(-t(i)/T);

% end of exppuls.m
