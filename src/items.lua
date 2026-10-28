local plans={}
local gilBefore=g(u,'get_OwendGil')
for _,v in ipairs(items) do
 local n=quantity(v[1])
 plans[#plans+1]={id=v[1],name=v[2],before=n,target=math.max(n,v[3])}
 print('ITEM PLAN',v[1],v[2],n,'->',math.max(n,v[3]))
end
if not FF1_READ_ONLY then
 local client=instance('Last.Management','OwnedItemClient')
 local add=meth(cls('Last.Management','OwnedItemClient'),'AddOwnedItem','System.Int32,System.Int32')
 for _,v in ipairs(plans) do assert(quantity(v.id)==v.before,'Inventory changed; stop on the map and retry') end
 for _,v in ipairs(plans) do
  if v.target>v.before then call(add,client,{v.id,v.target-v.before}) end
  assert(quantity(v.id)==v.target,'Quantity verification failed: '..v.name)
  print('ITEM VERIFIED',v.id,v.name,v.target)
 end
 assert(g(u,'get_OwendGil')==gilBefore,'Gil changed unexpectedly')
end
print('ITEMS',#plans,'readonly',tostring(FF1_READ_ONLY))
