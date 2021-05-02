function  plot_routing(routing,coords,param_obj)

m = length(routing); % number of workers
colors = distinguishable_colors(m);
tour_length = zeros(m,1);

f = figure;

for i = 1:m
   
   x = [0, coords(1,routing{i}), 0];
   y = [0, coords(2,routing{i}), 0];
   u = x(2:end) - x(1:end-1);
   v = y(2:end) - y(1:end-1);
   
   
   tour_length(i) = sum(sqrt(( u.^2 + v.^2 )));
   num_jobs = length(routing{i});
   tour_duration(i) = tour_length(i)/param_obj.vel + num_jobs*param_obj.mst;
   
   % left graph 
   subplot(121), hold on
   plot(x,y,'.','color',colors(i,:))
   quiver(x(1:end-1),y(1:end-1),u,v,'AutoScale','off','color',colors(i,:),'MaxHeadSize',0.15,'linewidth',1.5)
   
   % right graph 
   subplot(122), hold on
   h = bar(i,tour_duration(i));
   set(h,'facecolor',colors(i,:))
end

subplot(121)
L = param_obj.gs;
axis([-L/2 L/2 -L/2 L/2])
xlabel('x (km)'),ylabel('y (km)')
title('Routing of Worker')

subplot(122)
xlim([0.5,m+0.5])
xlabel('Worker'),ylabel('Duration (min)')
title('Duration of Workers'' Job')

p = f.Position;
p(3) = 2*p(3); 
p(4) = 1.2*p(4);
set(f,'position',p);

end

