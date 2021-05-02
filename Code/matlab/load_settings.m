%% Add functions in folders to path
addpath('subroutines')
addpath('classes')
clear

%% Define parameters

% fix seed for rng
seed = 9;
rng(seed)

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
worker_hire_cost = 100;       % pm  
customer_wait_rate = rand*10; % pw
worker_idle_rate = rand*5;    % pi 
worker_travel_rate = 1;       % pt 
worker_OT_rate = 1.5*worker_idle_rate; % po

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
num_customers = 30;  % number of customers

% generate an array of customers 
customers = Customer(gridsize,num_customers);

% generate random service time for each customer
for i = 1:num_customers
   customers(i).service_time = normrnd(Param.mst,Param.std); % N(mst,std) 
end

%% Simulate cancellation.
cancels = [];
for i = 1:num_customers
   if (rand < Param.c)
      customers(i).status = 4;
      cancels = [cancels, i];
   end
end
disp("cancellations:")
disp(cancels)