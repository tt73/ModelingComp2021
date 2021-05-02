%%
% Written by Jimmie, Tada 
%
function [dcost,vcost] = sectorObjective(testangle,customers,param_obj,cost_obj)
% testangle = array of angles that divide the 2D cartesian grid 
% customers = array of customers
% param_obj = structure with fields containing problem parameters
% cost_obj  = structure with fields containing cost-related parameters 

numsects = length(testangle);
pos = [customers.pos]; 
ang = atan2(pos(2,:),pos(1,:));

costs = zeros(numsects,1);
tour_distance = zeros(numsects,1);
num_jobs = zeros(numsects,1); 

for i=1:numsects
   
   % Get a mask (bool array) for all customers in current sector 
   if i==numsects 
      sectorindex = (testangle(i)<ang) | (ang<testangle(1)); 
   else
      sectorindex = (testangle(i)<ang) & (ang<testangle(i+1)); 
   end
   
   num_jobs(i) = sum(sectorindex);
   if (num_jobs==0)
      continue
   end
   
   % extract position of customers in sector 
   x = [0, pos(1,sectorindex)]; 
   y = [0, pos(2,sectorindex)]; 
   
   P = [x; y]; % coordinates / points
   c = mean(P,2); % mean/ central point
   d = P-c ; % vectors connecting the central point and the given points
   th = atan2(d(2,:),d(1,:)); % angle above x axis
   [~, idx] = sort(th);   % sorting the angles
   P = P(:,idx); % sorting the given points
   P = [P P(:,1)]; % add the first at the end to close the polygon

   [~,n] = size(P);
   for j = 1:n-1
      tour_distance(i) = tour_distance(i) + norm(P(:,j)-P(:,j+1),2);
   end
end

% exclude empty sectors 
nonzeroindices = find(tour_distance~=0);
tour_distance = tour_distance(nonzeroindices);
num_jobs = num_jobs(nonzeroindices);
tour_duration = tour_distance/param_obj.vel + num_jobs*param_obj.mst; 

% compute cost for each worker
m = length(tour_distance); 
Jm = cost_obj.pm*ones(m,1); % hire cost
Jt = tour_distance*cost_obj.pt; % travel cost
Jo = ((tour_duration>cost_obj.L*60).*(tour_duration-cost_obj.L*60))*cost_obj.po;
J = Jm + Jt + Jo; % cost per worker

% Add cost based on traveling 
dcost = sum(J);
vcost = var(J);