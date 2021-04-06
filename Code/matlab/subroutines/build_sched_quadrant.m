function [arrival_times, routing] = build_sched_quadrant(customers,vel,AST)
% Compute the time at a worker arrives at a customers' house using the
% average velocity and average service time. 

n = length(customers);
arrival_times = zeros(n,1);
routing = cell(4,1);

positions = [customers.pos];
xpos = positions(1,:) > 0;
ypos = positions(2,:) > 0;
all_tasks = cell(4,1);
worker_pos = zeros(2,4);
all_tasks{1} = find( xpos &  ypos);
all_tasks{2} = find(~xpos &  ypos);
all_tasks{3} = find(~xpos & ~ypos);
all_tasks{4} = find( xpos & ~ypos);

for i = 1:4
   time = 0;
   pos = worker_pos(:,i);
   tasks = all_tasks{i};
   route = [];
   while(~isempty(tasks)) % while array is nonempty
      
      % find the closest customer
      dests = [customers(tasks).pos];
      dists = vecnorm(dests-pos);
      [~, ind] = min(dists); % index of closest customer 
      customer = tasks(ind); % closest customer
      route = [route, customer];
      
      % travel to customer location
      travel = dists(ind)/vel; % time = distance/velocity
      time = time + travel;
      pos = dests(ind);
      arrival_times(customer) = time; % record arrival time
      
      % do the work
      time = time + AST;
      tasks = tasks(tasks~=customer); % delete customer from array
   end
   routing{i} = route;
end

end

