function model=make_model_tsvd(signal,options)

% Oscar Miranda-Dominguez
inc_frames=options.min_frames;
rep=options.rep_model;
[frames, rois]=size(signal);
mask=1:rois;
SV=options.SV;
local_model=zeros(rois,rois,rep);

% SV = zeros(rep,max_SV,rois);

for i=1:rep
    ix=randperm(frames);
    ix_in=ix(1:inc_frames);
    %ix_out=ix(inc_frames+1:end);
    TC_in=signal(ix_in,:);
    %TC_out=signal(ix_out,:);
    for j=1:rois
        y_in=TC_in(:,j);
        %y_out=TC_out(:,j);
        A=TC_in(:,mask~=j);
        
        [U, S, V]=svd(A,'econ');
        %         [U, S, V]=svd(A);
        x_inv=zeros(rois-1,inc_frames);
        for l=1:size(S,1)%SV(j)
            %             try
            x_inv=x_inv+V(:,l)*(1/S(l,l))*U(:,l)';
            %             catch
            %                 1
            %             end
        end
        local_model(j,mask~=j,i)=x_inv*y_in;
    end
end

model=mean(local_model,3);
