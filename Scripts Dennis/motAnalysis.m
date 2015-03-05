%% Main function for motility analysis
function results = motAnalysis(trees, A, B)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Get generation labels & Seperate trees after conditions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
treesA = {};
treesB = {};

for i = 1:length(trees)
    trees{1,i}.nonFluor.generation = getGenerations(trees{1,i}.nonFluor);
    if any(A == unique(trees{1,i}.nonFluor.positionIndex))
        treesA = [treesA, trees{1,i}];
    elseif any(B == unique(trees{1,i}.nonFluor.positionIndex))
        treesB = [treesB, trees{1,i}];
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Calculate cell cycle times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

resultsA = calcCt(treesA);
resultsB = calcCt(treesB);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Analyse overall Ct values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Condition A

overallDistA = [];
for i = 1:numel(resultsA)
    overallDistA = [overallDistA resultsA(i).overall];
end

%Condition B

overallDistB = [];
for i = 1:numel(resultsB)
    overallDistB = [overallDistB resultsB(i).overall];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Analyse per-generation cell-cycle times (Ct-Values)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Condition A
maxGensA = calcMaxGen(resultsA); %Calculate highest gen-count
perGenDistA = calcGenDist(resultsA, maxGensA); % Calculate per-gen distribution
    
% Condition B
maxGensB = calcMaxGen(resultsB); %Calculate highest gen-count
perGenDistB = calcGenDist(resultsB, maxGensB); % Calculate per-gen distribution


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Build Plots for Results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
% Scale Ct values from measurements to hours
scaledA = (overallDistA * 5) / 60;
scaledB = (overallDistB * 5) / 60;

%bins = unique(overallDistA);
%bins = [bins (max(bins) + 1)];

%Set number of bins
numBins = 20;
hold on;
%b = histfit(scaledB, numBins);
%a = histfit(scaledA, numBins);

%Calculate Probability and plot Bar graph
[cA, eA] = histcounts(scaledA, numBins);
probA = cA / length(scaledA);
a = bar(eA(1, 1:end-1), probA);

[cB, eB] = histcounts(scaledB, numBins);
probB = cB / length(scaledB);
b = bar(eB(1, 1:end-1), probB);

%Fit distribution to bar graphs
paramEstsA = wblfit(scaledA);
paramEstsB = wblfit(scaledB);
xgrid = linspace(8,32,100);
%A
pdfEstA = wblpdf(xgrid,paramEstsA(1),paramEstsA(2));
lA = line(xgrid,pdfEstA);
%B
pdfEstB = wblpdf(xgrid,paramEstsB(1),paramEstsB(2));
lB = line(xgrid,pdfEstB);


xlabel('Lifetime in Hours');
ylabel('Probability');

xlim([min([scaledA scaledB])-2 32]);%max([overallDistA overallDistB])]);

%b = bar(y,n, 'hist');
set(b(1),'FaceColor',[1,0.8,0]);
ch = get(b(1),'child');
set(ch,'FaceAlpha',0.4);
%set(b(1),'FaceAlpha',0.4);
%set(b(2),'color',[0,1,0]);
%area = sum(n)*(y(2)-y(1));
set(lA, 'color', [0,0,0]);
set(lB, 'color', [1,.6,0]);
 
muA = mean(scaledA);
vlineA = line([muA muA], get(gca, 'ylim'));
set(vlineA, 'color', get(lA, 'color'));

muB = mean(scaledB);
vlineB = line([muB muB], get(gca, 'ylim'));
set(vlineB, 'color', get(lB, 'color'));

title('Distributions of cell-cycle times');
legend('Wildtype','Tx+A83','Wildtype Fit & Mean','Tx+A83 Fit & Mean`')

hold off;

% Build plot for Per-Generation Results

% For A
figure;

[distA, grpA] = trans4Box(perGenDistA);
hold on;
title('Cell-cycle time distribution for each generation');
bpA = boxplot(distA, grpA);
xlabel('Generation');
ylabel('Cell-cycle times');
ylim([10 25]);
hold off;

% For B
figure;
[distB, grpB] = trans4Box(perGenDistB);
hold on;
title('Cell-cycle time distribution for each generation');
bpB = boxplot(distB, grpB);
xlabel('Generation');
ylabel('Cell-cycle times');
ylim([10 25]);
hold off;

end



%% Helperfunction to call the per generation Ct extraction on a set of trees
function results = calcCt(trees)
results = [];
for i = 1:length(trees)
    res = calcGenTime2(trees{1, i});
    results = [results res];
end
end

%% Calculate the largest number of generations in a set of trees
function maxGens = calcMaxGen(results)
maxGens = 0;
for i = 1:numel(results)
   gens = numel(results(i).perGeneration); %get number of gens in current tree
   if maxGens < gens
       maxGens = gens;
   end
end
end
%% Merge the per generation Ct distributions for a set of trees into one cell array.
%   Output: Cell array with one vector of Ct values per generation/row
function perGenDist = calcGenDist(results, maxGens)
perGenDist = cell(maxGens,1);
for i = 1:maxGens %For all generations
    for j = 1:numel(results) %Go through trees
        if numel(results(j).perGeneration) >= i %if generation exists in this tree
            perGenDist{i, 1} = [perGenDist{i, 1} cell2mat(results(j).perGeneration(i))]; %add i-th generation of current tree
        end
    end
end
end

%% Function transforming the struct of perGen distributions to a single dist with a corresponding grouping array for BoxPlots
function [dist, group] = trans4Box(pgDist)

dist = [];
group = [];
for i = 1:length(pgDist)
    dist = [dist cell2mat(pgDist(i))];
    group = [group linspace(i,i,length(cell2mat(pgDist(i))))];
end

%Scale to hours
dist = (dist * 5) / 60;

end
