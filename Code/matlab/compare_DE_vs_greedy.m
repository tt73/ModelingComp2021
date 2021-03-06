%% compare deterministic cost of routing schemes 

%% Add functions in folders to path
addpath('subroutines')
addpath('classes')
clear
close all

%% Define parameters

% fix seed for rng
seed = 1969;
% rng(seed)

% total widgh of simulation square grid
gridsize = 50; % km

% average speed of workers on the road
worker_vel = 1; % km/min

% service time is random normal
min_service_time = 30;  % min job duration
max_service_time = 60;  % max job duration
mean_service_time = (max_service_time-min_service_time)*rand + min_service_time; % mean service time
std_service_time = mean_service_time/2; % standard deviation of service time

% Time when overtime hours begin
standard_service_hours = rand*2+6; % 6 to 8 hours 

% Probability that a customer cancels his appointment after the appiontment was made 
cancel_prob = 0.05;

% Cost parameters
worker_hire_cost = 150;       % pm  
customer_wait_rate = rand*10; % pw
worker_idle_rate = rand*5;    % pi 
worker_travel_rate = 2;       % pt 
worker_OT_rate = 1.5*worker_idle_rate; % po

fprintf('Hire Cost   = %.3f\n',worker_hire_cost)
fprintf('Wait Cost   = %.3f\n',customer_wait_rate)
fprintf('Idle Cost   = %.3f\n',worker_idle_rate)
fprintf('OT Cost     = %.3f\n',worker_OT_rate)
fprintf('Serv. hours = %.3f\n',standard_service_hours)

%% Create objects
%
% Group variables into objects to make subroutine calling easier.  

% paramter object 
Param.vel = worker_vel;
Param.gs = gridsize;
Param.mst = mean_service_time;
Param.std = std_service_time;
Param.c = cancel_prob;

% cost object 
Cost.pm = worker_hire_cost;
Cost.pw = customer_wait_rate;
Cost.pi = worker_idle_rate;
Cost.pt = worker_travel_rate;
Cost.po = worker_OT_rate;
Cost.L = standard_service_hours;

%% Generate Customers

% customer parameters
choices = [20, 30, 40, 50];
num_customers = choices(2);  % number of customers

% generate an array of customers 
customers = Customer(gridsize,num_customers);

% generate random service time for each customer
for i = 1:num_customers
   customers(i).service_time = normrnd(Param.mst,Param.std); % N(mst,std) 
end

fprintf('Num customers = %d\n',num_customers);

%% customer range
minND = floor(num_customers/8); 
maxND = floor(num_customers*2/3);

fprintf('Customer sweep range: %d to %d\n',minND,maxND)

ND = 7;

%% Choose parmeter

w = 0.3;
fprintf('Parameter w: %f\n',w)

%% Choose routing for greedy 

nws = minND:maxND;
dcosts = nws*0;
vcosts = nws*0;
for i = 1:length(nws)
   workers = Worker(nws(i));
   [~,greedy_routing] = build_sched_scatter(workers,customers,Param);
   [dcosts(i),vcosts(i)] = compute_deterministic_cost(greedy_routing, customers, Param, Cost);
end
nvcosts = vcosts/norm(vcosts);
ndcosts = dcosts/norm(dcosts);

wcosts = w*nvcosts + (1-w)*ndcosts;
[~,ind] = min(wcosts);
num_workers = nws(ind);
% num_workers = ND;
workers = Worker(num_workers);
[~,greedy_routing] = build_sched_scatter(workers,customers,Param);
plot_routing(greedy_routing,[customers.pos],Param,Cost)
fprintf('Greedy Cost = %10.4f\n',dcosts(ind))



%% Choose routing for DE 
finalist = DetermineSectors(customers,minND,maxND,w,Param,Cost); 
% finalist = DetermineSectors(customers,ND,ND,w,Param,Cost); 
[~,de_routing,~] = build_sched_DE(finalist,customers,Param);
plot_routing(de_routing,[customers.pos],Param,Cost)
[dc,~] = compute_deterministic_cost(de_routing, customers, Param, Cost);
fprintf('DE Cost     = %10.4f\n',dc)