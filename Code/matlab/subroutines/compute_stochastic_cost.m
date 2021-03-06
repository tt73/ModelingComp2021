function cost = compute_stochastic_cost(deltas,workers,customers,param_obj,cost_obj,arrival_times,routing)
% need to fix this 
% the service time for each customer should be regenerated each instance

tic
cost = inf;

num_workers = length(workers);
vel = param_obj.vel;

% schdule a time with buffer 
num_customers = length(customers);
for i = 1:num_customers
   customers(i).scheduled_time = max(floor(arrival_times(i)) + deltas(i),0);
end

% generate random service time for each customer
for i = 1:num_customers
   customers(i).service_time = normrnd(param_obj.mst,param_obj.std); % N(mst,std) 
end

% Simulate cancellation.
cancels = [];
for i = 1:num_customers
   if (rand < param_obj.c)
      customers(i).status = 4;
      cancels = [cancels, i];
   end
end

% Assign routes.
for i = 1:num_workers
   workers(i).tasks = routing{i}(~ismember(routing{i},cancels));
end

% Loop variables
t = 0;
dt = 2.0; % time increment 
simulation_done = false;

while (~simulation_done)
   
   % Assign destination to idle workers.
   % There will be some noise in the speed due to traffic.
   for w = 1:num_workers
      if (workers(w).status == 0)
         workers(w) = choose_dest_and_speed(workers(w),customers,vel);
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
         case 4
            % nothing
      end
   end
   
   simulation_done = check_workers(num_workers,workers);
   t = t + dt;
   
   if (t > 6000) 
      warning('Might be stuck in inf loop in compute_stochastic_cost')
   end
end

[worker_cost] = compute_simulation_cost(workers, customers, cost_obj);

cost = sum(sum(worker_cost));
end

