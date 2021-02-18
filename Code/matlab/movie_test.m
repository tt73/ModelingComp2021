addpath('subroutines')
addpath('classes')
clear 

T = 1;
dt = T/300;
gridsize = 1;

% generate a list of times according to poisson process
lambda = 15; % average number of customers from 0 to 1
count = 0;
t = -log(1-rand)/lambda; % time at which first customer calls
arrival_times = [];
while (t < T)
   customers(count+1) = Customer(t,gridsize); % construct a customer
   t = t - log(1-rand)/lambda;
   count = count + 1;
end
num_customer = count; 

% workers
num_worker = 1;
pos_worker = zeros(2,num_worker);
status_worker = ones(num_worker,1); % 0 = hq, 1 = going, 2 = working, 3 = returning 
vel_worker = 1;                    % constant speed of van
task_worker = zeros(num_worker,1); % customer which worker is tasked to service
time_worker = zeros(num_worker,1); % how long worker has spent on a job 

workers(num_worker,1) = Worker;

% management
cur_customer = 1; % customer index that will be added to the queue
queue = []; % customers waiting in line
jobtime = .0001;

% Initialize movie with a graph
plot(0,0,'ro')
axis([-gridsize, gridsize, -gridsize, gridsize])
set(gca,'nextplot','replacechildren');
v = VideoWriter('basic1.mp4','MPEG-4');
open(v);


for t = 0:dt:T
   
   
   % add customer to the que
   for i = cur_customer:num_customer
      if(arrival_times(i)<t)
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
         if(status_customer(c)==0)  
            for w = 1:num_worker
               if(status_worker(w)==0)
                  task_worker(w) = c;
                  status_worker(w) = 1; 
                  status_customer(c) = 1;
               end
            end
         end
      end
   end
   
   % update workers 
   for w = 1:num_worker
      switch status_worker(w)
         case 0
            % just chill
         case 1 
            % worker is driving directly to the house
            % he moves for dt amount of time at fixed velocity 
            % when he arrives, change his status to 2
            c =  task_worker(w);
            destination = pos_customer(:,c);
            
            dr = dt*pos_radius(c);
            dx = dr*cos(pos_angle(c));
            dy = dr*sin(pos_angle(c));
            pos_worker(2,w) = pos_worker(2,w) + [dx; dy];
            
         case 2
            % worker is at the house
            % he works for dt amount of time 
            % when he is done, change his status to 3
            
         case 3
            % worker is returning to HQ
            % he for dt amount of time at fixed velocity
            % when he returns, change his status to 0
      end
   end
   
   % plot HQ - (this will delete the previous plot)
   plot(0,0,'ro')
   
   % plot customers in queue
   hold on
   for i = 1:length(queue)
      plot(pos_customer(1,i),pos_customer(2,i),'k.')
      text(pos_customer(1,i),pos_customer(2,i),ID_customer(i))
   end
   hold off
   
   % take the plot, and save it
   title(sprintf('Time = %f',t))
   axis([-gridsize, gridsize, -gridsize, gridsize])
   frame = getframe(gcf);
   writeVideo(v,frame);
   
   
end

close(v);