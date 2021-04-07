function [jm, ji, jw, jt, jo] = compute_simulation_cost(workers, customers, cost_obj, show)
pm = cost_obj.pm;
pw = cost_obj.pw;
pi = cost_obj.pi;
pt = cost_obj.pt;
po = cost_obj.po;
ssh = cost_obj.L;

if(nargin==3)
   show = false;
end
M = length(workers);
N = length(customers);

jm = M*pm;

ji = 0;
jw = 0;
for c = 1:N
   diff = customers(c).scheduled_time - customers(c).arrival_time;
   if(customers(c).status ~= 4)
      if (diff < 0) % worker arrived too late
         jw = jw - diff;
      else % worker arrived too early
         ji = ji + diff;
      end
   end
end
jw = jw*pw;
ji = ji*pi;


jt = 0;
for w = 1:M
   jt = jt + workers(w).total_drivetime;
end
jt = jt*pt;


jo = 0;
L = ssh*60;
for w = 1:M
   if (workers(w).end_time > L)
      jo = jo + workers(w).end_time;
   end
end
jo = jo*po;


if (show)
   figure 
   X = categorical({'Hiring','Idle','Waiting','Travel','Overtime'});
   X = reordercats(X,{'Hiring','Idle','Waiting','Travel','Overtime'});
   Y = [jm, ji, jw, jt, jo];
   bar(X,Y)
end

end

