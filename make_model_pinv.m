function [model, V]=make_model_pinv(signal,options)

if isempty (options)
    options.min_frames=size(signal,1);
    options.rep_model=1;
end
% Oscar Miranda-Dominguez
inc_frames=options.min_frames;
rep=options.rep_model;
[frames, rois]=size(signal);
mask=1:rois;


if nargout>1
    V=zeros(rois);
    den=frames-rois-1;
end
% SV=options.SV;
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
%         pre_pA=inv(A'*A);
        pre_pA=eye(rois-1)/(A'*A);
        pA=pre_pA*A';
        local_model(j,mask~=j,i)=pA*y_in;
        
        if nargout>1
            yp=A*local_model(j,mask~=j,i)';
            J=sum(y_in-yp)^2;
            s2=J/den;
            V(j,mask~=j,i)=s2*diag(pre_pA);
        end  
        j
        %         [U, S, V]=svd(A,'econ');
        %         %         [U, S, V]=svd(A);
        %         x_inv=zeros(rois-1,inc_frames);
        %         for l=1:size(S,1)%SV(j)%
        %             %             try
        %             x_inv=x_inv+V(:,l)*(1/S(l,l))*U(:,l)';
        %             %             catch
        %             %                 1
        %             %             end
        %         end
        %         local_model(j,mask~=j,i)=x_inv*y_in;
    end
end
model=mean(local_model,3);
