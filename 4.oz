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
