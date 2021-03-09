% Written by Tada
%
% This is a class for a single customer.
% The plan is to make an array of customers.
classdef Customer
   
   properties
      pos    % 2 by 1 column x,y position
      status % 0 = unserviced,
      % 1 = unserviced and waiting for late worker,
      % 2 = being serviced,
      % 3 = serviced,
      % 4 = canceled
      service_time % time required to finish in minutes
      scheduled_time
      arrival_time % time at which worker has arrived
      time_waited
   end
   
   methods
      function obj = Customer(gridsize,n,tmin,tmax) % this is  constructor
         if (nargin ~= 0)
            obj(1,n) = obj;
            for i = 1:n
               obj(i).status = 0;
               obj(i).pos = gridsize*rand(2,1)-gridsize/2;
               obj(i).service_time = rand*(tmax-tmin)+tmin; %U(tmin,tmax)
            end
         end
      end
      
      function obj = check_sched(obj,current_time)
         assert(obj.status == 0)
         if (current_time >= obj.scheduled_time)
            obj.status = 1;
         end
      end
      
      function obj = wait(obj,dt)
         assert(obj.status == 1)
         obj.time_waited = obj.time_waited + dt;
      end
   end
end

