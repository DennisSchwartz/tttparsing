% searches all subfolders for all files with given extension

function res = getfiles_rec(varargin)

folder = varargin{1};
ext = varargin{2};
maxlevel = inf;
level = 0;
if numel(varargin) > 2
    maxlevel = varargin{3};
    level = varargin{4};
end
d = dir(folder);

files = dir([folder '/*.' ext]);

if numel(files)>0
    res.files = {files.name};
    res.folders = repmat({folder},1,numel(files));
else
    res.files={};
    res.folders={};
end
% return
if sum([d.isdir])>2
    if maxlevel <  level+1;
        return
    end
    for i = find([d(3:end).isdir])
        
        new = getfiles_rec([folder '/' d(i+2).name],ext,maxlevel,level+1);
        res.files = [res.files new.files];
        res.folders = [res.folders new.folders];
    end

end

