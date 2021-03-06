function [arrival_times, routing] = build_sched_bin(workers,customers,vel,AST)
% Compute the time at a worker arrives at a customers' house using the
% average velocity and average service time. 

m = length(workers);
n = length(customers);
arrival_times = zeros(n,1); % time which customer gets serviced
routing = cell(m,1);
c_pos = [customers.pos]; % 2 by n array of positions


% Get the angular position of each customer
R = vecnorm(c_pos); % radius 
angle = zeros(1,n);
for i = 1:n
   if (c_pos(2,i) > 0)
      angle(i) = acosd(c_pos(1,i)/R(i));
   else
      angle(i) = 360 - acosd(c_pos(1,i)/R(i));
   end
end


% Create a bin, and do a count for each bin. 
da = 30; 
edges = 0:da:360;
count = histcounts(angle,edges);

% Figure out a way to distribute m workers 

% For each non empty bin ... 
%    Simulate workers moving from customer to customer based on proximity
%    Keep track of which worker moves to which customers
%    Keep track of the time at which the workers arrive 

end

