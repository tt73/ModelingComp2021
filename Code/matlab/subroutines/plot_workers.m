function [] = plot_workers(num_workers,workers)


hold on
for i = 1:num_workers
   switch workers(i).status
      case 0
         marker = 'bs';
      case 1
         marker = 'bs';
      case 2
         marker = 'b^';
      case 3
         marker = 'bs';
      case 4 
         marker = 'rs';
   end
   plot(workers(i).pos(1),workers(i).pos(2),marker,'markersize',8)
%    text(customers(i).pos(1),customers(i).pos(2),num2str(i))
end
hold off

end

