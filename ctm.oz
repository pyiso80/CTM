declare
proc {ButLast L ?Y ?LR}
   case L
   of [X] then Y = X LR = nil
   [] X|L2 then L3 in
      LR=X|L3
      {ButLast L2 Y L3}
   end
end

declare X LR in
{ButLast [2] X LR}
{Browse X}
{Browse LR}




      