%% Add functions in folders to path
addpath('subroutines')
addpath('classes')
clear

%% Define parameters

% total widgh of simulation square grid
gridsize = 50; % km

% average speed of workers on the road
vel = 1; % km/min

% Cost parameters
worker_hire_cost = 100;       % pm  
customer_wait_rate = rand*10; % pw
worker_idle_rate = rand*5;    % pi 
worker_travel_rate = 1;     % pt 
worker_OT_rate = 1.5*worker_idle_rate; % po
standard_service_hours = 8; %time when overtime hours begin

%% Generate Customers

% customer parameters
num_customers = 30;  % number of customers

% service time is random normal
tmin = 30;  % min job duration
tmax = 60;  % max job duration
mst = (tmax-tmin)*rand + tmin; % mean service time
sd = mst/2; % standard deviation of service time

% cancel probability 
chance = 0.05;

% generate an array of workers
customers = Customer(gridsize,num_customers,mst,sd);
