local sm=cls('Last.Management','StatusUpProviderInstanceManager')
local mgr=call(meth(sm,'Instance',''))
local provider=g(mgr,'GetCurrentProvider')
assert(readPointer(provider)==cls('Serial.FF1.Management','StatusUpProvider'),'Wrong game level-up provider')
local add=meth(cls('Last.Management','OwnedCharacterClient'),'AddExp','System.Int32,System.Int32,System.Int32')
local execute=meth(cls('Serial.FF1.Management','StatusUpProvider'),'Execution','Last.Data.User.OwnedCharacterData,System.Int32,Last.Battle.BattleSkillUpInformation')
local targetExp=1471455
for _,ch in ipairs(party) do
 assert(g(ch.object,'GetExpTableGroupId')==1,'Unsupported EXP table')
 ch.xp=g(ch.object,'get_CurrentExp')
 assert(type(ch.xp)=='number' and ch.xp>=0 and ch.xp<=9999999,'Invalid EXP')
 print('LEVEL PLAN',ch.id,'job',ch.job,'level',ch.level,'EXP',ch.xp,'target',targetExp)
end
if not FF1_READ_ONLY then
 local client=instance('Last.Management','OwnedCharacterClient')
 for _,ch in ipairs(party) do
  if ch.level<99 then
   assert(ch.xp<targetExp,'EXP and level disagree; reload the save')
   local updated=call(add,client,{ch.id,targetExp-ch.xp,12345})
   assert(type(updated)=='number' and updated>65536 and readPointer(updated)==cc,'Invalid EXP result')
   updated=call(execute,provider,{updated,12345,0})
   assert(type(updated)=='number' and updated>65536 and readPointer(updated)==cc,'Invalid growth result')
   g(client,'SetOwnedCharacter',{updated},'Last.Data.User.OwnedCharacterData')
  end
  local updated=g(u,'GetMemberData',{ch.slot},'System.Int32')
  g(updated,'UpdateParameter')
  assert(g(updated,'get_Id')==ch.id and g(updated,'get_JobId')==ch.job,'Character or job changed')
  local p=g(updated,'get_Parameter')
  assert(g(p,'ConfirmedLevel')==99 and g(updated,'get_CurrentExp')>=targetExp,'Level verification failed')
  print('LEVEL VERIFIED',ch.id,99,'HP',g(p,'ConfirmedMaxHp'))
 end
end
print('LEVEL99',#party,'readonly',tostring(FF1_READ_ONLY))
