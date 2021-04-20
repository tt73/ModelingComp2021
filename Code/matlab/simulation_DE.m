%%
% Written by Tada, Jimmie 
%
% This is the simulation which uses the differential evolution to compute
% the optimal routing and number of workers at the same time. 

load_settings;

% Option to make video
make_video = false;

%% Choose number of workers and the routing 

minND = floor(num_customers/5); 
maxND = floor(num_customers*3/4);
N_best = 10;
w = 0.5; % 0 < w < 1, 
finalists = DetermineSectors(customers,minND,maxND,w,Param,Cost,N_best);

% plot the N best sector results
for i = 1:N_best
   figure(i)
   [~,routing,~] = build_sched_DE(finalists{i},customers,Param);
   plot_routing(routing,[customers.pos],gridsize)
end

%% Build a schedule (appointment for customers) specifically for the
% quadrant model. The appointment times are chosen to be the average
% arrival time of the workers assuming nobody cancels.


% Generate array of workers.
[arrival_times,routing,num_workers] = build_sched_DE(finalists{1},customers,Param);
workers = Worker(num_workers);

%% Find buffer time
% 
num_runs = 30; % choose high num_runs if cancellation rate is high   

% searches for buffer times in the initial interval [-l,l]
l = Param.mst*ones(num_customers,1)/2;

% gets the stochastic scheduling cost
J = @(d)getSchedulingCost(d,workers,customers,...
    Param,Cost,arrival_times,routing,num_runs);

% sets the relevant Diffevo parameters
DEparams.ND = num_customers;    % dimension of input
DEparams.CR = 0.8;  % mutation probability (0,1) 
DEparams.F = 0.6;   % mutation strength (0,2) 
DEparams.NP = 10;   % pop size
DEparams.Nmax = 10; % number of evolutions 

% the final generation of optimal deltas
[pop,costs] = diffevoDelta(J,l,DEparams);
[~,ind] = min(costs);
delta = pop(:,ind);
fprintf('Optimal buffer time = %6.2f min\n',delta)
% delta = zeros(num_customers,1);

%% Give out the appointment 

for i = 1:num_customers
   customers(i).scheduled_time = max(floor(arrival_times(i)) + delta(i),0);
end

%% Assign routes.
for i = 1:num_workers
   workers(i).tasks = routing{i}(~ismember(routing{i},cancels));
end

%% Simulation 

% Initialize movie with a plot
if(make_video)
   figure
   plot(0,0,'ro','MarkerFaceColor','r')
   set(gca,'nextplot','replacechildren');
   v = VideoWriter('DE.mp4','MPEG-4');
   set(gcf,'color','w');
   open(v);
end

t = 0;
dt = .5; % time increment 
simulation_done = false;

while (~simulation_done)
   
   % Assign destination to idle workers.
   % There will be some noise in the speed due to traffic.
   for w = 1:num_workers
      if (workers(w).status == 0)
         %          workers(w) = workers(w).choose_dest_and_speed(customers,vel);
         workers(w) = choose_dest_and_speed(workers(w),customers,Param.vel);
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
fprintf('Total Cost = %10.2f\n',total_cost)