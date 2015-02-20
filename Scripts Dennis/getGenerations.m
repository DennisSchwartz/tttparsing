%Analysis of per generation, generation time of a tree
function generations = getGenerations(tree)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Step 1:
%       Get number of generations.
%       Get generation for each relevant cell
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%Get max cellNr
maxCell = max(tree.cellNr);

%Calculate max generation
maxGen = floor(log2(maxCell));

%Assign generation to each cellNr
generation = zeros(1, length(tree.cellNr)); %alloc mem for gen vector
for x = 1:maxGen
    lowerBound = 2^x;
    upperBound = 2^(x+1)-1;
    %Get trackpoints for relevant cellNrs
    curr = tree.cellNr >= lowerBound & tree.cellNr <= upperBound;
    %Assign the generation number x to these trackpoints
    generation(curr) = x;
end

%Add vector assigning a generation to every trackpoint in tree
generations = generation;

end