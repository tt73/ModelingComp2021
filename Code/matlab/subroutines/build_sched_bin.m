function [arrival_times, routing] = build_sched_bin(workers,customers,vel,AST)
% Compute the time at a worker arrives at a customers' house using the
% average velocity and average service time. 

m = length(workers);
n = length(customers);
arrival_times = zeros(n,1); % time which customer gets serviced
routing = cell(m,1);
c_pos = [customers.pos]; % 2 by n array of positions


% 
R = vecnorm(c_pos);
angle = zeros(1,n);
for i = 1:n
   if (c_pos(2,i) > 0)
      angle(i) = acosd(c_pos(1,i)/R(i));
   else
      angle(i) = 360 - acosd(c_pos(1,i)/R(i));
   end
end


% Create 
da = 30; 
edges = 0:da:360;
count = histcounts(angle,edges);


end

