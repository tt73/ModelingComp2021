% Written by Tada
%
% This is a class for a single customer.
% The plan is to make an array of customers.
classdef Customer
   
   properties
      time % time that customer makes a call to HQ
      pos % 2 by 1 column x,y position
      status % 0 = unscheduled, 1 = scheduled, 2 = serviced
   end
   
   methods
      
      function obj = Customer(t,gridsize) % this is  constructor
         
         obj.time = t;
         obj.status = 0;
         obj.pos = 2*gridsize*rand(2,1)-gridsize;
         
      end
      
   end
end