#fileID<Lambda_al>

#import<toolkit.al>

begin type Lambda
   add = lambda{op1: int; op2: int; ? @
            op1 + op2 };
end

begin const LambdaAppl
   add(2, 4) = 6;
   lambda{op1: int; op2: int; ? @
      op1 * op2}(2, 4) = 8;
end
