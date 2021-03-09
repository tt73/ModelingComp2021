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
num_customers = 20;
tmin = 30;
tmax = 60;
% tmin = 2;
% tmax = 5;
customers = Customer(gridsize,num_customers,tmin,tmax);

% workers
num_workers = 4;
workers = Worker(num_workers);

% compute average arrival times for each customer


% build a schedule
ast = (tmin+tmax)/2;
[arrival_times,routing] = build_sched_quadrant(customers,vel,ast);
for i = 1:num_customers
   customers(i).scheduled_time = floor(arrival_times(i));
end

% simulate cancellation
chance = 0.05;
cancels = [];
for i = 1:num_customers
   if (rand < chance)
      customers(i).status = 4;
      cancels = [cancels, i];
   end
end
disp("cancellations:")
disp(cancels)


% assign the routing
for i = 1:4
   workers(i).tasks = routing{i}(~ismember(routing{i},cancels));
end

% Loop variables
t = 0;
dt = 1;  % miniutes
simulation_done = false;

% Initialize movie with a graph
plot(0,0,'ro','MarkerFaceColor','r')
set(gca,'nextplot','replacechildren');
v = VideoWriter('basic1.mp4','MPEG-4');
set(gcf,'color','w');
open(v);

while (~simulation_done)
   
   % Assign destination to idle workers.
   % There will be some noise in the speed due to traffic.
   for w = 1:num_workers
      if (workers(w).status == 0)
         workers(w) = workers(w).choose_dest_and_speed(customers,vel);
      end
   end
   
   % Update customers.
   for c = 1:num_customers
      switch customers(c).status
         
         case 2
            continue % do nothing
            
         case 3
            continue % do nothing
            
         case 4
            continue % do nothing
         
         % Case 0: determine if appointment time has passed
         case 0
            customers(c) = customers(c).check_sched(t);
            
         % Case 1: keep track of time spent waiting
         case 1
            customers(c) = customers(c).wait(dt);
     
      end
   end
   
   % update workers based on status
   for w = 1:num_workers
      c = workers(w).curtask; % c is the current customer of focus
      switch workers(w).status
         
         % Case 1: move until destination is reached
         case 1
            [workers(w),reached] = workers(w).move(dt);
            if (reached && c>0)
               customers(c).arrival_time = t;
            end
            
         % Case 2: wait until scheduled time is passed
         case 2
            [workers(w),ready] = workers(w).wait(dt,t,customers(c).scheduled_time);
            if (ready)
               customers(c).status = 2;
            end
            
         % Case 3: work until the job is done
         case 3
            [workers(w),finished] = workers(w).work(dt,customers(c).service_time);
            if (finished)
               customers(workers(w).curtask).status = 3;
            end
      end
   end
   
   
   % plot HQ - (this will delete the previous plot)
   plot(0,0,'ro','MarkerFaceColor','r')
   plot_customers(num_customers,customers)
   plot_workers(num_workers,workers)
   
   simulation_done = check_workers(num_workers,workers);
   
   % take the plot, and save it
   title(sprintf('Time = %.3f (min)',t))
   axis([-gridsize/2, gridsize/2, -gridsize/2, gridsize/2])
   axis('square')
   set(gcf,'position',[0,0,800,750])
   set(gcf,'color','w');
   set(gca,'color',[.4 .4 .4]);
   xlabel('x (km)')
   ylabel('y (km)')
   frame = getframe(gcf);
   writeVideo(v,frame);
   
   t = t + dt;
end

close(v);


%% Print out statistics
appointment_times = [customers.scheduled_time];
arrival_times = [customers.arrival_time];
figure 
plot(1:num_customers,appointment_times,'b-','LineWidth',2')
hold on
for i = 1:num_customers
   
   plot([i,i],[appointment_times(i),arrival_times(i)],'r--')
   
end





