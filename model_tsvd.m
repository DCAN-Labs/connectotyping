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
for i=1:rep
    ix=randperm(frames);
    ix_in=ix(1:inc_frames);
    ix_out=ix(inc_frames+1:end);
    
    TC_in=signal(ix_in,:);
    
    [row_count, col_count] = size(TC_in);
    filename = sprintf('TC_in_%d_%d.csv', row_count, col_count);
    writematrix(TC_in, filename)
    
    TC_out=signal(ix_out,:);
    for j=1:rois
        y_in=TC_in(:,j);
        y_out=TC_out(:,j);
        A=TC_in(:,mask~=j);
        
        [U, S, V]=svd(A,'econ');
        x_inv=zeros(rois-1,inc_frames);
        for l=1:max_SV
            x_inv=x_inv+V(:,l)*(1/S(l,l))*U(:,l)';
            local_c=x_inv*y_in;
            yp=TC_out(:,mask~=j)*local_c;
            R(i,j,l)=corr(yp,y_out);
        end
    end
    display(['SVD decomposition, ' num2str(i) ' out of ' num2str(rep)])
end

% R is a 3-d object participant * ROI * s
mr=squeeze(mean(R,1));
[m, SV]=max(mr,[],2);
