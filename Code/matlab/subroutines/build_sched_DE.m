function [arrival_times, routing] = build_sched_DE(sector_angles,workers,customers,param_obj)

l = length(sector_angles);
m = length(workers);
n = length(customers);

arrival_times = zeros(n,1);
routing = cell(m,1);

pos = [customers.pos]; % size 2 by n a
ang = atan2(pos(2,:),pos(1,:));

fullID = 1:n;
sector_angles = sort(sector_angles);

% loop to compute
workID = 1;
for i = 1:l
   % Get a mask (bool array) for all customers in current sector
   if i==l
      % last sector
      sectorindex = (sector_angles(i)<ang) | (ang<sector_angles(1)); 
   else
      % all other sectors
      sectorindex = (sector_angles(i)<ang) & (ang<sector_angles(i+1)); 
   end
   
   % index of customers in the sector
   localID = fullID(sectorindex);
   
   % skip empty sectors
   num_points = sum(sectorindex);
   if (num_points==0)
      continue
   end
   
   % calculate central pivot point
   P = [[0;0], pos(:,sectorindex)];
   piv = mean(P,2);
   d = P-piv;
   th = atan2(d(2,:),d(1,:));
   [~, idx] = sort(th);   % sorting the angles
   shift = -find(idx==1)+1;  % circular shift index
   idxs = circshift(idx,shift);
   P = P(:,circshift(idx,shift));
   
   % Save the ordered index of customers
   ordered = localID(idxs(2:end)-1);
   routing{workID} = ordered;
   workID = workID + 1;
end

% loop to compute arrival times
for i = 1:m
   
   time = 0;    % current time 
   loc = [0;0]; % current location of worker 
   tasks = routing{i}; % indeces of customers designated for worker 
   num_tasks = length(tasks); 
   
   for j = 1:num_tasks
 
      customer = tasks(j); 
      
      % travel to customer location
      dist = norm(loc-pos(:,customer)); 
      travel = dist/param_obj.vel; % travel time = distance/velocity
      time = time + travel;
      loc = pos(:,customer); % update location of worker 
      arrival_times(customer) = time; % record arrival time
      
      % do the work
      time = time + param_obj.mst;
   end
   
end


end

