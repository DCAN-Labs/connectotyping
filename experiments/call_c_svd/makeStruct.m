function s = makeStruct(u)
% create structure type based on external header definition
s.numel = u;
s.vals = coder.opaque('int32_T *','NULL');
coder.cstructname(s,'myArrayType','extern','HeaderFile','arrayCode.h');
