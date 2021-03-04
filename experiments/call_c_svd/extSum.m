function x = extSum(u)
%#codegen
% set bounds on input type to use static memory allocation
u = int32(u);
assert(0 < u && u < 101);
% initialize an array
temparray = int32(1):u;
% declare an external structure and use it
s = makeStruct(u);
x = callExtCode(s, temparray);
