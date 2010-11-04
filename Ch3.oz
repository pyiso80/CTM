declare
proc {ButLast Li ?X ?Lr}
   case Li
   of [E] then X=E Lr=nil
   [] E|L1 then L2 in
      Lr=E|L2
      {ButLast L1 X L2}
   end
end

declare F Lr
{ButLast [1 3 5 7] F Lr}
{Browse F}
{Browse Lr}

declare
fun {Reverse L}
   proc {ReverseD L ?Y1 Y}
      case L
      of nil then Y1=Y
      [] X|Lr then
	 {ReverseD Lr Y1 X|Y}
      end
   end
   Y1
in
   {ReverseD L Y1 nil} Y1
end


declare
fun {NewQueue} q(nil nil) end

fun {Check Q}
   case Q
   of q(nil R) then q({Reverse R} nil)
   else
      Q
   end
end

fun {Insert Q X}
   case Q
   of q(F R) then {Check q(F X|R)}
   end
end

fun {Delete Q ?X}
   case Q
   of q(F R) then F1 in F=X|F1 {Check q(F1 R)}
   end
end

fun {IsEmpty Q}
   case Q
   of q(F R) then
      F == nil
   end
end

declare
fun {NewQueue} X in q(0 X X) end

fun {Insert Q X}
   case Q
   of q(N S E) then E1 in E=X|E1 q(N+1 S E1)
   end
end

fun {Delete Q ?X}
   case Q
   of q(N S E) then S1 in S=X|S1 q(N-1 S1 E)
   end
end

fun {IsEmpty Q}
   case Q
   of q(N S E) then
      N==0
   end
end

declare Q1 Q2 Q3 Q4 Q5 Q6 Q7 IN
Q1={NewQueue}
Q2={Insert Q1 peter}
Q3={Insert Q2 paul}

local X in Q4={Delete Q3 X} {Browse X} end
Q5={Insert Q4 mary}
local X in Q6={Delete Q5 X} {Browse X} end
local X in Q7={Delete Q6 X} {Browse X} end

declare
proc {QuadEq A B C ?Real ?X1 ?X2}
   D=B*B-4.0*A*C
in
   if D>=0.0 then
      Real=true
      X1=(~B+{Sqrt D})/(2.0*A)
      X2=(~B-{Sqrt D})/(2.0*A)
   else
      Real=false
      X1=~B/(2.0*A)
      X2={Sqrt ~D}/(2.0*A)
   end
end

