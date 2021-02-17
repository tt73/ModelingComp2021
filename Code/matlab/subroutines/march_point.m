function [A_new, reached] = march_point(A,B,v,dt)
%Move point A toward point B for dt amount of time at velocity v.
%   Move a particle from point A to point B 
%   Then check if A "reached" point B (meaning exceeded the destination) 
%   
reached = false;
d = B-A; % directional vector
A_new = A + d*v*dt;

angle = dot(d,B-A_new);
if (angle>0) % parallel 
   reached = true;
else
   % not reached yet
end

end

