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
% vcosts      = cost based on variance of the tour lengths of each worker
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
for i=1:DEparams.NP
   [dcosts(i),vcosts(i)] = f(pop(:,i));
   if(vcosts(i)==0)
      warning('somethings off')
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
      randind = randsample(DEparams.NP,3);
      while(ismember(i,randind)) % keep sampling until i is not drawn
         randind = randsample(DEparams.NP,3);
      end
      a = pop(:,randind(1));
      b = pop(:,randind(2));
      c = pop(:,randind(3));
      
      % Potential Cross Over y
      y = pop(:,i);
      for j = 1:DEparams.ND
         if (rand<DEparams.CR || j==R)
            y(j) = a(j) + DEparams.F*(b(j)-c(j));
         end
      end
   end
   
   % If new agent has lower cost, then replace
   % The cost is a weighted average of deterministic cost and variance.
   [new_cost,new_var] = f(y);
   if (w*new_var + (1-w)*new_cost < w*vcosts(i)+(1-w)*dcosts(i))
      pop(:,i) = y;
      dcosts(i) = new_cost;
      vcosts(i) = new_var;
   end
   
   % Update
   counter = counter + 1;
end