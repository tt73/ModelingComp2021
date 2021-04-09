%%
% Written by Tada

load_settings;

num_workers = num_customers/2;
workers = Worker(num_workers);

[arrival_times,routing] = build_sched_scatter(workers,customers,Param);

L = gridsize;
figure

m = length(routing); % number of workers 
colors = distinguishable_colors(m);

cpos = [customers.pos];
hold on
for i = 1:m
   
   x = [0, cpos(1,routing{i}), 0]; 
   y = [0, cpos(2,routing{i}), 0];
   u = x(2:end) - x(1:end-1);
   v = y(2:end) - y(1:end-1);
   
   plot(x,y,'.','color',colors(i,:))
   quiver(x(1:end-1),y(1:end-1),u,v,'AutoScale','off','color',colors(i,:),'MaxHeadSize',0.15)
end

axis([-L/2 L/2 -L/2 L/2])