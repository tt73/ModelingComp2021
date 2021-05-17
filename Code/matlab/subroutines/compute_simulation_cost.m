function [worker_costs] = compute_simulation_cost(workers, customers, cost_obj, show)
pm = cost_obj.pm;
pw = cost_obj.pw;
pi = cost_obj.pi;
pt = cost_obj.pt;
po = cost_obj.po;
ssh = cost_obj.L;

if(nargin==3)
   show = false;
end
M = length(workers);
N = length(customers);

worker_costs = zeros(5,M);

% 1. hire cost
worker_costs(1,:) = pm;

% 2. travel cost
for w = 1:M
   worker_costs(2,w) = workers(w).total_drivetime*pt;
end

% 3. waiting and
% 4. idle cost
for w = 1:M
   wait = 0;
   idle = 0;
   jobs = workers(w).schedule;
   for c = 1:length(jobs)
      diff = customers(c).scheduled_time - customers(c).arrival_time;
      if (~isempty(diff))
         if (diff < 0) % worker arrived too late
            wait = wait - diff;
         else % worker arrived too early
            idle = idle + diff;
         end
      end
   end
   worker_costs(3,w) = wait*pw;
   worker_costs(4,w) = idle*pi;
end

% 5. overtime cost
L = ssh*60;
for w = 1:M
   if (workers(w).end_time > L)
      worker_costs(5,w) = (workers(w).end_time - L)*po;
   end
end


if (show)
   figure
   bar(1:M,worker_costs')
   xlabel('Worker')
   ylabel('Cost')
   title(sprintf('Total Cost: %8.4f',sum(sum(worker_costs))))
   legend('Hire','Travel','Wait','Idle','Over')
end

end

