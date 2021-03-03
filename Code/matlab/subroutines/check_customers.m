%%
% Written by Tada
%

function [done] = check_customers(num_customers,customers)
% This function checks the status of all customers and 
% determines if the simulation is done. 

done = true;

for i = 1:num_customers
   if (customers(i).status == 0)
      done = false;
      break;
      % Status 0 means customer still hasn't been serviced
      % Thus, simulation is not done. 
   end
end
end

