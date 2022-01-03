# ModelingComp2021
This is the repository for the implementation of a vehicle routing and scheduling problem for the Modeling and Optimization: Theory and Applications 2021 competition by: <br />
> Tadanaga Takahashi - tt73@njit.edu <br />
> Yixuan Sun - ys379@njit.edu <br />
> Jimmie Adriazola - ja374@njit.edu <br />

## Introduction 
This is the [link](https://coral.ise.lehigh.edu/~mopta/competition) to the homepage of the modeling competition, and this is the [PDF](https://coral.ise.lehigh.edu/~mopta/mopta2021/MOPTA2021_Competition.pdf) of the official competition description. This a twist on a classic routing problem where there are N customers scattered across a grid and they must be serviced by M workers (M < N). This may be a HVAC or internet installation service. You must account for 1. the cost of hiring workers, 2. gasoline prices for traveling, and 3. cost of overtime any individual workers going beyond the standard work day. You must give each worker a subset of customers to handle in what order. Consider what would happen if customers can randomly cancel their appointment after the work distribution has already been decided. Consider what would happen if the time to travel from location to location or if the amount of time required to finish a service contained randomness. Then you introduce 2 additional costs resulting from the randomness: 1. cost of idling workers and 2. cost of keeping customers waiting passed the appointment time. 

## Model
All workers are deployed from the headquarters which is located at the origin of a 2D grid. There are N = 20 to 50 customers randomly uniformly scattered over a square. We break down the routing and scheduling problem into 3 phases: 
* Phase 1: Service day is still a few days away. Assume a full list of customers and their location is known. During this phase, the number of workers to hire and the work distribution must be decided. A routing must be constructed for each worker. An appointment time must be assigned to each customer. No additional customers can be scheduled for the service day after this phase is completed.
* Phase 2: This is the last day before the service. Some customers have cancelled. The customers’ appointment time and workers’ work load cannot be changed at this time. The only adjustment allowed is to remove cancelled appointments from the itenerary. 
* Phase 3: The service day has begun and we assume there is no additional customers cancel their appointments. Workers move from customer to customer in the order specified in their schedule without breaks. Workers start service immediately if they arrive after the appointment time. Workes idle outside if they arrive too early. Each worker must service all of its assigned customers and then return to HQ. 

The first step is to develop find select a number of workers and choose the routing for each worker. Next, we develop a way of assingning appointment time to each customer. Then we randomly choose customers to cancel their appointments. Finally, we run a simulation of the service day. The simulation incorporates random travel time and random service time. We tally the total cost based on how long the each worker unit worked, traveled, and idled as well as the total amount of time the customers have waited.  

## Method 

