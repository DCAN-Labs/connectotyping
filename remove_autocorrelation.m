function [TC_no_AC_LS R]=remove_autocorrelation(signal,lag)
% function [TC_no_AC_LS TC_no_AC_rec R]=remove_autocorrelation(signal,lag,rep_rec);
% The oupput of this function are the residuals after removing the
% autocorrelation based on:
% Least square solution TC_no_AC_LS
% 
% Oscar Miranda-Dominguez
% lags, how many historical values to consider in the data

if nargin<2
    lags=3;
end

%% Read data and prealocate global variables
signal=double(signal);
[samples N]=size(signal);
y_pred=zeros(samples-lag,N);
 
R=zeros(N,1);

%% Solve by LS
for roi=1:N
    y=(signal(lag+1:end,roi));
    x=zeros(samples-lag,lag);
    for j=1:lag
        x(:,j)=signal(lag-j+1:end-j,roi);
    end
    pinv_x=pinv(x);
    coefs=pinv_x*y;
    y_pred(:,roi)=x*coefs;
    R(roi,1)=corr(y,y_pred(:,roi));
end
TC_no_AC_LS=signal(lag+1:end,:)-y_pred;

