function [model, R_model] = make_model_tsvd_extended(signal, options)
% make_model_tsvd_extended - Truncated SVD-based model estimation for large inputs
% Optimized with parfor, batched SVD, and vectorized matrix operations,
% Enhanced with MEX % Broken...
%
% Authors: Oscar Miranda-Dominguez, Kody DeGolier
% INPUTS:
%   signal:    [frames x rois] time-series matrix
%   options:   struct with fields:
%       min_frames  - number of frames per subsample
%       rep_model   - number of model repetitions
%       SV          - [1 x rois] number of SVs to keep per ROI
%       use_mex     - (optional) true to use MEX acceleration
%       log_progress - (optional) true to log progress into a .txt file
%
% OUTPUTS:
%   model:        A model of functional connectivity using truncated SVD (TSVD) on randomly subsampled time series data
%   R_model:      The correlation within the model


% Parameters
inc_frames = options.min_frames;
rep = options.rep_model;
[frames, rois] = size(signal);
SV = options.SV;
use_mex = isfield(options, 'use_mex') && options.use_mex;
log_progress = isfield(options, 'log_progress') && options.log_progress;
mask = 1:rois;

% Setup progress logging
if log_progress
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    progress_log = fullfile(pwd, sprintf('progress_%s.txt', timestamp));
    
    % Create the log file
    fid = fopen(progress_log, 'wt');
    if fid > 0
        fprintf(fid, 'Progress Log Started: %s\n', datestr(now));
        fclose(fid);
    end
    fprintf('Logging progress to: %s\n', progress_log);
else
    progress_log = '';
end

% Preallocate
local_model = zeros(rois, rois, rep, 'like', signal);
local_R = zeros(rois, rois, rep, 'like', signal);

% Parallel loop over repetitions
parfor i = 1:rep
    ix = randperm(frames);
    TC_in = signal(ix(1:inc_frames), :);

    % Fast correlation using matrix ops
    R = (TC_in' * TC_in) / (inc_frames - 1);
    norms = sqrt(diag(R));
    R = R ./ (norms * norms');  % Normalize to correlation
    local_R(:, :, i) = R;

    temp_model = zeros(rois, rois, 'like', signal);  % Local copy

    for j = 1:rois
        y_in = TC_in(:, j);
        A = TC_in(:, mask ~= j);

        % Truncated SVD
        [U, S, V] = svd(A, 'econ');
        k = SV(j);
        Uk = U(:, 1:k);
        Sk = S(1:k, 1:k);
        Vk = V(:, 1:k);

        % Fast pseudoinverse and regression
        x_inv = Vk * diag(1 ./ diag(Sk)) * Uk';
        temp_model(j, mask ~= j) = x_inv * y_in;
    end

    local_model(:, :, i) = temp_model;

    % Log progress
    if ~isempty(progress_log)
        % Use try-catch to avoid file contention issues
        try
            fid = fopen(progress_log, 'a');
            if fid > 0
                fprintf(fid, 'Completed repetition %d / %d at %s\n', i, rep, datestr(now, 'HH:MM:SS'));
                fclose(fid);
            end
        catch
            % If writing fails, silently continue
        end
    end
end

% Average model and correlation
model = mean(local_model, 3);

% Fisher Z-transform, average, then inverse
local_Z = atanh(local_R);
mean_Z = mean(local_Z, 3);
R_model = tanh(mean_Z);

end
