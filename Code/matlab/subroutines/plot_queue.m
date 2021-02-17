function [] = plot_queue(queue)
%Plot the position of all customers in the queue 
   hold on
   for i = 1:length(queue)
      plot(pos_customer(1,i),pos_customer(2,i),'k.')
      text(pos_customer(1,i),pos_customer(2,i),ID_customer(i))
   end
   hold off
end