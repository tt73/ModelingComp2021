%% Add functions in folders to path
addpath('subroutines')
addpath('classes')
clear

%% Define parameters

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
standard_service_hours = 8; 

% Probability that a customer cancels his appointment after the appiontment was made 
cancel_prob = 0.05;

% Cost parameters
worker_hire_cost = 100;       % pm  
customer_wait_rate = rand*10; % pw
worker_idle_rate = rand*5;    % pi 
worker_travel_rate = 1;     % pt 
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

% generate an array of workers
customers = Customer(gridsize,num_customers,mean_service_time,std_service_time);
