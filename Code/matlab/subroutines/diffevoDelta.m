function [pop,costs] = diffevoDelta(f,l,DEparams)

%Minimizes f(x) using the differential evolution algorithm
%of Storn, Price

%Inputs:
%f is the function handle we want to minimize
%l is the length of the interval for the defined function
%DEparams.CR,DEparams.NP,DEparams.F are the diffevo
%parameters discussed in the literature

%Output: the possible global minimizers

%Initialize a population of candidate minimizers from the intervals [-l,l]
pop = zeros(DEparams.ND,DEparams.NP);

for i = 1:DEparams.NP
   for j = 1:DEparams.ND
      pop(j,i)=(l(j)*(2*rand-1)); % pop(:,i) is one agent
   end
end


fpop = zeros(DEparams.NP,1);
for i=1:DEparams.NP
   fpop(i)=f(pop(:,i));
end

%Set DEparams.tolerance and maximum number of iterations
counter=0; tic
while counter < DEparams.Nmax
   
   for i = 1:DEparams.NP % for each agent in pop
      
      y = pop(:,i); % make a clone
      
      R = randi(DEparams.ND);
      
      % Draw 3 samples from populatino w/o replacement
      randind = randsample(DEparams.NP,3);
      while(ismember(i,randind)) % keep sampling until i is not drawn
         randind = randsample(DEparams.NP,3);
      end
      a = pop(:,randind(1));
      b = pop(:,randind(2));
      c = pop(:,randind(3));
      
      for j = 1:DEparams.ND
         if (rand<DEparams.CR || j==R)
            y(j) = a(j) + DEparams.F*(b(j)-c(j));
         end
      end
      
      fCandidate = f(y);
      if (fCandidate<fpop(i))
         pop(:,i) = y;
         fpop(i) = fCandidate;
      end
      
   end
   
   counter = counter + 1;
end

costs = fpop;