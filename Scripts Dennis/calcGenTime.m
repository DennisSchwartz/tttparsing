%Analysis of overall and per generation cell cycle times of a tree
function genTimeDist = calcGenTime(tree)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 1:
%   Extract only those Trackpoints where tracked cells end in division.
%   This removes lost cells, the last generation and the root/first cell.
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Get only trackpoints of cells with stopReason "Division" ( == 1)
disp('Discard lost cells, root cell and last generation...');
relevantTrackPoints = find(tree.stopReason == 1);

%Remove root cell
%Get trackpoints for root cell
rootTP = find(tree.cellNr == 1);
%remove root trackpoints from revelantTrackPoints
for tp = rootTP
    relevantTrackPoints(relevantTrackPoints == tp) = [];
end

if isempty(relevantTrackPoints)
    genTimeDist = {};
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Step 2:
%   Get the cell numbers and generations for the relevant track points.
%   The more trackpoints for each cellNr (== cell ID), the longer its
%   generation/cell cycle time (== time btw. split from parent to its own division).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Extracting IDs/Trackpoints of relevant cells...');
cellNmbrsForRelTP = zeros(1,length(relevantTrackPoints)); %Preallocate memory
tempGen = zeros(1, length(relevantTrackPoints)); %Preallocate memory
counter = 1; 
for tp = relevantTrackPoints
    cellNmbrsForRelTP(1,counter) = tree.cellNr(1,tp);
    tempGen(1, counter) = tree.generation(1, tp);
    counter = counter + 1;
end 
%Get the relevant generations
relGenerations = unique(tempGen);

disp('Done!');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Step 3:
%   Generate a Histogram displaying the number of trackpoints each cell
%   (cellNr) occupies. This represents overall generation time (see Step 2).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Calculating overall generation time distibution...');
u = unique(cellNmbrsForRelTP); %Get unique cellNrs
bins = [u (max(unique(u)) + 1)]; %Set bins for Hist
[overallDist, hist, bin] = histcounts(cellNmbrsForRelTP, bins);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Step 4:
%   Get distribution for each generation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Relevant trackpoints are those, with the right generation number
%From those relTP extract cellNr counts to get cell cycle times
cellNmbrsAllGens = []; %Can't allocate memory -> changing size
generations = [];
for i = relGenerations
   %get all trackpoints of generation i
   temp = tempGen == i;
   cellNmbrsThisGen = cellNmbrsForRelTP(temp);
   generations = [generations linspace(i,i,length(cellNmbrsThisGen))];
   cellNmbrsAllGens = [cellNmbrsAllGens cellNmbrsThisGen];
end

%display per generation Tc distribution
boxplot(cellNmbrsAllGens, generations);

%Display Histogram
histogram(overallDist);

disp('All done...');
disp('Returning distribution.');
genTimeDist.overall = overallDist;
genTimeDist.generations = generations;
genTimeDist.cellNmbrs = cellNmbrsAllGens;

return
end