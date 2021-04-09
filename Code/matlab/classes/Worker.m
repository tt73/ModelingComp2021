% Written by Tada
%
% This is a class for a single worker.
% The plan is to make an array of workers.
classdef Worker
   
   properties
      
      % 0 = idle 
      % 1 = driving
      % 2 = waiting at customers house
      % 3 = working
      % 4 = done
      status   
      pos       % [x; y] current position
      curtask   % current task
      curvel    % velocity to next destination (has +/- noise)
      tasks     % indeces of assigned customers
      dest      % [x; y] location of destination
      schedule  % array of appointment times
      
      % statistics 
      drivetime % time spent driving to destination
      waittime  % time spent waiting at customer's house
      worktime  % time spent working on customer
      total_drivetime
      total_waittime
      total_worktime
      end_time  % time that worker returned to base
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
      
      function obj = choose_dest_and_speed(obj,customers,vel)
         assert(obj.status == 0);
         if (~isempty(obj.tasks))
            obj.curtask = obj.tasks(1);
            obj.dest = customers(obj.curtask).pos;
         else
            obj.dest = [0;0]; % go back to base
            obj.curtask = 0; % change task to zero 
         end
         obj.curvel = vel + randn/5; % add some noise to speed
         obj.status = 1;
      end
      
      function [obj,reached] = move(obj,dt) % move to destination
         assert(obj.status==1);
         path = obj.dest - obj.pos; % direction of movement
         d = path/norm(path);    % d = normalized vector
         obj.pos = obj.pos + d*obj.curvel*dt; % new position
         obj.drivetime = obj.drivetime + dt;
         
         reached  = false;
         p = obj.pos - obj.dest;
         norm(obj.dest-obj.pos);
         if (norm(obj.dest-obj.pos)<10e-8)
            reached = true;
         elseif(p(1)/d(1)>0 && p(2)/d(2)>0)
            reached = true;
         elseif(path==0)
            reached = true;
         end
         
         if(reached)
            obj.total_drivetime = obj.total_drivetime + obj.drivetime;
            obj.drivetime = 0;
            if (obj.curtask > 0)
               obj.status = 2; % change status to waiting
            else
               obj.status = 4;
            end
         end
      end
      
      function [obj,ready] = wait(obj,dt,time,scheduled_time) % move to destination
         assert(obj.status == 2);
         
         % just wait until scheduled time is passed
         obj.waittime = obj.waittime + dt;
         if (time >= scheduled_time) 
            ready = true;
         else
            ready = false;
         end
         
         % update status
         if(ready)
            obj.status = 3; % change status to working
            obj.total_waittime = obj.total_waittime + obj.waittime;
            obj.waittime = 0;
         end
      end
      
      function [obj,finished] = work(obj,dt,service_time) % move to destination
         assert(obj.status == 3);
         
         % Do work
         obj.worktime = obj.worktime + dt;
         if (obj.worktime >= service_time)
            finished = true;
         else
            finished = false;
         end
         
         % Update status if done
         if(finished)
            obj.status = 0; % change status to idle
            obj.total_worktime = obj.total_worktime + obj.worktime;
            obj.worktime = 0;
            obj.tasks = obj.tasks(2:end); % just remove 
         end
      end
      
   end
end