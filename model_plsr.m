function [SV, R]=model_plsr(signal,options)
% Oscar Miranda-Dominguez
perc=options.perc;
rep=options.rep_svd;
[frames, rois]=size(signal);
mask=1:rois;

inc_frames=round(frames*perc(1));
max_SV=min([inc_frames rois-1])-1;
% SV = zeros(rep,max_SV,rois);
R  = zeros(rep,rois,max_SV);
for i=1:rep
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
        for l=1:max_SV-1
            [Xl,Yl,Xs,Ys,beta,pctVar,PLSmsep] = plsregress(A,y_in,l);
            local_c=beta(2:end);
            yp=[ones(size(TC_out,1),1) TC_out(:,mask~=j)] *beta;
            R(i,j,l)=corr(yp,y_out);
             
        end        
    end
    display(['Repetition, ' num2str(i) ' out of ' num2str(rep)])
end



mr=squeeze(mean(R,1));
[m, SV]=max(mr,[],2);