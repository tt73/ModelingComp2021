%%
% 
% Just testing out how to 
load_settings;

minND=7; 
maxND=15; 
w=0.9; % 0 < w < 1, 
[num_workers,sector_angles] = DetermineWorkers(customers,minND,maxND,w,true);
workers = Worker(num_workers);


%%
sector_angles = sort(sector_angles);
L = gridsize;
num_sec = length(sector_angles);
edges = sector_angles;
figure, hold on
for i = 1:num_sec
   plot([0 L*cos(edges(i))],[0 L*sin(edges(i))],'k','linewidth',1.5)
   text(L/3*cos((edges(i))),L/3*sin((edges(i))),num2str(i),'fontsize',14)
end
axis([-L/2 L/2 -L/2 L/2])


n = length(customers);
m = num_workers;
arrival_times = zeros(n,1);
routing = cell(m,1);
fullID = 1:n;

pos = [customers.pos]; % size 2 by n 
ang = atan2(pos(2,:),pos(1,:));
rad = vecnorm(pos);
scatter(rad.*cos(ang),rad.*sin(ang))

colors = distinguishable_colors(num_sec);
workID = 1;
for i = 1:num_sec
 
   % Get a mask (bool array) for all customers in current sector
   if i==num_sec
      % last sector
      sectorindex = (sector_angles(i)<ang) | (ang<sector_angles(1)); 
   else
      % all other sectors
      sectorindex = (sector_angles(i)<ang) & (ang<sector_angles(i+1)); 
   end
   
   % index of customers in the sector
   localID = fullID(sectorindex);
   
   % skip empty sectors 
   num_points = sum(sectorindex);
   if (num_points==0) 
      continue  
   end
   
   % calculate central pivot point 
   P = [[0;0], pos(:,sectorindex)];
   piv = mean(P,2); 
   d = P-piv;
   th = atan2(d(2,:),d(1,:));
   [~, idx] = sort(th);   % sorting the angles
   shift = -find(idx==1)+1;  % circular shift index 
   idxs = circshift(idx,shift);
   P = P(:,circshift(idx,shift)); 
   
   % Save the ordered index of customers 
   ordered = localID(idxs(2:end)-1);
   routing{workID} = ordered;
   workID = workID + 1; 
   
   plot(P(1,:),P(2,:),'color',colors(i,:))
   plot(piv(1),piv(2),'ko','MarkerFaceColor','k')
   plot(pos(1,sectorindex),pos(2,sectorindex),'*','color',colors(i,:))
   
end

colors = distinguishable_colors(m);


