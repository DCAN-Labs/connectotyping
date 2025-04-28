function [TC_no_AC_LS, R,optimal_lag,R_mean_out]=remove_autocorrelation(signal,options_remove_autocorrelation)
% function [TC_no_AC_LS TC_no_AC_rec R]=remove_autocorrelation(signal,lag,rep_rec);
% The oupput of this function are the residuals after removing the
% autocorrelation based on:
% Least square solution TC_no_AC_LS
%
% Oscar Miranda-Dominguez
% lags, how many historical values to consider in the data

if nargin<2% To preserve backwards compatibility with no second argument mins use 3 lags
    lag=3;
    [TC_no_AC_LS, R]=solve_generic_autocorrelation(signal,lag);
else
    is_struc_2arg=isstruct(options_remove_autocorrelation);
    is_empty_2arg=isempty(options_remove_autocorrelation);
    
    if is_struc_2arg==0
        if is_empty_2arg==0
            lag=options_remove_autocorrelation;
            [TC_no_AC_LS, R]=solve_generic_autocorrelation(signal,lag);
        else
            lag=3;
            [TC_no_AC_LS, R]=solve_generic_autocorrelation(signal,lag);
        end
        
    else
        options_remove_autocorrelation=read_options_remove_autocorrelation(options_remove_autocorrelation);
        [TC_no_AC_LS, R,optimal_lag,R_mean_out]=solve_robust_autocorrelation(signal,options_remove_autocorrelation);
    end
    
    
    1;
    
    
end

function [TC_no_AC_LS, R,optimal_lag,R_mean_out]=solve_robust_autocorrelation(signal,options_remove_autocorrelation)

[samples, N]=size(signal);
R=zeros(N,1);

y_pred=nan(samples, N);
n_frames_modeling=floor(samples*options_remove_autocorrelation.perc_train_pred(1));
n_frames_pred=floor(samples*options_remove_autocorrelation.perc_train_pred(2));

max_pot_init_model=samples-n_frames_modeling+1;
template_pred=ones(samples,1);

max_pot_lag=n_frames_pred-3;% to make sure the vector when all the lags are used has a length of at least 3
R_mean_out=zeros(N,max_pot_lag);
% R_in=zeros(max_pot_lag,options_remove_autocorrelation.n,N);
% R_out=zeros(max_pot_lag,options_remove_autocorrelation.n,N);
optimal_lag=zeros(N,1);
for roi=1:N % working on each ROI
    
    R_in=zeros(max_pot_lag,options_remove_autocorrelation.n);
    R_out=zeros(max_pot_lag,options_remove_autocorrelation.n);
    
    
    for lag=1:max_pot_lag
        % Selecting sections for modeling and prediction
        for i=1:options_remove_autocorrelation.n
            
            init=randi(max_pot_init_model);
            ix_in=(1:n_frames_modeling)+init-1;
            
            pot_init_pred=template_pred;
            pot_init_pred(ix_in)=0;
            
            ix_out=1;
            foo=find(pot_init_pred);
            while sum(pot_init_pred(ix_out))<n_frames_pred
                %    init_pred=randi(samples-n_frames_pred+1);
                foo_ix=randi(length(foo));%select a random index on foo
                
                init_pred=foo(foo_ix);
                ix_out=(1:n_frames_pred)+init_pred-1;
                ix_out(ix_out>samples)=[];
            end
            
            local_signal=signal(ix_in,roi);
            y_in=local_signal(lag+1:end);
            x_in=zeros(n_frames_modeling-lag,lag);
            for j=1:lag
                x_in(:,j)=local_signal(lag-j+1:end-j);
            end
            pinv_x=pinv(x_in);
            coefs=pinv_x*y_in;
            
            local_signal=signal(ix_out,roi);
            y_out=local_signal(lag+1:end);
            x_out=zeros(n_frames_pred-lag,lag);
            for j=1:lag
                x_out(:,j)=local_signal(lag-j+1:end-j);
            end
            
            y_out_pred=x_out*coefs;
            R_out(lag,i)=corr(y_out,y_out_pred);
            
            y_in_pred=x_in*coefs;
            R_in(lag,i)=corr(y_in,y_in_pred);   
        end   
    end
    
    Z_in=atanh(R_in);
    Z_out=atanh(R_out);
    roi
    [b optimal_lag_local]=max(mean(R_out,2));
    
    %Is  better than prev?
    if optimal_lag_local>1
        [h,p,ks2stat] = kstest2(Z_out(optimal_lag_local,:),Z_out(optimal_lag_local-1,:));
        if p>.05
            optimal_lag_local=optimal_lag_local-1;
        end
    end
    
    optimal_lag(roi)=optimal_lag_local;
%     subplot 211
%     boxplot(R_in')
%     title(roi)
%     subplot 212
%     boxplot(R_out')
%     
%     Z_out=atanh(R_out);
    lag=optimal_lag(roi);
    
    R_mean_out(roi,:)=mean(R_out,2);
    
    y=(signal(lag+1:end,roi));
    x=zeros(samples-lag,lag);
    for j=1:lag
        x(:,j)=signal(lag-j+1:end-j,roi);
    end
    pinv_x=pinv(x);
    coefs=pinv_x*y;
    y_pred(lag+1:end,roi)=x*coefs;
    R(roi,1)=corr(y,y_pred(lag+1:end,roi));


    1;
end
TC_no_AC_LS=signal-y_pred;

function [TC_no_AC_LS, R]=solve_generic_autocorrelation(signal,lag)
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

function options=read_options_remove_autocorrelation(options)

% Pecentile, 0 to 100 to be included in training
if ~isfield(options,'perc_train_pred') || isempty(options.perc_train_pred);
    options.perc_train_pred=[.7 .1];
else
    error_text_lag_perc='options_remove_autocorrelation.perc_train_pred must be a vector of 2 components that indicates partitions for modeling and prediction';
    [nr, nc]=size(options.perc_train_pred);
    if and(nr>1,nc>1)
        error_text_lag_perc=[error_text_lag_perc ', you provided a matrix as input instead of a 2-elements vector'];
        error(error_text_lag_perc)
    end
    if nr*nc>2
        error_text_lag_perc=[error_text_lag_perc ', you provided a vector with more than 2-elements'];
        error(error_text_lag_perc)
    end
    if (1-options.perc_train_pred(1))/2>options.perc_train_pred(1)
        error_text_lag_perc=[error_text_lag_perc ', you provided a percentage greater than 100 percent'];
        error(error_text_lag_perc)
    end
%     if sum(options.perc_train_pred)>=1
%         error_text_lag_perc=[error_text_lag_perc ', you provided a percentage greater than 100 percent'];
%         error(error_text_lag_perc)
%     end
    
end;
options.perc_train_pred=options.perc_train_pred;


if ~isfield(options,'n') || isempty(options.n)
    options.n=100;
else
    [nr, nc]=size(options.n);
    
    if nr*nc>1
        error('n should b an scalar')
    end
    
    options.n=round(abs(options.n));
    if options.n<1
        error('n should be an integer larger than 1');
    end
end
options.n=options.n;
