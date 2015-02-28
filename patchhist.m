% usage:
%   patchHist(data,bins, {,parameter, value...})
%
% required parameters:
%  data - cell array of data vectors
%  bins - number of bins used for the histograms
%
% optional parameters:
%  colors
%  alpha
%  normalize



function ps = patchhist(data, bins, varargin)

%% parse parameters
p = inputParser;
p.StructExpand=true; % if we allow parameter  structure expanding
p.addRequired('data', @iscell);
p.addParamValue('colors', lines, @isnumeric);
p.addParamValue('alpha', 0.3, @isnumeric);
p.addParamValue('normalize', false, @islogical);
p.addParamValue('legend', {}, @iscell);
p.parse(data, varargin{:});
r=p.Results;


%% plotting


% iterate over columns
for i=1:numel(data)
    [y,x] = hist(data{i},bins);
    hold on;
    color =  r.colors(mod(i,numel(r.colors)),:);

    if (r.normalize)
        y = y ./ numel(data{i});
        y = y / (max(data{i}) -min(data{i}));
    end
    xline{i}=x;
    yline{i}=y;
    %     plot(x,y, 'Color',  color );
    p = patch([x(1) x x(end)],[min(0) y min(0)],color,'FaceAlpha',r.alpha);
    ps(i) = p;
end

for i=1:numel(data)
    color =  r.colors(mod(i,numel(r.colors)),:);
   h =  plot([xline{i}(1) xline{i} xline{i}(end)],[0 yline{i} 0],'Color',color);
end
if ~isempty(r.legend)
    legend(ps,r.legend);
end
% set(lh,'units','pixels');
% lp=get(lh,'outerposition');
% set(lh,'outerposition',[300,850,100,50]);
hold off;