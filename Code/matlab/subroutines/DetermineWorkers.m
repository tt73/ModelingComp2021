%%
% Written by Jimmie
%
function [num_workers,sector_angles] = DetermineWorkers(customers,minND,maxND,w,plots,param_obj,cost_obj)

% these differential evolution parameters are fixed
DEParams.F = 0.8; % (default 0.8) 
DEParams.CR = 0.9; % (default 0.9)
DEParams.NP = 100;  % (default n*10)
DEParams.Nmax = 50; 

J =@(x) sectorObjective(x,customers,false,param_obj,cost_obj); % function handle

NDs = minND:maxND;
num_ND = length(NDs);
optimizer = cell(num_ND,1);
lastcost = zeros(num_ND,1);

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
   [pop,costs,tour_vars] = diffevoAngles2(J,l,DEParams); 
   
   
   % Weight the cost and the variance
   costs = costs/norm(costs);
   vars = tour_vars/norm(tour_vars);
   weighted = w*vars + (1-w)*costs;
   
   [~,optind] = min(weighted);
   
   lastcost(j) = weighted(optind);
   optimizer{j} = pop(:,optind);
end

[~,jj] = min(lastcost);

lastoptimizer = optimizer{jj};

[~,num_workers] = sectorObjective(lastoptimizer,customers,plots,param_obj,cost_obj);
sector_angles = lastoptimizer;