addpath('subroutines')
addpath('classes')

T = 1;
dt = T/300;
gridsize = 1;

% generate a list of times according to poisson process
lambda = 20;
count = 1;
t = -log(1-rand)/lambda; % first customer makes an appointment
arrival_times = [];
while (t < T)
   arrival_times(count) = t;
   t = arrival_times(count) - log(1-rand)/lambda;
   count = count + 1;
end
num_customer = length(arrival_times);
pos_angle = 2*pi*rand(num_customer,1);
pos_radius = gridsize*rand(num_customer,1);
% pos_customer = [(pos_radius.*cos(pos_angle))'; (pos_radius.*sin(pos_angle))'];
pos_customer = 2*gridsize*rand(2,num_customer) - gridsize;
ID_customer = split(num2str(1:num_customer));
status_customer = zeros(num_customer,1); % 0 = unschedules, 1 = scheduled, 2 = serviced

% workers
num_worker = 1;
pos_worker = zeros(2,num_worker);
status_worker = zeros(num_worker,1); % 0 = hq, 1 = going, 2 = working, 3 = returning 
vel_worker = 1;                   % constant speed of van
task_worker = zeros(num_worker,1); % customer which worker is tasked to service
time_worker = zeros(num_worker,1); % how long worker has spent on a job 

% management
cur_customer = 1; % customer index that will be added to the queue
queue = []; % customers waiting in line
service_time = .0001;

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
      c =  task_worker(w); % the customer assigned to worker
      switch status_worker(w)
         case 0
            % just chill
         case 1 
            % worker is driving directly to the house
            % he moves for dt amount of time at fixed velocity 
            % when he arrives, change his status to 2
            start = pos_worker(:,w);
            dest = pos_customer(:,c);
            [pos_worker(:,w),arrived] = march_point(start,dest,vel_worker,dt);
            if (arrived)
               status_worker(w) = 2;
            end
         case 2
            % worker is at the house
            % he works for dt amount of time 
            % when he is done, change his status to 3
            time_worker(w) = time_worker(w) + dt;
            if (time_worker(w) >= service_time) 
               status_worker(w) = 3;            
            end
         case 3
            % worker is returning to HQ
            % he for dt amount of time at fixed velocity
            % when he returns, change his status to 0
            start = pos_worker(:,w);
            dest = [0;0];
            [pos_worker(:,w),arrived] = march_point(start,dest,vel_worker,dt);
            if (arrived)
               status_worker(w) = 0;
            end
      end
   end
   
   % plot HQ - (this will delete the previous plot)
   plot(0,0,'ro')
   
   % plot customers in queue
   plot_queue(queue)
   
   % take the plot, and save it
   title(sprintf('Time = %f',t))
   axis([-gridsize, gridsize, -gridsize, gridsize])
   frame = getframe(gcf);
   writeVideo(v,frame);
   
   
end

close(v);