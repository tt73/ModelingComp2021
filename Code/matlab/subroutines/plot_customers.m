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
         mk = '.';
         c = 'g';
      case 1
         mk = '.';
         c = 'y';
         str = "apt: "+num2str(customers(i).scheduled_time);
         text(customers(i).pos(1),customers(i).pos(2),str,'color','y')
      case 2
         mk = '.';
         c = [0.9290 0.6940 0.1250];
      case 3
         mk = '.';
         c = 'b';
      case 4
         mk = '.';
         c = 'r';
   end
   plot(customers(i).pos(1),customers(i).pos(2),'marker',mk,'markersize',10,'color',c)
   text(customers(i).pos(1),customers(i).pos(2),num2str(i))
end
hold off
end

