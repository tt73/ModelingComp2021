%%
% Written by Jimmie 
%
function [J,numworkers,routing] = sectorObjective(testangle,customers,w,make_plots)
% routing (numworker by 1) cell array 
numsects = length(testangle);
J = 0;
flag = 0;
N = max(size(customers));

% initialize their position and relative distance arrays
dist = zeros(N,1); % distance of each customer from the origin
ang = zeros(N,1); % angular location of each customer (-pi to pi) 
pos = zeros(N,2); % 

% assign positions to an array
for i=1:N
   tempcust = customers(i);
   dist(i) = norm(tempcust.pos,2);
   ang(i) = atan2(tempcust.pos(2),tempcust.pos(1));
   pos(i,:) = tempcust.pos;
end

if make_plots
   plot(pos(:,1),pos(:,2),'*'),hold on
end

metrics=zeros(numsects,1);
for i=1:numsects
   
   if i==numsects 
      sectorindex = (testangle(i)<ang) | (ang<testangle(1)); % last sector
   else
      sectorindex = (testangle(i)<ang) & (ang<testangle(i+1)); % all other sectors
   end
   
   x = pos(sectorindex,1); x = [0;x]';
   y = pos(sectorindex,2); y = [0;y]';
   P = [x; y]; % coordinates / points
   c = mean(P,2); % mean/ central point
   d = P-c ; % vectors connecting the central point and the given points
   th = atan2(d(2,:),d(1,:)); % angle above x axis
   [~, idx] = sort(th);   % sorting the angles
   P = P(:,idx); % sorting the given points
   P = [P P(:,1)]; % add the first at the end to close the polygon
   
   % update pathing 
   
   if make_plots
      plot( P(1,:), P(2,:), '.-r')
   end
   
   if i>1
      flag = shareboundary(tempP,P);
   end
   
   % impose constraint on pathing 
   if flag
      J=inf;
   end
   
   tempP = P;
   [~,n] = size(P);
   
   for j = 1:n-1
      metrics(i) = metrics(i)+norm(P(:,j)-P(:,j+1),2);
   end
end

nonzeroindices=find(metrics~=0);
perim = metrics(nonzeroindices); % length of the tour 

J = J + w*std(perim) + (1-w)*mean(perim); 

numworkers = length(perim); 