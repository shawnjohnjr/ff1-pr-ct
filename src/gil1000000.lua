local function field(c,n)
 for _,f in ipairs(mono_class_enumFields(c,true) or {}) do if f.name==n then return f end end
 error('Missing field '..n)
end
local sf=field(um,'saveData')
local save=readPointer(u+sf.offset)
local sc=cls('Last.Data.User','UserSaveData')
assert(save and save>65536 and readPointer(save)==sc,'Invalid save data')
local gf=field(sc,'owendGil');assert(gf.typename=='System.Int32','Invalid Gil field type')
local address=save+gf.offset
local before=readInteger(address)
assert(before and before>=0 and before<=9999999,'Invalid Gil')
if not FF1_READ_ONLY then
 assert(writeInteger(address,1000000),'Gil write failed')
 assert(readInteger(address)==1000000 and g(u,'get_OwendGil')==1000000,'Gil verification failed')
end
print('GIL VERIFIED',before,'->',readInteger(address))
