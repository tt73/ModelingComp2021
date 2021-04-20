function [arrival_times, routing, num_workers] = build_sched_DE(sector_angles,customers,param_obj)

num_sec = length(sector_angles);
num_cus = length(customers);

arrival_times = zeros(num_cus,1);
routing = cell(num_sec,1);

pos = [customers.pos]; % size 2 by n a
ang = atan2(pos(2,:),pos(1,:));

fullID = 1:num_cus;
sector_angles = sort(sector_angles);

% loop to compute
worker_ID = 1;
for i = 1:num_sec
   % Get a mask (bool array) for all customers in current sector
   if i==num_sec
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
   routing{worker_ID} = ordered;
   worker_ID = worker_ID + 1;
end

% set the number of workers to the final worker index 
num_workers = worker_ID-1;

% delete cells if 
if (num_sec > num_workers)
   routing(num_workers+1:end) = []; 
end

% loop to compute arrival times
for i = 1:num_workers
   
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

