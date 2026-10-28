local target=1000000
local before=g(u,'get_OwendGil')
assert(type(before)=='number' and before==math.floor(before) and before>=0 and before<=9999999,'Invalid Gil')
local ic=cls('Last.Management','OwnedItemClient')
local add=meth(ic,'AddGil','System.Int32')
local remove=meth(ic,'RemoveGil','System.Int32')
print('GIL PLAN',before,'->',target)
if not FF1_READ_ONLY then
 local client=instance('Last.Management','OwnedItemClient')
 assert(g(u,'get_OwendGil')==before,'Gil changed; stop on the map and retry')
 if before<target then call(add,client,{target-before})
 elseif before>target then call(remove,client,{before-target}) end
 assert(g(u,'get_OwendGil')==target,'Gil verification failed')
 print('GIL VERIFIED',before,'->',target)
end
