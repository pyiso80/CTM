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



	 


