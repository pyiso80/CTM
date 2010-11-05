% The tree-drawing algorithm and its displayer

% Author: Peter Van Roy

% Load QTk GUI tool from Mozart Standard Library
declare
[QTk]={Module.link ["x-oz://system/wp/QTk.ozf"]}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate positions

% (This uses order-determining concurrency for simplicity;
% with judicious placement of the calculations a sequential
% model can be used instead.)

declare
fun {AddXY Tree}
   case Tree
   of tree(left:L right:R ...) then
      {Adjoin Tree tree(x:_ y:_ left:{AddXY L} right:{AddXY R})}
   [] leaf then
      leaf
   end
end        
/*
Scale=40

proc {DepthFirst Tree Level LeftLimit RootX RightLimit}
   case Tree
   of tree(x:X y:Y left:leaf right:leaf ...) then
      thread X=LeftLimit end
      thread Y=Scale*Level end
      thread RootX=X end
      thread RightLimit=X end
   [] tree(x:X y:Y left:L right:leaf ...) then
      thread X=RootX end
      thread Y=Scale*Level end
      {DepthFirst L Level+1 LeftLimit RootX RightLimit}
   [] tree(x:X y:Y left:leaf right:R ...) then
      thread X=RootX end
      thread Y=Scale*Level end
      {DepthFirst R Level+1 LeftLimit RootX RightLimit}
   [] tree(x:X y:Y left:L right:R ...) then
         LRootX LRightLimit RRootX RLeftLimit
      in
         thread X=(LRootX+RRootX) div 2 end
         thread Y=Scale*Level end
         thread RootX=X end
         thread RLeftLimit=LRightLimit+Scale end
         {DepthFirst L Level+1 LeftLimit LRootX LRightLimit}
         {DepthFirst R Level+1 RLeftLimit RRootX RightLimit}
   end
end
*/


Scale=40
proc {DepthFirst Tree Level LeftLim ?RootX ?RightLim}
   case Tree
   of tree(x:X y:Y left:leaf right:leaf ...) then
      X=RootX=RightLim=LeftLim
      Y=Scale*Level
   [] tree(x:X y:Y left:L right:leaf ...) then
      X=RootX
      Y=Scale*Level
      {DepthFirst L Level+1 LeftLim RootX RightLim}
   [] tree(x:X y:Y left:leaf right:R ...) then
      X=RootX
      Y=Scale*Level
      {DepthFirst R Level+1 LeftLim RootX RightLim}
   [] tree(x:X y:Y left:L right:R ...) then
         LRootX LRightLim RRootX RLeftLim
      in
         Y=Scale*Level
         {DepthFirst L Level+1 LeftLim LRootX LRightLim}
         RLeftLim=LRightLim+Scale
         {DepthFirst R Level+1 RLeftLim RRootX RightLim}
         X=RootX=(LRootX+RRootX) div 2
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Run {P X Y T Level} on all nodes, where (X,Y) is the node's
% coordinates, T is the subtree at that node, and Level is
% the depth in the tree.
proc {Traverse1 PosTree Level P}
   case PosTree
   of tree(x:X y:Y left:L right:R ...) then
      {P X Y PosTree Level}
      {Traverse1 L Level+1 P}
      {Traverse1 R Level+1 P}
   [] leaf then
      skip
   end
end
                     
% Run {P X Y T SX SY ST Level} on all links parent-child.
proc {Traverse3 PosTree Level P}
   case PosTree
   of tree(x:X y:Y left:L=tree(x:LX y:LY ...) ...) then
      {P X Y PosTree LX LY L Level}
      {Traverse3 L Level+1 P}
   else skip end
   case PosTree
   of tree(x:X y:Y right:R=tree(x:RX y:RY ...) ...) then
      {P X Y PosTree RX RY R Level}
      {Traverse3 R Level+1 P}
   else skip end
end

% Create a window and return a function that can draw
% a tree in that window.
fun {MakeDrawTree}
   Can
   Des=td(canvas(handle:Can glue:nswe bg:white
                 width:400 height:300))
   Win={QTk.build Des}
   TagPtr={NewCell proc {$ _} skip end}
   {Win show}
in
   proc {$ PosTree}
      Tag={Can newTag($)}
   in
      {{Access TagPtr} delete}
      {Assign TagPtr Tag}
      {Traverse3 PosTree 0
       proc {$ X Y T AX AY AT L}
          {Can create(line X Y AX AY fill:black tags:Tag)}
       end}
      {Traverse1 PosTree 0
       proc {$ X Y T L}
          {Can create(rectangle X-3 Y-3 X+3 Y+3 fill:red tags:Tag)}
       end}
   end
end

DrawTree={MakeDrawTree}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Example execution: (feed the whole example in one step)

% 1. Define the example tree:
declare
Tree=
tree(key:a val:111
     left:tree(key:b val:55
               left:tree(key:x val:100
                         left:tree(key:z val:56 left:leaf right:leaf)
                         right:tree(key:w val:23 left:leaf right:leaf))
               right:tree(key:y val:105 left:leaf
                          right:tree(key:r val:77 left:leaf right:leaf)))
     right:tree(key:c val:123
                left:tree(key:d val:119
                          left:tree(key:g val:44 left:leaf right:leaf)
                          right:tree(key:h val:50
                                     left:tree(key:i val:5 left:leaf right:leaf)
                                     right:tree(key:j val:6 left:leaf right:leaf)))
                right:tree(key:e val:133 left:leaf right:leaf)))

% 2. Calculate the solution:
Tree2={AddXY Tree}
{Browse Tree2}
{DepthFirst Tree2 1 Scale _ _}

% 3. Draw the solution:
{DrawTree Tree2}

% Browse the solution:
{Browse Tree2}

% END

