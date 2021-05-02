function [pop,costs] = diffevoDelta(f,l,DEparams,cost_obj)

%Minimizes f(x) using the differential evolution algorithm
%of Storn, Price

%Inputs:
%f is the function handle we want to minimize
%l is the length of the interval for the defined function
%DEparams.CR,DEparams.NP,DEparams.F are the diffevo
%parameters discussed in the literature

%Output: the possible global minimizers

%Initialize a population of candidate minimizers with a uniform
%distribution over the search space. If wait cost > idle cost, then we try
%to push the appoitment times later (buffer time > 0). If wait cost < idle
%cost, then we move the appointment times earlier (buffer time < 0). 
pop = zeros(DEparams.ND,DEparams.NP);
for i = 2:DEparams.NP % skip first member on purpose 
   for j = 1:DEparams.ND
      if (cost_obj.pw > cost_obj.pi) 
         pop(j,i)=(l(j)*(rand));
      else
         pop(j,i)=(l(j)*(-rand));
      end
   end
end


% compute the initial cost of each member of the population 
cost = zeros(DEparams.NP,1);
best = 1; 
bcost = inf;
for i=1:DEparams.NP
   cost(i)=f(pop(:,i));
   if(cost(i) < bcost)
      bcost = cost(i);
      best = i; % keep track of the best one
   end
end

%Set DEparams.tolerance and maximum number of iterations
counter=0; 
start = tic;
while counter < DEparams.Nmax
   
   for i = 1:DEparams.NP % for each agent in pop
      
      y = pop(:,i); % make a clone
      
      R = randi(DEparams.ND);
      
      % Draw 3 samples from populatino w/o replacement
      randind = randsample(DEparams.NP,2);
      while(ismember([i,best],randind)) % keep sampling until i is not drawn
         randind = randsample(DEparams.NP,2);
      end
   
      for j = 1:DEparams.ND
         if (rand<DEparams.CR || j==R)
            y(j) = pop(j,best) + DEparams.F*(pop(j,randind(1))-pop(j,randind(2)));
         end
      end
      
      ycost = f(y);
      if (ycost<cost(i))
         pop(:,i) = y;
         cost(i) = ycost;
         
         if (ycost < bcost)
            bcost = ycost;
            best = i;
         end
      end
      
      
   end
   
   secs = toc(start);
   counter = counter + 1;
   fprintf('Finished %d/%d iterations in %6.2f seconds. std = %6.2f. Expected to finish in %6.2f minutes\n\r',counter,DEparams.Nmax,secs,std(cost),(DEparams.Nmax/counter-1)*secs/60)
end

costs = cost;