%%Main class for motility analysis
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
    else
        treesB = [treesB, trees{1,i}];
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Calculate cell cycle times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

resultsA = calcCt(treesA);

resultsB = calcCt(treesB);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Analyse Results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
allGen = [];
allCellNmbrs = [];
for i = 1:length(resultsA)
    allGen = [allGen resultsA.generations];
    allCellNmbrs = [allCellNmbrs resultsA.cellNmbrs];
end

gens = unique(allGen);

for g = gens
   mask = allGen == g;
   curr = allCellNmbrs(mask);
end


label = 'A';
plotResults(resultsA, label);
label = 'B';
plotResults(resultsB, label);

%results.gentimesB = gentimesB;

end

function void = plotResults(results, label)


dist = [];
cellNrs = [];
generations = [];
for x = results
    dist = [dist x.overall];
    cellNrs = [cellNrs x.cellNmbrs];
    generations = [generations x.generations];
end
    

boxplot(cellNrs, generations);
x = ['boxplot' label];
export_fig(x);

%generate histogram of overall cycle times
histogram(dist);

x = ['histogram' label];
export_fig(x);

end

function results = calcCt(trees)

results = [];
for i = 1:length(trees)
    currTree = trees{1,i}.nonFluor;
    res = calcGenTime(currTree);
    results = [results res];
end

end
