%%
% Written by Tada
% This little script creates a video of the quadrant model.
% All it does is show a simulation of workers moving from customer to
% customer until everyone is serviced.

%% Assumptions about customers
% There are N customers and all of their locations are uniformly generated
% and their posistions are known. They don't have a scheduled time, so they
% welcome the workers as soon as they arrive. The time it takes to complete
% a service is instantaneous. Furthermore, they never randomly cancel their
% appointment.

%% Assumption about workers
% There are only 4. They all have contant velocity and ignore randomness of
% traffic. They are assigned the customers in their quadrant. Starting from
% the origin (0,0), they move to the closest customer in their list. Once
% there, the workers immediately switch from waiting to working, and then
% immediatly change from working to finished. The workers check off the
% customer from their list of tasks and then moves on the closest customer
% still on their list. When they finish their task, they do nothing.

%% Code
addpath('subroutines')
addpath('classes')
clear


gridsize = 50; % km
vel = 1;       % km/min

% customers
num_customers = 40;
customers = Customer(gridsize,num_customers,30,60);

% workers
num_workers = 4;
workers = Worker(num_workers);

% assign customers to workers
positions = [customers.pos];
xpos = positions(1,:) > 0;
ypos = positions(2,:) > 0;
workers(1).tasks = find( xpos &  ypos);
workers(2).tasks = find(~xpos &  ypos);
workers(3).tasks = find(~xpos & ~ypos);
workers(4).tasks = find( xpos & ~ypos);

% disp(workers(1).tasks)
% disp(workers(2).tasks)
% disp(workers(3).tasks)
% disp(workers(4).tasks)

% Initialize movie with a graph
plot(0,0,'ro')
set(gca,'nextplot','replacechildren');
v = VideoWriter('basic1.mp4','MPEG-4');
open(v);


t = 0;
dt = 0.5;  % miniutes 
simulation_done = false;

while (~simulation_done)
   
   % assign destination to idle workers
   for w = 1:num_workers
      if (workers(w).status == 0)
         workers(w) = workers(w).choose_dest(customers);
      end
   end
   
   % update workers based on status
   for w = 1:num_workers
      switch workers(w).status
         case 1
            workers(w) = workers(w).move(vel,dt);
         case 2
            workers(w) = workers(w).wait(dt,customers);
         case 3
            workers(w) = workers(w).work(dt,customers);
            customers(workers(w).curtask).status = 1;
      end
   end
   
      
   % plot HQ - (this will delete the previous plot)
   plot(0,0,'ro')
   plot_customers(num_customers,customers)
   
   for i = 1:num_workers
      plot(workers(i).pos(1),workers(i).pos(2),'bs')
   end
   hold off
   
   simulation_done = check_customers(num_customers,customers);
   
   % take the plot, and save it
   title(sprintf('Time = %.3f (min)',t))
   axis([-gridsize/2, gridsize/2, -gridsize/2, gridsize/2])
   xlabel('x (km)')
   ylabel('y (km)')
   frame = getframe(gcf);
   writeVideo(v,frame);
   
   t = t + dt;
end
 
close(v);


