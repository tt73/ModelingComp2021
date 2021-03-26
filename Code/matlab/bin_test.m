
n = 50;
L = 50;

coords = rand(2,n)*L - L/2;

R = vecnorm(coords);
angle = zeros(1,n);
for i = 1:n
   if (coords(2,i) > 0)
      angle(i) = acosd(coords(1,i)/R(i));
   else
      angle(i) = 360 - acosd(coords(1,i)/R(i));
   end
end


% Create 
da = 30;
edges = 0:da:360;
%change this again
count = histcounts(angle,edges)

figure 
subplot(121)
hold on 
scatter(coords(1,:),coords(2,:),'filled')
for i = 1:length(edges)-1
   plot([0 L*cosd(edges(i))],[0 L*sind(edges(i))],'k','linewidth',1.5)
   text(L/3*cosd((edges(i)+da/2)),L/3*sind((edges(i)+da/2)),num2str(i),'fontsize',14)
end
xlim([-L/2 L/2]), ylim([-L/2 L/2])
subplot(122)
bar(count)

average_bin_count = mean(count)