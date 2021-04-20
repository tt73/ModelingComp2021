%%
% Written by Jimmie, Tada
% 
function [finalists] = DetermineSectors(customers,minND,maxND,w,param_obj,cost_obj,N_best)
% This function runs the DE algorithm for each value of ND from minND to
% maxND. In each iteration, NP candidates are generated but only sub_NP
% move on to the next selection phase. 

% these differential evolution parameters are fixed
DEParams.F = 0.8;   % (default 0.8) 
DEParams.CR = 0.9;  % (default 0.9)
DEParams.NP = 80;   % (default n*10)
DEParams.Nmax = 50; 

% sub population which moves on to final round 
sub_NP = floor(DEParams.NP/4); % quarter of NP 

% convenient function handle to spit out cost of sector x
J =@(x) sectorObjective(x,customers,param_obj,cost_obj);

NDs = minND:maxND;
num_ND = length(NDs);

semifinalists = cell(sub_NP,num_ND);
semifinal_cost = zeros(sub_NP,num_ND);
semifinal_vars = zeros(sub_NP,num_ND);

% Vary the number of sectors. 
% For each number, do DE and get the best
for j = 1:num_ND
   
   % ND = dimension of cost input x 
   % ND = number of sectors
   DEParams.ND = NDs(j); 
   
   % The array l is a discretization from -π to π   
   dt = 2*pi/DEParams.ND;
   l = -pi:dt:pi-dt;
   
   % Get the evolved population
   % Also get the cost of each col and the variance
   [pop, costs, tour_vars] = diffevoAngles2(J,l,w,DEParams); 
   
   % Save the semi-finalists  
   [~,optind] = sort(costs+tour_vars);
   semifinal_vars(:,j) = tour_vars(optind(1:sub_NP));
   semifinal_cost(:,j) = costs(optind(1:sub_NP));
   for i = 1:sub_NP
      semifinalists{j,i} = pop(:,optind(i));
   end
   
end

normalized_cost = semifinal_cost/max(semifinal_cost(:));
normalized_vars = semifinal_vars/max(semifinal_vars(:));
weighted_cost = w*normalized_vars + (1-w)*normalized_cost;

if(1)  % this is just for debugging
   subplot(421)
   heatmap(NDs,1:sub_NP,semifinal_cost),title('Deterministic Cost')
   subplot(422)
   heatmap(NDs,1:sub_NP,semifinal_vars),title('Tour Variance')
   subplot(4,2,3:8)
   heatmap(NDs,1:sub_NP,weighted_cost),title(sprintf('Weighted cost w = %4.2f',w))
   xlabel('Number of sectors'),ylabel('Sub pop')
end

[~,ind] = sort(weighted_cost(:)); 

finalists = cell(N_best,1);
for i = 1:N_best
   row = mod(ind(i),sub_NP);
   col = ceil(ind(i)/num_ND);
   finalists{i} = semifinalists{row,col};
   fprintf('Number %2d: ND = %2d, Cost = %6.4f\n',i,NDs(col),weighted_cost(row,col))
end