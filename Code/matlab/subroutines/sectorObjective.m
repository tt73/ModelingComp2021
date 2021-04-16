%%
% Written by Jimmie 
%
function [J,numworkers,tour_var] = sectorObjective(testangle,customers,make_plots,param_obj,cost_obj)
% pass cost object 
% routing (numworker by 1) cell array 

numsects = length(testangle);
J = 0;
N = max(size(customers));

% Test if any angles fall outside the allowed limits
if(any(testangle>pi) || any(testangle<-pi))
   J = inf;
   numworkers = nan;
   tour_var = nan;
   return
end


% initialize their position and relative distance arrays
dist = zeros(N,1); % distance of each customer from the origin
ang = zeros(N,1); % angular location of each customer (-pi to pi) 
pos = zeros(N,2); % 

% assign positions to an array
for i=1:N
   tempcust = customers(i);
   dist(i) = norm(tempcust.pos,2);
   ang(i) = atan2(tempcust.pos(2),tempcust.pos(1));
   pos(i,:) = tempcust.pos;
end

if make_plots % plot all customers as * 
   figure, plot(pos(:,1),pos(:,2),'*'), hold on
end

testangle = sort(testangle); % this is crucial 

metrics = zeros(numsects,1);
num_jobs = zeros(numsects,1); 

for i=1:numsects
   
   % Get a mask (bool array) for all customers in current sector 
   if i==numsects 
      sectorindex = (testangle(i)<ang) | (ang<testangle(1)); 
   else
      sectorindex = (testangle(i)<ang) & (ang<testangle(i+1)); 
   end
   
   num_jobs(i) = sum(sectorindex);
   
   % extract position of customers in sector 
   x = pos(sectorindex,1); x = [0;x]';
   y = pos(sectorindex,2); y = [0;y]';
   
   P = [x; y]; % coordinates / points
   c = mean(P,2); % mean/ central point
   d = P-c ; % vectors connecting the central point and the given points
   th = atan2(d(2,:),d(1,:)); % angle above x axis
   [~, idx] = sort(th);   % sorting the angles
   P = P(:,idx); % sorting the given points
   P = [P P(:,1)]; % add the first at the end to close the polygon
   
    
   if make_plots
      plot( P(1,:), P(2,:), '.-r')
   end
   

   [~,n] = size(P);
   for j = 1:n-1
      metrics(i) = metrics(i) + norm(P(:,j)-P(:,j+1),2);
   end
end

nonzeroindices=find(metrics~=0);
perim = metrics(nonzeroindices); % length of the tour 
numworkers = length(perim); 

tour_var = var(perim);

% Add cost based on hiring 
J = J + numworkers*cost_obj.pm;

% Add cost based on traveling 
J = J + sum(perim)*cost_obj.pt;

% Add cost based on overtime 
tour_duration = perim/param_obj.vel + num_jobs(nonzeroindices)*param_obj.mst;
overtime = cost_obj.L*60; % number of hours * 60 min 
J = J + sum( (tour_duration - overtime).*(tour_duration > overtime)*cost_obj.po); 