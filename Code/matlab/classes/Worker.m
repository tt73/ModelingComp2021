% Written by Tada
%
% This is a class for a single worker.
% The plan is to make an array of workers.
classdef Worker
   
   properties
      pos       % [x; y] current position
      status    % 0 = idle, 1 = driving, 2 = waiting, 3 = working
      drivetime % time spent driving to destination
      waittime  % time spent waiting at customer's house
      worktime  % time spent working on customer
      curtask   % current task
      tasks     % indeces of assigned customers
      dest      % [x; y] location of destination
      total_drivetime
      total_waittime
      total_worktime
   end
   
   methods
      function obj = Worker(n) % constructor
         obj.pos = [0;0];
         obj.status = 0;
         obj.worktime = 0;
         obj.drivetime = 0;
         obj.waittime = 0;
         obj.total_drivetime = 0;
         obj.total_worktime = 0;
         obj.total_waittime = 0;
         if(nargin==1)
            obj(1,n) = obj;
         end
      end
      
      function obj = choose_dest(obj,customers)
         assert(obj.status == 0);
         if (~isempty(obj.tasks))
            dests = [customers(obj.tasks).pos];
            dists = vecnorm(dests-obj.pos);
            [val, ind] = min(dists);
            obj.dest = dests(:,ind);
            obj.curtask = obj.tasks(ind);
            obj.status = 1;
         end
      end
      
      function obj = move(obj,vel,dt) % move to destination
         assert(obj.status==1);
         d = obj.dest - obj.pos; % direction of movement
         d = d/norm(d);    % normalize
         obj.pos = obj.pos + d*vel*dt; % new position
         obj.drivetime = obj.drivetime + dt;
         
         reached  = false;
         p = obj.pos - obj.dest;
         norm(obj.dest-obj.pos);
         if (norm(obj.dest-obj.pos)<10e-8)
            reached = true;
         elseif(p(1)/d(1)>0 && p(2)/d(2)>0)
            reached = true;
         end
         
         if(reached)
            obj.status = 2; % change status to waiting
            obj.total_drivetime = obj.total_drivetime + obj.drivetime;
            obj.drivetime = 0;
         end
      end
      
      function obj = wait(obj,dt,customers) % move to destination
         assert(obj.status == 2);
         
         % need to fix this later
         ready = true;
         
         if(ready)
            obj.status = 3; % change status to working
            obj.total_waittime = obj.total_waittime + obj.waittime;
            obj.waittime = 0;
         end
      end
      
      function obj = work(obj,dt,customers) % move to destination
         assert(obj.status == 3);
         
         % need to fix this later
         finished = true;
         
         if(finished)
            obj.status = 0; % change status to idle
            obj.total_worktime = obj.total_worktime + obj.worktime;
            obj.worktime = 0;
            obj.tasks = obj.tasks(obj.tasks~= obj.curtask);
         end
      end
      
   end
end