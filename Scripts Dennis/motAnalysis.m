%%Main class for motility analysis
function results = motAnalysis(trees, cutoff)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Get generation labels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:length(trees)
    trees{1,i}.nonFluor.generation = getGenerations(trees{1,i}.nonFluor);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Calculate overall generation time distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Calculate first half of gen times
gentimesA = [];
for i = 1:cutoff
    currTree = trees{1,i}.nonFluor;
    res = calcGenTime(currTree);
    gentimesA = [gentimesA res];
end
results.gentimesA = gentimesA;

%%Calculate the rest of the gen times
gentimesB = [];
for i = cutoff:length(trees)
    currTree = trees{1,i}.nonFluor;
    res = calcGenTime(currTree);
    gentimesB = [gentimesB res];
end
results.gentimesB = gentimesB;

results.meanA = mean(gentimesA);
results.meanB = mean(gentimesB);
results.meanDiff = mean(gentimesA) - mean(gentimesB);
end