declare Rs X1 X2 in
{QuadEq 1.0 3.0 ~4.0 Rs X1 X2}
{Browse Rs#X1#X2}

%3.4.6 Trees
declare
fun {Lookup Ks T}
   case T
   of leaf then notFound
   [] tree(K V T1 T2) then
      if Ks==K then found(V)
      elseif Ks>K then {Lookup Ks T2}
      else  {Lookup Ks T1}
      end
   end
end

declare
fun {Lookup Ks T}
   case T
   of leaf then notFound
   [] tree(K V T1 T2) andthen Ks==K then found(V)
   [] tree(K V T1 T2) andthen Ks>K then {Lookup Ks T2}
   [] tree(K V T1 T2) andthen Ks<K then {Lookup Ks T1}
   end
end

declare T1 T2 T3 T4 T5 in
T1=leaf
{Browse {Lookup 1 T1}}
T2=tree(4 d tree(2 c tree(0 a leaf leaf) tree(3 b leaf leaf)) tree(5 e leaf leaf))
{Browse {Lookup 5 T2}}


declare
fun {Insert Ki Vi T}
   case T
   of leaf then tree(Ki Vi leaf leaf)
   [] tree(K V T1 T2) andthen Ki==K then tree(Ki Vi T1 T2)
   [] tree(K V T1 T2) andthen Ki<K then tree(K V {Insert Ki Vi T1} T2)
   [] tree(K V T1 T2) andthen Ki>K then tree(K V T1 {Insert Ki Vi T2})
   end
end

T3={Insert ~1 h T2}
{Browse T3}
{Browse T2}

declare
fun {RemoveSmallest T}
   case T
   of leaf then none
   [] tree(K V T1 T2) then
      case {RemoveSmallest T1}
      of none then K#V#T2
      [] Kp#Vp#Tp then Kp#Vp#tree(K V Tp T2)
      end
   end
end

{Browse {RemoveSmallest T2}}

declare
fun {Delete Kd T}
   case T
   of leaf then leaf
   [] tree(K V T1 T2) andthen Kd==K then
      case {RemoveSmallest T2}
      of none then T1
      [] Kp#Vp#Tp then tree(Kp Vp T1 Tp)
      end
   [] tree(K V T1 T2) andthen Kd>K then
      tree(K V T1 {Delete Kd T2})
   [] tree(K V T1 T2) andthen Kd<K then
      tree(K V {Delete Kd T1} T2)
   end
end

{Browse {Delete 4 T2}}

%3.4.6.4 Tree Traversal

%Depth-first traversal
declare
proc {DFS T}
   case T
   of leaf then skip
   [] tree(Key Val L R) then
      {Browse Key#Val}
      {DFS L}
      {DFS R}
   end
end

{DFS T2}

declare
proc {DFSAccLoop T S1 ?Sn}
   case T
   of leaf then Sn=S1
   [] tree(Key Val L R) then S2 S3 in
      S2=Key#Val|S1
      {DFSAccLoop L S2 S3}
      {DFSAccLoop R S3 Sn}
   end
end

declare
fun {DFSAcc T} {Reverse {DFSAccLoop T nil $}}end

{Browse {DFSAcc T2}}

declare
proc {DFSAccLoop2 T ?S1 Sn}
   case T
   of leaf then S1=Sn
   [] tree(Key Val L R) then S2 S3 in
      S1=Key#Val|S2
      {DFSAccLoop2 L S2 S3}
      {DFSAccLoop2 R S3 Sn}
   end
end
fun {DFSAcc2 T}
   {DFSAccLoop2 T $ nil}
end
{Browse {DFSAcc2 T2}}

declare
proc {BFS T}
   fun {TreeInsert Q T}
      if T\=leaf then {Insert Q T} else Q end
   end
    proc {BFSQueue Q1}
      if {IsEmpty Q1} then skip
      else X Q2 Key Val L R in
	 Q2={Delete Q1 X}
	 tree(Key Val L R)=X
	 {Browse Key#Val}
	 {BFSQueue {TreeInsert {TreeInsert Q2 L} R}}

      end
    end
in
    {BFSQueue {TreeInsert {NewQueue} T}}
end
{BFS T2}

declare
fun {BFSAcc T}
   fun {TreeInsert Q T}
      if T\=leaf then {Insert Q T} else Q end
   end

   proc {BFSQueue Q1 ?S1 Sn}
      if {IsEmpty Q1} then S1=Sn
      else Q2 X Key Val L R in
	 Q2={Delete Q1 X}
	 tree(Key Val L R)=X
	 S1=Key#Val|S2
	 {BFSQueue {TreeInsert {TreeInsert Q2 L} R} S2 Sn}
      end
   end
in
   {BFSQueue {TreeInsert {NewQueue} T} $ nil}
end

   
	 
   

      
	 




%3.6.1 Genericity
declare
fun {SumList L}
   case L
   of nil then 0
   [] X|L1 then X + {SumList L1}
   end
end

{Browse {SumList [1 2 3 4]}}

fun {FoldR L F U}
   case L
   of nil then U
   [] X|L1 then {F X {FoldR L1 F U}}
   end
end

declare
fun {SumList L}
   {FoldR L fun {$ X Y} X + Y end 0}
end

{Browse {SumList [1 2 3 4 5 6]}}

declare
fun {ProductList L}
   {FoldR L fun {$ X Y} X * Y end 1}
end
{Browse {ProductList [1 2 3]}}


declare
proc {Split Xs ?Ys ?Zs}
   case Xs
   of nil then Ys=nil Zs=nil
   [] [X] then Ys=[X] Zs=nil
   [] X|Y|Yr then Y1 Z1 in
      Ys=X|Y1 Zs=Y|Z1
      {Split Yr Y1 Z1}
   end   
end

declare Ys Zs in
{Split [1 2 3] Ys Zs}
{Browse Ys#Zs}

declare
fun {GenericMergeSort F Xs}
   fun {Merge Xs Ys}
      case Xs#Ys
      of nil#Ys then Ys
      [] Xs#nil then Xs
      [] (X|Xr)#(Y|Yr) then
	 if {F X Y} then X|{Merge Xr Ys}
	 else Y|{Merge Xs Yr} end
      end
   end

   fun {MergeSort Xs}
      case Xs
      of nil then nil
      [] [X] then [X]
      else Ys Zs in
	 {Split Xs Ys Zs}
	 {Merge {MergeSort Ys} {MergeSort Zs}}
      end
   end
in
   {MergeSort Xs}
end

declare
fun {MergeSort Xs}
   {GenericMergeSort fun {$ A B} A < B end Xs}
end
{Browse {MergeSort [5 7 3 9 1 3]}}


declare
fun {Merge Xs Ys}
      case Xs#Ys
      of nil#Ys then Ys
      [] Xs#nil then Xs
      [] (X|Xr)#(Y|Yr) then
	 if X>Y then X|{Merge Xr Ys}
	 else Y|{Merge Xs Yr} end
      end
end

declare X = 3 in
{Browse X}

declare
fun {Sort F Xs}
   fun {Merge Xs Ys}
      case Xs#Ys
      of nil#Ys then Ys
      [] Xs#nil then Xs
      [] (X|Xr)#(Y|Yr) then
	 if {F X Y} then X|{Merge Xr Ys}
	 else Y|{Merge Xs Yr} end
      end
   end

   fun {MergeSort Xs}
      case Xs
      of nil then nil
      [] [X] then [X]
      else Ys Zs in
	 {Split Xs Ys Zs}
	 {Merge {MergeSort Ys} {MergeSort Zs}}
      end
   end
in
   {MergeSort Xs}
end

declare
fun {MakeSort F}
   fun {$ L}
      {Sort F L}
   end
end

declare
SortInst = {MakeSort fun {$ A B} A < B end}

{Browse {SortInst [5 7 8 2 1]}}

declare
fun {Plus2}
   fun {$ A}
      A + 2
   end
end

declare
Add2 = {Plus2}

{Browse Add2}

{Browse {Add2 3}}


declare
proc {ForAll L P}
   case L
   of nil then skip
   [] X|L2 then
      {P X}
      {ForAll L2 P}
   end
end

{ForAll [1 2 3 4 5] Browse}

declare
proc {For A B S P}
   proc {LoopUp C}
      if C =< B then {P C} {LoopUp C+S} end
   end
   proc {LoopDn C}
      if C >= B then {P C} {LoopDn C+S} end
   end

in
   if S>0 then {LoopUp A} end
   if S<0 then {LoopDn A} end
end

{For 1 10 1 Browse}
{For 10 1 ~1 Browse}

declare
proc {ForAcc A B S P In ?Out}
   proc {LoopUp C In ?Out1}
      Mid in
      if C=<B then {P In C Mid} {LoopUp C+S Mid Out1}
      else In=Out end      
   end
   proc {LoopDn C In ?Out1}
      Mid in
      if C>=B then {P In C Mid} {LoopDn C+S Mid Out1}
      else In=Out end
   end   
in
   if S>0 then {LoopUp A In Out} end
   if S<0 then {LoopDn A In Out} end   
end

declare Z in
{ForAcc 1 3 1 proc {$ A B ?C} C=A+B end 0 Z}
{Browse Z}


declare
proc {ForAcc A B S P U ?FR}    % FR is final result for *ForAcc
   proc {LoopUp C  In ?FR}     % FR is the final result for *LoopUp, I
      Out in                   
      if C=<B then {P In C Out} {LoopUp C+S Out FR}
      else FR=In end
   end
   proc {LoopDn C  In ?FR}    
      Out in                   
      if C>=B then {P In C Out} {LoopDn C+S Out FR}
      else FR=In end
   end
in
   if S>0 then {LoopUp A U FR} end
   if S<0 then {LoopDn A U FR} end   
end

declare Z in
{ForAcc 4 1 ~1 proc {$ A B ?C} C=A+B end 0 Z}
{Browse Z}

declare
proc {ForAllAcc L P U ?Out}
   case L
   of nil then U=Out
   [] X|L2 then Mid in
      {P U X Mid}
      {ForAllAcc L2 P Mid Out}
   end
end


declare
fun {SumList L}
   S
in
   {ForAllAcc L proc {$ A B ?C} C=A+B end 0 S}
   S
end

{Browse {SumList [1 2 3]}}
{Browse {SumList nil}}

declare
fun {FoldL L F U}
   case L
   of nil then U
   [] X|L2 then {FoldL L2 F {F U X}}
   end
end


declare
fun {FoldR L F U}
   fun {Loop L U}
      case L
      of nil then U
      [] X|L2 then {Loop L2 {F X U}}
      end
   end   
in
   {Loop {Reverse L} U}
end

{Browse {FoldL [1 2 3] fun {$ A B} {Browse B} A + B end 0}}
   


   
declare
fun {Abs X}
   if X < 0.0 then ~X
   else X end
end

{Browse {Abs ~3.0}}
{Browse {Abs 0.0}}
{Browse {Abs 3.0}}

{Browse {Abs ~1.3}}


declare
proc {For A B S P}
   proc {LoopUp C}
      if C=<B then {P C} {LoopUp C+S} end
   end
   proc {LoopDn C}
      if C>=B then {P C} {LoopDn C+S} end
   end   
in
   if S>0 then {LoopUp A} end
   if S<0 then {LoopDn A} end
end

% {For A B S proc {$ I} <stmt> end}
% for I in A..B do <stmt> end
% for I in A..B;S do <stmt> end
for I in 1..10;2 do {Browse I} end

proc {ForAll L P}
   case L
   of nil then skip
   [] X|L2 then {P X} {ForAll L2 P}
   end
end

% {ForAll L proc {$ X} <stmt> end}
% for X in L do <stmt> end
for X in [1 2 3 5] do {Browse X} end

declare L in
L=[obj(name:tv price:100 color:black) obj(name:guitar price:100 color:red) obj(name:amp price:100 color:orange) ]

for obj(name:N price:P color:C) in L do
   {Browse N}
   {Browse P}
   {Browse C}
end

declare
fun {Filter L F}
   {FoldR L fun {$ X A} if {F X} then X|A else A end end nil}
end

declare
fun {Iterate S IsDone Transform}
   if {IsDone S} then S
   else S1 in
      S1 = {Transform S}
      {Iterate S1 IsDone Transform}
   end
end      

declare
fun {FoldR Xs F U}
   {Iterate
    {Reverse Xs}#U
    fun {$ S} Xr#A=S in Xr == nil end
    fun {$ S} Xr#A=S in Xr.2#{F Xr.1 A} end}.2
end

    
    







