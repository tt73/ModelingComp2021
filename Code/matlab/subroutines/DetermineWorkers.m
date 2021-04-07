%%
% Written by Jimmie
%
function [num_workers,sector_angles] = DetermineWorkers(customers,minND,maxND,w,plots)

% these differential evolution parameters are fixed
DEParams.F = 0.6;
DEParams.CR = 0.9;
DEParams.NP = 70;
DEParams.Nmax = 50;

J =@(x) sectorObjective(x,customers,w,false); % function handle

optimizer = zeros(maxND,maxND-minND+1);
lastcost = zeros(1,maxND-minND+1);

for j = minND:maxND
   
   % ND = number of sectors
   DEParams.ND = j; % ND is an integer ranging from minND to maxND
   
   % The array l is a discretization from -π to π,
   % so l = -pi:2*pi/ND:pi
   l = zeros(1,DEParams.ND);
   for i = 1:DEParams.ND
      l(i) = 2*(i-1)/DEParams.ND*pi-pi; % (2πi)/ND - π
   end
   
   optimizers = diffevoAngles(J,l,DEParams); % ????
   
   % Compute the cost NP number of times
   cost = zeros(1,DEParams.NP);
   for i = 1:DEParams.NP
      cost(i) = J(optimizers(:,i));
   end
   
   % [~,optind] = min(cost);
   optind = find(cost==min(cost)); % index of lowest cost
   optind = optind(1); % in case multiple minimums are found  
   
   lastcost(j-minND+1) = cost(optind);
   optimizer(1:j,j-minND+1) = optimizers(:,optind);
end

% jj = find(min(lastcost)==lastcost); % index of lowest cost
[~,jj] = min(lastcost);

lastoptimizer = optimizer(1:minND+jj-1,jj);

[~,num_workers] = sectorObjective(lastoptimizer,customers,w,plots);
sector_angles = lastoptimizer;