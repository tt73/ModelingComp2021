function  plot_routing(routing,coords,param_obj,cost_obj)

m = length(routing); % number of workers
colors = distinguishable_colors(m);
tour_length = zeros(m,1);
tour_duration = zeros(m,1);
tour_cost = zeros(3,m);
f = figure;

for i = 1:m
   
   x = [0, coords(1,routing{i}), 0];
   y = [0, coords(2,routing{i}), 0];
   u = x(2:end) - x(1:end-1);
   v = y(2:end) - y(1:end-1);
   
   num_jobs = length(routing{i});
   tour_length(i) = sum(sqrt(( u.^2 + v.^2 )));
   tour_duration(i) = tour_length(i)/param_obj.vel + num_jobs*param_obj.mst;
   tour_cost(1,i) = cost_obj.pm;
   tour_cost(2,i) = tour_length(i)*cost_obj.pt;
   tour_cost(3,i) = (tour_duration(i) > cost_obj.L*60).*(tour_duration(i) - cost_obj.L*60)*cost_obj.po;
   
   % left graph 
   subplot(121), hold on
   plot(x,y,'.','color',colors(i,:))
   quiver(x(1:end-1),y(1:end-1),u,v,'AutoScale','off','color',colors(i,:),'MaxHeadSize',0.15,'linewidth',1.5)
   
   % right graph 
   subplot(122), hold on
   h = bar(i,tour_cost(:,i));
   set(h,'facecolor',colors(i,:))
end

subplot(121)
L = param_obj.gs;
axis([-L/2 L/2 -L/2 L/2])
xlabel('x (km)'),ylabel('y (km)')
title('Routing')

subplot(122)
xlim([0.5,m+0.5])
xlabel('Worker'),ylabel('Hire + Travel + Overtime Cost')
title('Cost for Each Worker')

p = f.Position;
p(3) = 2*p(3); 
p(4) = 1.2*p(4);
set(f,'position',p);

sgtitle(sprintf('Total Cost: %8.4f',sum(sum(tour_cost))))

end

