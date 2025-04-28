function cat_folder=cat_folders(folders,n_folders)
f=filesep;

cat_folder=[];
for i=1:n_folders
    cat_folder=[cat_folder folders{i} f];
end
cat_folder(end)=[];