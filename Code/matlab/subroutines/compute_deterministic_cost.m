function J = compute_deterministic_cost(routing, customers, vel, mst, pm, pt, po, L)
% routing    = (num_workers,1) cell of arrays containing indeces of customers
% customers  = (num_customers,1) array of customers 
% vel        = (scalar) speed (km/min) of worker
% mst        = (scalar) mean service time (min) of a job
% pm         = (scalar) cost to hire one worker
% pt         = (scalar) cost per km of traveling
% po         = (scalar) cost per min for overtime 
% L          = (scalar) number of hours in a workday 

m = length(routing);
pos = [customers.pos];

% compute length and duration of each tour 
tour_distance = zeros(m,1);
tour_duration = zeros(m,1);

for i = 1:m
   % Create a list of all coordinates visited by the worker.
   % It begins and ends at the origin. 
   coords = [[0;0], pos(:,routing{i}), [0;0]];
   
   % Compute paths (vectors) connecting each node along the tour.   
   paths = coords(:,2:end) - coords(:,1:end-1);
   
   % Compute the lengths of each path.  
   dists = vecnorm(paths);
   
   % This is the total length (km) traveled from HQ and back. 
   tour_distance(i) = sum(dists);
   
   % This is the total time duration (min) of the tour. 
   travel_time = tour_distance(i)/vel;
   service_time = mst*numel(routing{i});
   tour_duration(i) = tour_duration(i) + travel_time + service_time;
end

Jm = m*pm;                  % hire cost 
Jt = sum(tour_distance)*pt; % travel cost
Jo = sum((tour_duration>L*60).*(tour_duration-L*60))*po; % OT cost 

J = Jm + Jt + Jo;