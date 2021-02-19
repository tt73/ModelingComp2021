% Written by Tada
%
% This is a class for a single worker.
% The plan is to make an array of workers.
classdef Worker
   
   properties
      pos      % 2 by 1 column x,y position
      status   % 0 = unscheduled, 1 = scheduled, 2 = serviced
      task     % index of customer that worker is assigned to
      worktime % time spent working on customer
   end
   
   methods
      function obj = Worker % constructor
         obj.pos = [0;0];
         obj.status = 0;
         obj.task = 0;
         obj.worktime = 0;
      end
      
      function obj = move(obj,dest,vel,dt) % move from point A to B
         start = obj.pos;
         d = dest - start; % direction of movement
         d = d/norm(d);    % normalize 
         obj.pos = obj.pos + d*vel*dt; % new position
         
         reached  = false;
         p = obj.pos - dest;
         norm(dest-obj.pos)
         if (norm(dest-obj.pos)<10e-8)
            reached = true;
         elseif(p(1)/d(1)>0 && p(2)/d(2)>0)
            reached = true;
         end
         
         if(reached)
            if (obj.status==1)
               obj.status = 2;
            elseif(obj.status==3)
               obj.status = 0;
            end
         end
      end
      
      
   end
end