%%
% Editted by Tada
%
function [pop,dcosts,vcosts] = diffevoAngles2(f,l,w,DEparams)
%Minimizes f(x) using the differential evolution algorithm
%of Storn, Price

%Inputs:
% f = the function handle we want to minimize
% l = input of f, its a column
% w = weight of the variance vs deterministic cost
% DEparams = object containing several DE options

%Output:
% pop         = NP columns of candidates
% dcosts      = deterministic of candidates based on model parameters
% vcosts      = cost based on variance of the tours
% num_workers = actual number of workers employed for each candidate


% Initialize the population
% Perturb all of the angles except the first one
% pop(:,i) is the ith agent
pop = zeros(DEparams.ND, DEparams.NP);

for i = 1:DEparams.NP
   pop(1,i) = l(1);
   for j = 2:DEparams.ND
      pop(j,i) = l(j) + pi*(2*rand-1)/DEparams.ND;
   end
   pop(:,i) = sort(pop(:,i));
end

% Compute cost of each population
% Compute the tour variance as well
% Compute the number of workers too
vcosts = zeros(DEparams.NP,1);
dcosts = zeros(DEparams.NP,1);
wcost = zeros(DEparams.NP,1);
best = 1;
bcost = inf;
for i=1:DEparams.NP
   [dcosts(i),vcosts(i)] = f(pop(:,i));
   wcost(i) = w*vcosts(i) + (1-w)*dcosts(i);
   if (wcost(i) < bcost)
      bcost = wcost(i);
      best = i;
   end
end

%Set DEparams.tolerance and maximum number of iterations
counter = 0;
while counter<DEparams.Nmax
   
   % loop over each agent
   for i = 1:DEparams.NP
      % Random sector
      R = randi(DEparams.ND);
      
      % Draw 3 samples from populatino w/o replacement
      randind = randsample(DEparams.NP,4);
      while(ismember([i,best],randind)) % keep sampling until i is not drawn
         randind = randsample(DEparams.NP,4);
      end
      
      % Potential Cross Over y
      y = pop(:,i);
      for j = 1:DEparams.ND
         if (rand<DEparams.CR || j==R)
            a = pop(j,randind(1));
            b = pop(j,randind(2));
            c = pop(j,randind(3));
            d = pop(j,randind(4));
            y(j) = pop(j,best) + DEparams.F*(a-b) + DEparams.F*(c-d);
         end
      end
   end
   
   % fix the mutated agent by sorting
   y = sort(y);
   
   % penalize the agent if angles fall out of range
   if(any(y>pi) || any(y<-pi))
      continue
   else
      
      % If new agent has lower cost, then replace
      % The cost is a weighted average of deterministic cost and variance.
      [new_dcost,new_vcost] = f(y);
      new_cost = w*new_vcost + (1-w)*new_dcost;
      if (new_cost < wcost(i))
         pop(:,i) = y;
         dcosts(i) = new_dcost;
         vcosts(i) = new_vcost;
         wcost(i) = new_cost;
         if (new_cost < bcost)
            bcost = new_cost;
            best = i;
         end
      end
   end
   
   % Update
   counter = counter + 1;
   
   % check for convregence 
   if (std(wcost) < DEparams.tol)
      break
   end
end