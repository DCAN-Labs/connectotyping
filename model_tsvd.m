function [SV, R]=model_tsvd(signal,options)
% Oscar Miranda-Dominguez
perc=options.perc;
rep=options.rep_svd;
[frames, rois]=size(signal);
mask=1:rois;

inc_frames=round(frames*perc(1));
max_SV=min([inc_frames rois-1]);
% SV = zeros(rep,max_SV,rois);
R  = zeros(rep,rois,max_SV);
parfor i=1:rep
    ix=randperm(frames);
%     ix=randi(frames,[1 frames]); %bootstraping, allowing repeated data
    ix_in=ix(1:inc_frames);
    ix_out=ix(inc_frames+1:end);
    TC_in=signal(ix_in,:);
    TC_out=signal(ix_out,:);
    for j=1:rois
        y_in=TC_in(:,j);
        y_out=TC_out(:,j);
        A=TC_in(:,mask~=j);
        [U S V]=svd(A,'econ');
%         [U, S, V]=svd(A);
%         x_inv=zeros(rois-1,max_SV);
        x_inv=zeros(rois-1,inc_frames);
        for l=1:max_SV
%             try
            x_inv=x_inv+V(:,l)*(1/S(l,l))*U(:,l)';
            local_c=x_inv*y_in;
            yp=TC_out(:,mask~=j)*local_c;
            R(i,j,l)=corr(yp,y_out);
%             catch
%                 1;
%             end
        end
    end
    display(['SVD decomposition, ' num2str(i) ' out of ' num2str(rep)])
end


%% Original logic to get the best number of components
mr=squeeze(tanh(mean(atanh(R),1)));
[m, SV]=max(mr,[],2);
%% updating the logic
%1. Across subjects, calculate the largest explain variance 
%2. For each ROI, identify the global maxima, ie the number of components
%that maximize out of sample explained variance 

% Z=atanh(R);
% if sum(isinf(Z(:)))==0
%     sumR=squeeze(nansum(Z,1));
% else
%     sumR=squeeze(nansum(R,1));
% end
sumR=squeeze(nansum(R,1));
[maxR, I]=max(sumR,[],2);