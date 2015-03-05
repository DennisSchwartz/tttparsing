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
bins = unique(overallDistA);
bins = [bins (max(bins) + 1)];
hold on;
a = histfit(overallDistA, 20);
xlabel('# of Measurements');
ylabel('occurences');

xlim([min([overallDistA overallDistB]) 300]);%max([overallDistA overallDistB])]);

b = histfit(overallDistB, 20);
%b = bar(y,n, 'hist');
set(b(1),'FaceColor',[1,0.8,0]);
set(b(1),'FaceAlpha',0.4);
set(b(2),'color',[0,1,0]);
%area = sum(n)*(y(2)-y(1));
 
muA = mean(overallDistA);
vlineA = line([muA muA], get(gca, 'ylim'));
set(vlineA, 'color', get(a(2), 'color'));

muB = mean(overallDistB);
vlineB = line([muB muB], get(gca, 'ylim'));
set(vlineB, 'color', get(b(2), 'color'));


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
