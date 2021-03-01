% deprecated code

clear 

T = 1;
dt = T/300;
gridsize = 1;

% generate a list of times according to poisson process
lambda = 10; % average number of customers from 0 to 1
count = 0;
t = -log(1-rand)/lambda; % time at which first customer calls
while (t < T)
   customers(count+1) = Customer(gridsize,t); % construct a customer
   t = t - log(1-rand)/lambda;
   count = count + 1;
end
num_customer = count; 

% workers
num_workers = 3;
vel_worker = 12;     % constant speed of van
workers(num_workers,1) = Worker;

% management
cur_customer = 1; % customer index that will be added to the queue
queue = []; % customers waiting in line
jobtime = .01;

% Initialize movie with a graph
plot(0,0,'ro')
axis([-gridsize, gridsize, -gridsize, gridsize])
set(gca,'nextplot','replacechildren');
v = VideoWriter('basic1.mp4','MPEG-4');
open(v);


for t = 0:dt:T
   
   
   % add customer to the queue
   for i = cur_customer:num_customer
      if(customers(i).time < t)
         queue = [queue; cur_customer];
         cur_customer = cur_customer + 1;
      else
         break
      end
   end
   
   % manage work assignment 
   if(~isempty(queue))
      for q = 1:length(queue)
         c = queue(q); % the customer in line 
         if(customers(c).status==0)  
            for w = 1:num_workers
               status = workers(w).status;
               if(status==0)
                  workers(w).status = 1;
                  workers(w).task = c;
                  customers(c).status = 1;
                  break
               end
            end
         end
      end
   end
   
   % update workers 
   for w = 1:num_workers
      c =  workers(w).task;
      switch workers(w).status
         case 0
            % just chill
         case 1 
            % worker is driving directly to the house
            % he moves for dt amount of time at fixed velocity 
            % when he arrives, change his status to 2
            destination = customers(c).pos;
            workers(w) = workers(w).move(destination,vel_worker,dt);

         case 2
            % worker is at the house
            % he works for dt amount of time 
            % when he is done, change his status to 3
            workers(w).worktime = workers(w).worktime + dt;
            if (workers(w).worktime > jobtime)
               workers(w).worktime = 0;
               workers(w).status = 3;
               customers(c).status = 2;
               queue = queue(queue~=c);
            end
            
         case 3
            % worker is returning to HQ
            % he for dt amount of time at fixed velocity
            % when he returns, change his status to 0
            destination = [0,0];
            workers(w) = workers(w).move(destination,vel_worker,dt);
      end
   end
   
   % plot HQ - (this will delete the previous plot)
   plot(0,0,'ro')
   
   % plot customers in queue
   hold on
   for i = 1:length(queue)
      c = queue(i);
      plot(customers(c).pos(1),customers(c).pos(2),'k.')
      text(customers(c).pos(1),customers(c).pos(2),num2str(c))
   end
   for i = 1:num_workers
      plot(workers(i).pos(1),workers(i).pos(2),'bs')
   end
   hold off
   
   % take the plot, and save it
   title(sprintf('Time = %f',t))
   axis([-gridsize, gridsize, -gridsize, gridsize])
   frame = getframe(gcf);
   writeVideo(v,frame);
   
   
end

close(v);