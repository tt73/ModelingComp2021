%%
% Written by Tada
%
% This is the simulation which uses the greedy algorithm to generate the
% routing. 

load_settings;

% Option to make video
make_video = false;

%% Find optimal number of workers
% 
min_nw = floor(num_customers/8); 
max_nw = floor(num_customers*2/3);
nws = min_nw:max_nw;
dcosts = nws*0;
vcosts = nws*0;
for i = 1:length(nws)
   workers = Worker(nws(i));
   [~,routing] = build_sched_scatter(workers,customers,Param);
   [dcosts(i),vcosts(i)] = compute_deterministic_cost(routing, customers, Param, Cost);
end
w = 0.7;
wcosts = w*vcosts + (1-w)*dcosts;
[~,ind] = min(wcosts);
num_workers = nws(ind);
workers = Worker(num_workers);
[arrival_times,routing] = build_sched_scatter(workers,customers,Param);
plot_routing(routing,[customers.pos],Param,Cost)

%% Determine a schedule buffer time 

num_runs = 30; % choose high num_runs if cancellation rate is high   

% searches for buffer times in the initial interval [-l,l]
l = Param.mst*ones(num_customers,1)/2;

% gets the stochastic scheduling cost
J = @(d)getSchedulingCost(d,workers,customers,...
    Param,Cost,arrival_times,routing,num_runs);

% sets the relevant Diffevo parameters
DEparams.ND = num_customers;    % dimension of input
DEparams.CR = 0.9;  % mutation probability (0,1) 
DEparams.F = 0.8;   % mutation strength (0,2) 
DEparams.NP = 8;   % num_customers*10;   % pop size
DEparams.Nmax = 5; % number of evolutions 

% the final generation of optimal deltas
%    delta = zeros(num_customers,1);
[pop,costs] = diffevoDelta(J,l,DEparams,Cost);
[~,ind] = min(costs);
delta = pop(:,ind);

%% Give out the appointment 

for i = 1:num_customers
   customers(i).scheduled_time = max(floor(arrival_times(i)) + delta(i),0);
end

%% Assign routes.
for i = 1:num_workers
   workers(i).tasks = routing{i}(~ismember(routing{i},cancels));
end

%% Run the simulation
run_simulation

%% Compute Cost
% call function
[jm, ji, jw, jt, jo] = compute_simulation_cost(workers, customers, Cost, true);
total_cost = jm + ji + jw + jt + jo;
fprintf('Total Cost = %10.2f\n',total_cost)