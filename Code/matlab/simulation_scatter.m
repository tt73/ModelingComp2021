%%
% Written by Tada

load_settings;

% Option to make video
make_video = false;

%% Choose number of workers
%

num_workers = ceil(num_customers/3);

%% Build the routing plan 
% 
workers = Worker(num_workers);
[arrival_times,routing] = build_sched_scatter(workers,customers,Param);
plot_routing(routing,[customers.pos],gridsize)

%% Determine a schedule buffer time 

dmin = -20;
dmax = 20;
deltas = dmin:5:dmax;
num_runs = 5;
costs = deltas*0;
get_cost =@(d) compute_stochastic_cost(d,workers,customers,Param,Cost,arrival_times,routing);
for i = 1:length(deltas)
   % run a stochastic simulation 
   J = 0;
   for j = 1:num_runs
      J = J + get_cost(deltas(i));
   end
   % save the average cost 
   costs(i) = J/num_runs;
end
[~,ind] = min(costs);
delta = deltas(ind);
fprintf('Optimal buffer time = %f\n',delta)

for i = 1:num_customers
   customers(i).scheduled_time = floor(arrival_times(i)) + delta;
end

%% Begin Computation of cost
%
% This is where the evaluation of the objective function begins. The
% locations of the workers are fixed for a given minimization problem. The
% service times for each customer is also fixed. The key randomness that
% drive this simulation 1) service times 2) travel velocity and 3) customer
% cancellation.

% Simulate cancellation.
cancels = [];
for i = 1:num_customers
   if (rand < Param.c)
      customers(i).status = 4;
      cancels = [cancels, i];
   end
end
disp("cancellations:")
disp(cancels)

% Assign routes.
for i = 1:num_workers
   workers(i).tasks = routing{i}(~ismember(routing{i},cancels));
end

% Initialize movie with a plot
if(make_video)
   figure 
   plot(0,0,'ro','MarkerFaceColor','r')
   set(gca,'nextplot','replacechildren');
   v = VideoWriter('scatter.mp4','MPEG-4');
   set(gcf,'color','w');
   open(v);
end

% Loop variables
t = 0;
dt = .5; % time increment 
simulation_done = false;

while (~simulation_done)
   
   % Assign destination to idle workers.
   % There will be some noise in the speed due to traffic.
   for w = 1:num_workers
      if (workers(w).status == 0)
         workers(w) = choose_dest_and_speed(workers(w),customers,worker_vel);
      end
   end
   
   % Update customers.
   for c = 1:num_customers
      switch customers(c).status
         % Case 0: determine if appointment time has passed
         case 0
            customers(c) = customers(c).check_status(t);
            
         case {1,2,3,4}
            continue % do nothing
      end
   end
   
   % update workers based on status
   for w = 1:num_workers
      c = workers(w).curtask; % c is the current customer of focus
      switch workers(w).status
         
         % Case 1: move until destination is reached
         case 1
            [workers(w),reached] = workers(w).move(dt);
            if (reached)
               if (c > 0)
                  customers(c).arrival_time = t;
               else
                  workers(w).end_time = t;
               end
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
   
   simulation_done = check_workers(num_workers,workers);
   t = t + dt;
   
   if (make_video && mod(t,1)==0)
      % plot HQ - (this will delete the previous plot)
      plot(0,0,'ro','MarkerFaceColor','r')
      plot_customers(num_customers,customers)
      plot_workers(num_workers,workers)

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
   end
end

if(make_video)
   close(v);
end

%% Compute Cost

% call function
[jm, ji, jw, jt, jo] = compute_simulation_cost(workers, customers, Cost, true);
total_cost = jm + ji + jw + jt + jo;
disp(total_cost)