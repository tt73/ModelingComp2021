function [arrival_times, routing] = build_sched_scatter(workers,customers,param_obj)
% Compute the time at a worker arrives at a customers' house using the
% average velocity and average service time. 

m = length(workers);
n = length(customers);
arrival_times = zeros(n,1); % time which customer gets serviced
accounted = zeros(n,1);
routing = cell(m,1);
c_pos = [customers.pos]; % 2 by n array of positions

t = 0;
dt = 1;
while (~all(arrival_times))
   
   % assign a job to workers among customers unaccounted for
   if(~all(accounted))
      for w = 1:m
         if (workers(w).status == 0)
            dists = vecnorm(c_pos-workers(w).pos);
            [~, ind] = min(dists);
            workers(w).dest = c_pos(:,ind);
            workers(w).curtask = ind;
            accounted(ind) = 1;
            workers(w).curvel = param_obj.vel;
            workers(w).status = 1;
            c_pos(:,ind) = inf;
            routing{w} = [routing{w}, ind];
         end
      end
   end
   
   % update workers based on status
   for w = 1:m
      c = workers(w).curtask; % c is the current customer of focus
      switch workers(w).status
         
         % Case 1: move until destination is reached
         case 1
            [workers(w),reached] = workers(w).move(dt);
            if (reached)
               arrival_times(c) = t; % track arrival time
            end
            
         % Case 2: no waiting, immediately start working
         case 2
            workers(w).status = 3;
            
         % Case 3: work for average service time (AST) minutes
         case 3
            workers(w).worktime = workers(w).worktime + dt;
            if (workers(w).worktime >= param_obj.mst)
               workers(w).status = 0;
               workers(w).worktime = 0;
            end
      end
   end
   t = t + dt;
   if (t > 10000)
      warning('possible infinite loop')
   end
end

end

