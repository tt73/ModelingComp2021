function [arrival_times, routing] = build_sched_DE(sector_angles,workers,customers,param_obj)

l = length(sector_angles);
m = length(workers);
n = length(customers);

arrival_times = zeros(n,1);
routing = cell(m,1);

pos = [customers.pos]; % size 2 by n a
ang = atan2(pos(1,:),pos(2,:));



for i = 1:l
   
   % Get a mask (bool array) for all customers in current sector
   if i==l
      % last sector
      sectorindex = (sector_angles(i)<ang) | (ang<sector_angles(1)); 
   else
      % all other sectors
      sectorindex = (sector_angles(i)<ang) & (ang<sector_angles(i+1)); 
   end
   
   
   
   
   
end


end

