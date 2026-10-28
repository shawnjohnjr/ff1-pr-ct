assert(getOpenedProcessID()~=0,'Attach to FINAL FANTASY.exe first')
local base=getAddressSafe('GameAssembly.dll');assert(base,'GameAssembly.dll missing')
local pe=base+readInteger(base+60)
assert(readInteger(pe+8)==1738582778 and readInteger(pe+80)==38342656,'Requires FF1 PR Steam build 20249397')
local launched=LaunchMonoDataCollector();assert(launched and launched~=0,'Mono collector unavailable')
local classes,methods={},{ }
local function cls(ns,n)
 local key=ns..'.'..n
 if not classes[key] then local c=mono_findClass(ns,n);assert(c and c~=0,'Class missing: '..key);classes[key]=c end
 return classes[key]
end
local function meth(c,n,sig)
 local key=tostring(c)..':'..n..':'..sig
 if methods[key] then return methods[key] end
 local current=c
 while current and current~=0 do
  for _,m in ipairs(mono_class_enumMethods(current) or {}) do
   if m.name==n and mono_method_getSignature(m.method)==sig then methods[key]=m.method;return m.method end
  end
  current=mono_class_getParent(current)
 end
 error('Missing method '..n..' ('..sig..')')
end
local function call(m,o,args)
 local r,e=mono_invoke_method(0,m,o or 0,args or {});assert(e==nil,tostring(e));return r
end
local function g(o,n,args,sig)
 assert(type(o)=='number' and o>65536,'Invalid object for '..n)
 return call(meth(mono_object_getClass(o),n,sig or ''),o,args)
end
local function instance(ns,n)
 local c=cls(ns,n);local o=mono_object_new(c)
 assert(type(o)=='number' and o>65536 and readPointer(o)==c,'Cannot create '..n)
 call(meth(c,'.ctor',''),o);return o
end
local um=cls('Last.Management','UserDataManager')
local u=call(meth(um,'Instance',''))
assert(type(u)=='number' and u>65536 and readPointer(u)==um,'Load your FF1 save first')
local cc=cls('Last.Data.User','OwnedCharacterData')
local pc=cls('Last.Data','PlayerCharacterParameter')
local party={};local seen={}
for i=0,3 do
 local ch=g(u,'GetMemberData',{i},'System.Int32')
 assert(type(ch)=='number' and ch>65536 and readPointer(ch)==cc,'Four loaded party members required')
 local id=g(ch,'get_Id');local job=g(ch,'get_JobId')
 assert(type(id)=='number' and id>=1 and not seen[id],'Invalid or duplicate party ID')
 assert(type(job)=='number' and job>=1 and job<=12,'Invalid FF1 job')
 local p=g(ch,'get_Parameter');assert(readPointer(p)==pc,'Invalid character parameter')
 local lv=g(p,'ConfirmedLevel');assert(type(lv)=='number' and lv>=1 and lv<=99,'Invalid level')
 seen[id]=true;party[#party+1]={slot=i,id=id,job=job,object=ch,level=lv}
end
local function quantity(id)
 local o=g(u,'SearchOwnedItem',{id},'System.Int32')
 assert(type(o)=='number','Invalid item response')
 if o==0 then return 0 end
 assert(o>65536 and readPointer(o)==cls('Last.Data.User','OwnedItemData'),'Invalid item object')
 assert(g(o,'get_ContentId')==id,'Item ID mismatch')
 local n=g(o,'get_Count');assert(type(n)=='number' and n>=0 and n<=99,'Invalid item count')
 return n
end
