function J=getSchedulingCost(d,workers,customers,Param,Cost,arrival_times,routing,num_runs)
get_cost =@(x) compute_stochastic_cost(x,workers,customers,Param,Cost,arrival_times,routing);
   % run a stochastic simulation 
   J = 0;
   for j = 1:num_runs
      J = J + get_cost(d);
   end
   % save the average cost
   J = J/num_runs;