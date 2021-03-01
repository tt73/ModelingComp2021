addpath('subroutines')
addpath('classes')
clear 


gridsize = 50; % km
vel = 1;       % km/min

% customers 
num_customers = 40; 
customers = Customer(gridsize,num_customers);

% workers 
num_workers = 4;
workers = Worker(num_workers);

% assign customers to workers 
positions = [customers.pos];
xpos = positions(1,:) > 0;
ypos = positions(2,:) > 0;
workers(1).tasks = find( xpos &  ypos);
workers(2).tasks = find(~xpos &  ypos);
workers(3).tasks = find(~xpos & ~ypos);
workers(4).tasks = find( xpos & ~ypos);

disp(workers(1).tasks)
disp(workers(2).tasks)
disp(workers(3).tasks)
disp(workers(4).tasks)



% Initialize movie with a graph
plot(0,0,'ro')
sz =100;
axis([-gridsize/2, gridsize/2, -gridsize/2, gridsize/2])
hold on
for i = 1:num_customers
   switch customers(i).status 
      case 0
         marker = 'g.';
      case 1
         marker = 'b.';
      case 2
         marker = 'r.';
   end
   scatter(customers(i).pos(1),customers(i).pos(2),sz,marker)
end
for i = 1:num_workers
   plot(workers(i).pos(1),workers(i).pos(2),'LineWidth',4)
end
hold off

set(gca,'nextplot','replacechildren');
v = VideoWriter('basic1.mp4','MPEG-4');
open(v);

T = 100; % min
dt = 1;  % min

for t = 0:dt:T
   
      
   % assign destination to idle workers 
   for w = 1:num_workers
      if (workers(w).status == 0)
         workers(w) = workers(w).choose_dest(customers);
      end
   end
   
   % update workers based on status 
   for w = 1:num_workers
      switch workers(w).status
         case 1
            workers(w) = workers(w).move(vel,dt);
         case 2
            workers(w) = workers(w).wait(dt,customers);
         case 3
            workers(w) = workers(w).work(dt,customers);
            customers(workers(w).curtask).status = 1;
      end
   end
   
   
   
   % plot HQ - (this will delete the previous plot)
   plot(0,0,'ro')
   
   % plot customers in queue
   hold on
   for i = 1:num_customers
      switch customers(i).status 
         case 0
            marker = 'g.';
         case 1
            marker = 'b.';
         case 2
            marker = 'r.';
      end
      plot(customers(i).pos(1),customers(i).pos(2),marker,'markersize',10)
      text(customers(i).pos(1),customers(i).pos(2),num2str(i))
   end
   for i = 1:num_workers
      plot(workers(i).pos(1),workers(i).pos(2),'bs')
   end
   hold off
   
   % take the plot, and save it
   title(sprintf('Time = %f',t))
   axis([-gridsize/2, gridsize/2, -gridsize/2, gridsize/2])
   frame = getframe(gcf);
   writeVideo(v,frame);
%    set(gcf,'position',[1089 374 1038 784])
   % debugging
%    for i = 1:num_workers
%       fprintf('Worker %d, status = %d\n',i,workers(i).status)
%    end

   
   
end


