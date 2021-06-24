function validated_mask=validate_mask(mask)


%% Detect if preselected frames
n_mask=size(mask);

preselected_frames_flag=1;
if n_mask(2)==1
    preselected_frames_flag=0;
end
preselected_frames_flag=preselected_frames_flag==1;

%% 

validated_mask=mask(:,end); %default
if preselected_frames_flag
    % do nothing
else
    min_frames=min(cellfun(@sum,mask));
    for i=1:n_mask(1)
        local_mask_all=validated_mask{i};
        local_ix=find(local_mask_all);
        p = randperm(numel(local_ix));
        p_truncated=p(1:min_frames);
        local_ix_truncated=local_ix(p_truncated);
        
        local_mask_template=and(local_mask_all,0);
        local_mask_template(local_ix_truncated)=1;
        local_mask_template=local_mask_template==1;
        
        validated_mask{i}=local_mask_template;
    end
end
