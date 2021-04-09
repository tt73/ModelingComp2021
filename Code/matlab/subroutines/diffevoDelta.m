function optimizer=diffevoDelta(f,l,DEparams)

%Minimizes f(x) using the differential evolution algorithm 
%of Storn, Price

%Inputs:
%f is the function handle we want to minimize
%l is the length of the interval for the defined function
%DEparams.CR,DEparams.NP,DEparams.F are the diffevo 
%parameters discussed in the literature

%Output: the possible global minimizer

%Initialize a population of candidate minimizers from the intervals [-l,l]
pop=zeros(DEparams.ND,DEparams.NP);
for j=1:DEparams.ND
    for i=1:DEparams.NP
        pop(j,i)=(l(j)*(2*rand-1));
    end
end
fpop=zeros(DEparams.NP,1);
z=zeros(DEparams.ND,1);
for i=1:DEparams.NP
    fpop(i)=f(pop(:,i));
end

%Set DEparams.tolerance and maximum number of iterations
counter=0;tic

while counter<DEparams.Nmax
    newpop=pop;
    newfpop=fpop;
    for i=1:DEparams.NP
        for j=1:DEparams.ND
            currentmember=pop(j,i);
            %Choose 3 distinct elements different from current member
            randind=randsample(DEparams.NP,3);
            while length(unique(randind))<3||~isempty(find(randind==i,1))
                randind=randsample(DEparams.NP,3);
            end
            a=pop(j,randind(1));
            b=pop(j,randind(2));
            c=pop(j,randind(3));
            
            %Compute currentmember's potentially new location y
            r=rand;
            %Potential Cross Over
            if r<DEparams.CR
                y=a+DEparams.F*(b-c);
            else
                y=currentmember;
            end
            z(j)=y;
        end
        
        fCandidate=f(z);
        if fCandidate<fpop(i)
            newpop(:,i)=z;
            newfpop(i)=fCandidate;
        end    
        
    end
    
    %Update
    counter=counter+1;
    pop=newpop;
    fpop=newfpop;
    fprintf('%f cost after %i iterations of diffevo complete in %f seconds.\n',...
            min(fpop),counter,toc)
end

optimizer=pop;