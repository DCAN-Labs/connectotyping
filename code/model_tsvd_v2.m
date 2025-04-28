function [SV, R] = model_tsvd_extended(signal, options)
% model_tsvd_extended: Computes predictive performance using truncated SVD for a given signal matrix
%
% INPUTS:
%   signal:    [frames x rois] time-series matrix
%   options:   struct with fields:
%       perc:     fraction of frames to use for training (e.g., 0.7)
%       rep_svd:  number of repetitions
%
% OUTPUTS:
%   SV:        [rois x 1] optimal number of singular values per ROI
%   R:         [rep x rois x max_SV] correlation results

    % Validate inputs
    if ~isfield(options, 'perc') || ~isfield(options, 'rep_svd')
        error('Options must contain "perc" and "rep_svd" fields.');
    end

    [nFrames, nROIs] = size(signal);
    mask = 1:nROIs;

    train_frames = round(nFrames * options.perc);
    max_SV = min(train_frames, nROIs - 1);

    rep = options.rep_svd;
    R = zeros(rep, nROIs, max_SV);

    parfor i = 1:rep  % Use 'parfor' for speed-up if Parallel Toolbox is available
        rng(i);  % For reproducibility in parfor
        idx = randperm(nFrames);
        idx_train = idx(1:train_frames);
        idx_test = idx(train_frames+1:end);

        TC_train = signal(idx_train, :);
        TC_test = signal(idx_test, :);

        local_R = zeros(nROIs, max_SV);

        for roi = 1:nROIs
            y_train = TC_train(:, roi);
            y_test = TC_test(:, roi);

            predictors = mask ~= roi;
            A = TC_train(:, predictors);
            B = TC_test(:, predictors);

            [U, S, V] = svd(A, 'econ');

            % Preallocate reconstruction
            x_inv = zeros(size(V, 1), size(U, 1));
            for k = 1:max_SV
                x_inv = x_inv + V(:, k) * (1 / S(k, k)) * U(:, k)';
                coeffs = x_inv * y_train;
                y_pred = B * coeffs;

                r = corr(y_pred, y_test);
                if ~isnan(r)
                    local_R(roi, k) = r;
                end
            end
        end
        R(i, :, :) = local_R;
        fprintf('Completed SVD rep %d / %d\n', i, rep);
    end

    % Aggregate results
    mr = squeeze(mean(R, 1));
    [~, SV] = max(mr, [], 2);
end