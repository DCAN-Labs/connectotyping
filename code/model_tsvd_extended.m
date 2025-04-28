function [SV, R] = model_tsvd_extended(signal, options)
% model_tsvd_extended: Computes predictive performance using truncated SVD
% with optional MEX acceleration and batch-friendly logging.
%
% INPUTS:
%   signal:    [frames x rois] time-series matrix
%   options:   struct with fields:
%       perc:           fraction of frames to use for training (e.g., 0.7)
%       rep_svd:        number of repetitions
%       use_mex         (optional) true to use MEX acceleration
%       log_progress    (optional) true to log progress
%
% OUTPUTS:
%   SV: [rois x 1] best number of SVs per ROI
%   R:  [rep x rois x max_SV] correlation results

% Validate inputs
if ~isfield(options, 'perc') || ~isfield(options, 'rep_svd')
    error('Options must contain "perc" and "rep_svd".');
end

[nFrames, nROIs] = size(signal);
rep = double(options.rep_svd);
perc = double(options.perc);
use_mex = isfield(options, 'use_mex') && options.use_mex;
log_progress = isfield(options, 'log_progress') && options.log_progress;

% Setup logging
if log_progress
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    progress_log = fullfile(pwd, sprintf('progress_%s.txt', timestamp));

    fid = fopen(progress_log, 'wt');
    if fid > 0
        fprintf(fid, 'Progress Log Started: %s\n', datestr(now));
        fclose(fid);
    end
    fprintf('Logging progress to: %s\n', progress_log);
else
    progress_log = '';
end

train_frames = round(nFrames * perc);
max_SV = min(train_frames, nROIs - 1);
max_SV = max(max_SV);  % Make sure max_SV is at least 1

% Preallocate
R = zeros(rep, nROIs, max_SV);
elapsed_times = zeros(rep, 1);  % Preallocate timing storage

% Main loop
parfor i = 1:rep
    iter_start_time=tic;
    rng(i);  % reproducible randomness
    idx = randperm(nFrames);
    idx_train = idx(1:train_frames);
    idx_test = idx(train_frames+1:end);

    TC_train = signal(idx_train, :);
    TC_test = signal(idx_test, :);

    local_R = zeros(nROIs, max_SV);

    for roi = 1:nROIs
        y_train = TC_train(:, roi);
        y_test = TC_test(:, roi);

        predictors_train = TC_train(:, [1:roi-1, roi+1:end]);
        predictors_test = TC_test(:, [1:roi-1, roi+1:end]);

        [U, S, V] = svd(predictors_train, 'econ');

        if use_mex && exist('compute_svd_corr', 'file') == 3
            try
                Rvals = compute_svd_corr(U, S, V, y_train, predictors_test, y_test);
                local_R(roi, :) = Rvals(:)';
            catch
                local_R(roi, :) = fallback_svd(U, S, V, y_train, predictors_test, y_test, max_SV);
            end
        else
            local_R(roi, :) = fallback_svd(U, S, V, y_train, predictors_test, y_test, max_SV);
        end
    end

    R(i, :, :) = local_R;
    elapsed_time = toc(iter_start_time);  % End timer
    elapsed_times(i) = elapsed_time;  % Store each iteration's time

    % Progress logging (safe inside parfor)
    if ~isempty(progress_log)
        try
            fid = fopen(progress_log, 'a');
            if fid > 0
                fprintf(fid, 'Completed repetition %d / %d at %s\n', i, rep, datestr(now, 'HH:MM:SS'));
                fclose(fid);
            end
        catch
            % do nothing
        end
    end
    if isempty(progress_log)
        fprintf('Completed SVD repetition %d / %d\n', i, rep);
    end
end

if log_progress
    fid = fopen(progress_log, 'a');  % Open for appending
    if fid > 0
        fprintf(fid, '\nSVD Repetition Timing Results:\n');
        for i = 1:rep
            fprintf(fid, 'Repetition %d: %.3f seconds\n', i, elapsed_times(i));
        end
        total_time = sum(elapsed_times);
        fprintf(fid, 'Total elapsed time for all repetitions: %.3f seconds (%.2f minutes)\n', total_time, total_time/60);
        fclose(fid);
    end
end

% Find best number of SVs
mr = squeeze(mean(R, 1));   % [rois x max_SV]
[~, SV] = max(mr, [], 2);    % [rois x 1]

end


function Rvals = fallback_svd(U, S, V, y_train, X_test, y_test, max_SV)
% fallback_svd - Standard MATLAB version if MEX not available
[p, ~] = size(V);
[n, ~] = size(U);
x_inv = zeros(p, n);
Rvals = zeros(max_SV, 1);

for k = 1:max_SV
    x_inv = x_inv + V(:, k) * (1 / S(k, k)) * U(:, k)';
    coeffs = x_inv * y_train;
    y_pred = X_test * coeffs;
    Rvals(k) = corr(y_pred, y_test, 'Rows', 'complete');
end
end
