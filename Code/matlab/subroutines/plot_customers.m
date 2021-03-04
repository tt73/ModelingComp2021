%% 
% Written by Tada 
% 

function [] = plot_customers(num_customers,customers)
% This function just plots all the customers locations on an existing 
% figure. It color-codes the customers based on their status. 

   hold on
   for i = 1:num_customers
      switch customers(i).status
         case 0
            marker = 'g.';
         case 1
            marker = 'y.';
         case 2
            marker = 'b.';
         case 3
            marker = 'r.';
      end
      plot(customers(i).pos(1),customers(i).pos(2),marker,'markersize',10)
      text(customers(i).pos(1),customers(i).pos(2),num2str(i))
   end
end

