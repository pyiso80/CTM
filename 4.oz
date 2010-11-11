declare
fun {Gen L H}
   {Delay 1000}
   if L > H then nil else L|{Gen L+1 H} end
end

declare Xs Ys in
thread Xs = {Gen 1 20} end
thread Ys = {Map Xs fun {$ X} X * X end} end
{Browse Xs}
{Browse Ys}

% Partial Termination
declare
fun {Double Xs}
   case Xs
   of nil then Xs
   [] X|Xr then 2*X|{Double Xr} end
end

declare Ys Xs E in
Xs = 1|2|3|E
{Browse thread {Double Xs} end}
E=4|5|6|Ys
Ys=nil

declare
fun {Map Xs F}
   case Xs of nil then nil
   [] X|Xr then thread {F X} end|{Map Xr F} end
end
declare
F Xs Ys Zs
{Browse thread {Map Xs F} end}

Xs=1|2|3|4|Ys
fun {F X} X*X end

declare Zs in
Ys=5|6|7|8|Zs
Zs=nil

% Concurrent Fibonacci Function
declare
fun {Fib X}
   if X=< 2 then 1
   else thread {Fib X-1} end + {Fib X-2} end
end

{Browse {Fib 10}}

% 4.3 Streams
declare
fun {Generate N Limit}
   if N < Limit then
      N|{Generate N+1 Limit}
   else
      nil
   end
end
% --
fun {Sum Xs A}
   case Xs
   of nil then A
   [] X|Xr then {Sum Xr A+X}
   end
end
% --
local Xs S in
   thread Xs={Generate 0 150000} end
   thread S={Sum Xs 0} end
   {Browse S}
end
% --
local Xs S in
   thread Xs={Generate 0 1500001} end
   thread S={FoldL Xs fun {$ X Y} X+Y end 0} end
   {Browse S}
end

%-------------------------------------------------------------------------------
% Transducers and pipelines
declare
fun {IsOdd X} X mod 2 \= 0 end
local Xs Ys S in
   thread Xs={Generate 0 100} end
   thread Ys={Filter Xs IsOdd} end
   {Browse Ys}
   thread S={Sum Ys 0} end
   {Browse S}
end

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------

declare
proc {DGen N Xs}
   case Xs
   of X|Xr then X=N {DGen N+1 Xr}
   end
end
%-----
fun {DSum ?Xs A Limit}
   if Limit>0 then
      X|Xr=Xs        % to let X be bound by DGen 
   in
      {DSum Xr A+X Limit-1}        % A+X will block until X is bound by DGen
   else
      A
   end
end
%-----
local Xs S in
   thread {DGen 0 Xs} end
   thread {Browse Xs} end
   thread S={DSum Xs 0 10} end
   thread {Browse S} end
end
%-----
declare
proc {Buffer N ?Xs Ys} % Xs is the buffer list, Ys is to communicate with the consumer
   fun {Startup N ?Xs} % create a list of N unbound vars with an unbound tail and return the tail 
      if N==0 then Xs
      else Xr in Xs=_|Xr {Startup N-1 Xr} end
   end
   %------------------------------
   % AskLoop retrun an element from the buffer when the consumer ask for it by binding Ys
   % and also replenlish the buffer   
   proc {AskLoop Ys ?Xs ?End} % Ys will be bound to _|Yr by the consumer
      case Ys
      of Y|Yr then Xr End2 in
         Xs=Y|Xr % Y will received an element from the buffer	 
	 End=_|End2 % Replenish the buffer
	 {AskLoop Yr Xr End2}
      end
   end
   End={Startup N Xs}
in
   {AskLoop Ys Xs End} % Ys is the arg of the Buffer, and it communicates with the consumer, Xs is the buffer list
end





   

   





	 


