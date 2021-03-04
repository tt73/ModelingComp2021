%%
% Written by Tada
%

function [done] = check_workers(num_workers,workers)
% This function checks the status of all customers and 
% determines if the simulation is done. 

done = true;

for i = 1:num_workers
   if (workers(i).status ~= 4)
      done = false;
      break;
      % Status 0 means customer still hasn't been serviced
      % Thus, simulation is not done. 
   end
end
end

