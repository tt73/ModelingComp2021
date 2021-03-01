% Written by Tada
%
% This is a class for a single customer.
% The plan is to make an array of customers.
classdef Customer
   
   properties
      pos    % 2 by 1 column x,y position
      status % 0 = unserviced, 1 = serviced, 2 = canceled 
   end
   
   methods
      function obj = Customer(gridsize,n) % this is  constructor    
         if (nargin ~= 0)
            obj(1,n) = obj;    
            for i = 1:n
               obj(i).status = 0;
               obj(i).pos = gridsize*rand(2,1)-gridsize/2;
            end
         end
      end
   end
end