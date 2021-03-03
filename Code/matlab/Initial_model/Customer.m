% Written by Tada
%
% This is a class for a single customer.
% The plan is to make an array of customers.
classdef Customer
   
   properties
      pos    % 2 by 1 column x,y position
      status % 0 = unscheduled, 1 = scheduled, 2 = serviced
      time   % time 
   end
   
   methods
      function obj = Customer(gridsize,t) % this is  constructor
         
         % this is only for the initial model
         if (nargin ==2)
            obj.time = t;
            obj.status = 0;
            obj.pos = 2*gridsize*rand(2,1)-gridsize;
         end
         
         % just feed in gridsize 
         if (nargin == 1) 
            obj.status = 0;
            obj.pos = 2*gridsize*rand(2,1)-gridsize;
         end
      end
      

   end
end