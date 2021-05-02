%%
% Written by Jimmie, Tada
%
% I will modify so it runs over all
function [finalist] = DetermineSectors(customers,minND,maxND,w,param_obj,cost_obj)
% customers - array of Customer
% minND - integer, smallest number of sectors
% maxND - integer, largest number of sectors
% w - float, weight. w=0 means trust dcost, w=1 means trust vcost.
% param_obj - struct - contains problem parameters
% cost_obj - struct - contains cost parameters


% these differential evolution parameters are fixed
DEParams.F = 0.8;   % (default 0.8)
DEParams.CR = 0.9;  % (default 0.9)
DEParams.NP = 50;   % (default n*10)
DEParams.Nmax = 50;
DEParams.tol = 1e-5;

% sub population which moves on to final round
sub_NP = floor(DEParams.NP/4); % quarter of NP

% This objective actually returns 2 types of cost: dcost, and varcost
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
   
   % Get the evolved population pop (ND x NP)
   % Also get the cost of each col and the variance.
   [pop, costs, tour_vars] = diffevoAngles2(J,l,w,DEParams);
   
   % Normalize the cost and variance w.r.t. local population
   minc = min(costs(:));
   maxc = max(costs(:));
   minv = min(tour_vars(:));
   maxv = max(tour_vars(:));
   normalized_cost = (semifinal_cost-minc)/(maxc-minc);
   normalized_vars = (semifinal_vars-minv)/(maxv-minv);
   
   % Save the semi-finalists
   [~,optind] = sort(w*normalized_vars +(1-w)*normalized_cost);
   semifinal_vars(:,j) = tour_vars(optind(1:sub_NP));
   semifinal_cost(:,j) = costs(optind(1:sub_NP));
   for i = 1:sub_NP
      semifinalists{j,i} = pop(:,optind(i));
   end
   
end

% Normalize the cost and var w.r.t. semifinalists
minc = min(semifinal_cost(:));
maxc = max(semifinal_cost(:));
minv = min(semifinal_vars(:));
maxv = max(semifinal_vars(:));
normalized_cost = (semifinal_cost-minc)/(maxc-minc);
normalized_vars = (semifinal_vars-minv)/(maxv-minv);

% figure,subplot(121),heatmap(normalized_cost),subplot(122),heatmap(normalized_vars)

weighted_cost = w*normalized_vars(:) + (1-w)*normalized_cost(:);
[~,ind] = min(weighted_cost);
row = mod(ind-1,sub_NP)+1;
col = ceil(ind/num_ND);
finalist = semifinalists{row,col};