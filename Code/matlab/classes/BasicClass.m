% I'm just keeping this for reference 

classdef BasicClass
   properties
      Value {mustBeNumeric}
   end
   methods
      function obj = BasicClass(val) % this is a constructor
         if nargin == 1
            obj.Value = val;   % e.g. myBasicClass = BasicClass(111)
         end
      end
      function r = roundOff(obj) 
         r = round([obj.Value],2);
      end
      function r = multiplyBy(obj,n)
         r = [obj.Value] * n;
      end
      
      function r = plus(o1,o2) % example of overloading
         r = [o1.Value] + [o2.Value];
      end
   end
end