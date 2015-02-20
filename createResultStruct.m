%% fill or extend all missing elements of a treedata
function results = createResultStruct(moviename,varargin)
% usage:
%   printfig(name {,parameter, value})
%
% read ttt tracking files and produces a result structure with all
% available information
%
% parameters:
%   wl             : wavelength (default: 'w0')
%   format         : image format (default: 'png')
%   experimentspath: path to all experiments on the storage or your local
%                    folder (default: Z:\TTT\)
%   treepath       : path to the trackes trees (*.ttt, default:
%                    'X:\TTTfies\')
%   cellthresh     : only use trees with at least x cells (default: 3)


%% parse parameters
p = inputParser;
p.StructExpand=true; % if we allow parameter  structure expanding
p.addRequired('moviename', @ischar);
p.addParamValue('outpath', '/Users/ds/Documents/ICB/TTTFiles_Parsing/resultfiles_TEMP/', @ischar);
p.addParamValue('wl', 'w00', @(x)any(strcmpi(x,{'w0','w1','w2','w3','w4','w5','w6','w00','w01','w02','w03','w04','w05','w06','w07','w08'})));
p.addParamValue('format', 'png', @(x)any(strcmpi(x,{'tif','jpg','png'})));
p.addParamValue('experimentspath', '/Users/ds/Documents/ICB/TTTFiles_Parsing/Exp', @ischar);
p.addParamValue('treepath', '/Users/ds/Documents/ICB/TTTFiles_Parsing/Tree', @ischar); %exists only on susi!!!
p.addParamValue('cellthresh', 1, @isnumeric);

p.parse(moviename,varargin{:});
r = p.Results;
if ispc && sum(strfind(r.outpath,'\')) == 0
    r.treepath =  'X:\';
    r.experimentspath = 'I:\';
    r.outpath = 'I:\resultfiles\';
else
    addpath(genpath('/Users/ds/Documents/ICB/TTTFiles_Parsing'))
end

imgroot= [r.experimentspath '/' r.moviename];
wavelength = [r.wl '.' r.format];

moviestart = getmoviestart(imgroot);
year = ['20' moviename(1:2)];
xml = dir([imgroot '/' r.moviename '_TATexp.xml']);
xmlpath = [imgroot '/' xml(end).name];

% d = dir([treepath '*.ttt']);
stru = getfiles_rec([r.treepath '/TTTfiles/' year '/' r.moviename '/'],'ttt');
if numel(stru.files) < 1
    error('no Tree Files found for this path')
end

if exist([r.outpath 'results' r.moviename '.mat']) ~= 0
    load([r.outpath 'results' r.moviename '.mat'])
    existingTrees = cellfun(@(x) x.description.treeFile,results,'uniformoutput',false);
else
    results = {};
    existingTrees = {};
end

for i=1:numel(stru.files)
    % get tracking data
    res = tttParser([stru.folders{i} '/' stru.files{i}],xmlpath);
    resultsidx = 1;
    if isempty(res) || numel(unique(res.cellNr)) < r.cellthresh
        continue
    end
    fprintf('==============================================================\n')
    fprintf('Processing %s (%i of %i)\n',stru.files{i},i,numel(stru.files))
    if sum(ismember(existingTrees,stru.files{i})) > 1
        error('Tree %s exists  multiple times in existing resultsfile!!! Check that!\n',stru.files{i})
    elseif sum(ismember(existingTrees,stru.files{i})) == 1
        existingTree = find(ismember(existingTrees,stru.files{i}));
        if numel(res.timepoint) ~= numel(results{existingTree}.nonFluor.timepoint)
            disp('Tree already exists and was extended... updating!')
            treeidx = existingTree;
            if exist(sprintf('%s%s/treemeasurements/tree_%.4i/',r.experimentspath,r.moviename,treeidx),'dir')
                rmdir(sprintf('%s%s/treemeasurements/tree_%.4i/',r.experimentspath,r.moviename,treeidx),'s');
            end
        else
            disp('Tree already exists and was not extended... skipping!')
            continue;
        end
    else
        treeidx = numel(results)+1;
    end
    
    resfields = fields(res);
    treefile = dir([stru.folders{i} '/' stru.files{i}]);
    treefiledate = treefile.date(1:end-9);
    results{treeidx}.description.date = treefiledate;
    % map filenames
    for posi = unique(res.positionIndex)'
        fprintf('gathering position %d files %s...\n',posi,r.wl)
        
        % read position log file to get absolute timepoints otherwise use old
        % method
        if exist(sprintf('%s/%s_p%04d/',imgroot,r.moviename, posi),'dir')
            newexperiment=1;
            filename = sprintf('%s/%s_p%04d/%s_p%04d.log',imgroot,r.moviename,posi,r.moviename,posi);
        else
            newexperiment = 0;
            filename = sprintf('%s/%s_p%03d/%s_p%03d.log',imgroot,r.moviename,posi,r.moviename,posi);
            
        end
        
        if exist(filename,'file')
            % read logfile
            log = positionLogFileReader(filename);
            
            idx=find(res.positionIndex == posi)';
            
            wl = strsplit(wavelength,'.');
            wl = str2double(wl{1}(2:end));
            
            for id = idx
                % store everything
                abstime = log.absoluteTime(log.timepoint == res.timepoint(id) & log.wavelength == wl);
                if isempty(abstime)
                    continue
                else
                    zindex= '';
                    if newexperiment
                        if log.zindex(log.timepoint == res.timepoint(id) & log.wavelength == wl) ~= -1
                            zindex = sprintf('z%03d_',log.zindex(log.timepoint == res.timepoint(id) & log.wavelength == wl));
                        end
                        % example:
                        % old 110624AF6_p0024_t00002_w1.tif
                        % new 111103PH5_p0148_t00002_z001_w01.png
                        
                        filename = sprintf('%s_p%04d/%s_p%04d_t%05d_%s%s', r.moviename,posi,r.moviename,posi,res.timepoint(id),zindex,wavelength);
                    else
                        filename = sprintf('%s_p%03d/%s_p%03d_t%05d_%s%s',  r.moviename,posi,r.moviename,posi,res.timepoint(id),zindex,wavelength);
                    end
                    for f = 1:numel(resfields)
                        results{treeidx}.nonFluor.(resfields{f})(resultsidx) = res.(resfields{f})(id);
                    end
                    results{treeidx}.nonFluor.absoluteTime(resultsidx) = abstime-moviestart;
                    results{treeidx}.nonFluor.filename{resultsidx} = filename;
                    results{treeidx}.description.treeFile = stru.files{i};
                    resultsidx = resultsidx+1;
                end
            end
            fieldz = fields(results{treeidx}.nonFluor);
            if ismember('manual_check',fieldz)
                rmfield(results{treeidx}.nonFluor,'manual_check');
                rmfield(results{treeidx}.nonFluor,'annotator');
            end
        else
            error(sprintf('Missing log files for %s. Please load ALL log files on the server',filename))
        end
    end
end
if ~isempty(setdiff(existingTrees,stru.files))
    [~,ia] = setdiff(existingTrees,stru.files);
    warning(sprintf('%i Trees were deleted, setting results to empty struct',numel(ia)))
    results(ia) = [];
end

if sum(cellfun(@isempty,results)) ~= 0
    warning('There were empty tracks!!!')
    results(cellfun(@isempty,results)) = [];
end
try
    if isfield(r,'outpath') && ~strcmp(r.outpath,'')
        save([r.outpath 'results' moviename '.mat'],'results')
        if isunix
            unix(['chmod 775 ' r.outpath 'results' moviename '.mat'])
        end
    end
catch me
    warning('Save failed!!!!')
end
fprintf('%i trees with at least %i cells saved as results struct!\n',numel(results),r.cellthresh)
end