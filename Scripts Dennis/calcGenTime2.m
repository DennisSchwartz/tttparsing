%Analysis of overall and per generation cell cycle times of a tree
function genTimeDist = calcGenTime2(tree)


%Only cells with stopReason == 1 are relevant
mask = tree.nonFluor.stopReason == 1;
relCellNmbrs = unique(tree.nonFluor.cellNr(mask));
%remove first cell
relCellNmbrs = relCellNmbrs(relCellNmbrs ~= 1);

%Calculate overall cell cycle time distribution
genTimeDist.overall = getTimes(tree, relCellNmbrs);

%Calculate per-generation cell cycle time distribution
genTimeDist.perGeneration = {};

%Number of generations: Log2 of Highest cell number
numGens = floor(log2(max(relCellNmbrs)));

for i = 1:numGens
   %get cellNumbers of current gen
   lowerBound = power(2, i);
   upperBound = power(2, i+1) - 1;
   %mask = tree.nonFluor.generation == i;
   numbers = relCellNmbrs(relCellNmbrs >= lowerBound & relCellNmbrs <= upperBound);
   genTimeDist.perGeneration{1, i} = getTimes(tree, numbers);
end

end

function times = getTimes(tree, numbers)

cellNmbrs = numbers;
times = zeros(1, length(cellNmbrs));

counter = 1;
for i = cellNmbrs

mask = tree.nonFluor.cellNr == i;
tempTimes = tree.nonFluor.timepoint(mask);
times(counter) = max(tempTimes) - min(tempTimes);
counter = counter + 1;

end

end