%%
% Written by Jimmie 
%
function flag=shareboundary(P1,P2)
flag=false;
[~,runindexi]=size(P1);
[~,runindexj]=size(P2);
for i=1:runindexi
    for j=1:runindexj
        if P1(:,i)==P2(:,j)
            if i==1
                if j==1
                    if sum(P1(:,end)==P2(:,end))==2||...
                       sum(P1(:,end)==P2(:,2))==2||...
                       sum(P1(:,2)  ==P2(:,end))==2||...
                       sum(P1(:,2)   ==P2(:,2))==2 
                        flag=true;
                        break
                    end
                end
            end
            if i==1
                if j==runindexj
                    if sum(P1(:,end)==P2(:,end-1))==2||...
                       sum(P1(:,end)==P2(:,1))==2||...
                       sum(P1(:,2)  ==P2(:,end-1))==2||...
                       sum(P1(:,2)   ==P2(:,1))==2  
                        flag=true;
                        break
                    end
                end
            end
            if i==runindexi
                if j==1
                    if sum(P1(:,end-1)==P2(:,end))==2||...
                       sum(P1(:,end-1)==P2(:,2))==2||...
                       sum(P1(:,1)  ==P2(:,end))==2||...
                       sum(P1(:,1)   ==P2(:,2))==2   
                        flag=true;
                        break
                    end
                end
            end
            if i==runindexi
                if j==runindexj
                    if sum(P1(:,end-1)==P2(:,end-1))==2||...
                       sum(P1(:,end-1)==P2(:,1))==2||...
                       sum(P1(:,1)  ==P2(:,end-1))==2||...
                       sum(P1(:,1)   ==P2(:,1))==2  
                        flag=true;
                        break
                    end
                end
            end
            if i>1&&i<runindexi
                if j>1&&j<runindexj
                    if sum(P1(:,i+1)==P2(:,j+1))==2||...
                       sum(P1(:,i+1)==P2(:,j-1))==2||...
                       sum(P1(:,i-1)  ==P2(:,j+1))==2||...
                       sum(P1(:,i-1)   ==P2(:,j-1))==2  
                        flag=true;
                        break
                    end
                end
            end
        end
    end 
    if flag
        break
    end
end
