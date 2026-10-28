from pathlib import Path
import csv, re, xml.etree.ElementTree as E

PROJECT=Path(__file__).resolve().parent
OUT=PROJECT
SRC=PROJECT/'src'
common=(SRC/'common.lua').read_text()
rows=list(csv.DictReader((PROJECT/'equipment.csv').open()))
ids=[int(r['content_id']) for r in rows]
names={int(r['content_id']):r['繁中名稱'] for r in rows}
names[8]='萬靈藥'
def name(i):return names[i]
def item_body(ids,target):
 return 'local items={\n'+''.join('{%d,"%s",%d},\n'%(i,name(i),target) for i in ids)+'}\n'+(SRC/'items.lua').read_text()
entries=[('Level99','全隊 Lv99（正常升級成長，保留職業）',(SRC/'level99.lua').read_text()),
 ('TopEquipment','畢業裝備包：29 種各補至 4 件（加入背包）',item_body(ids,4)),
 ('Elixir99','萬靈藥補至 99 個',item_body([8],99)),
 ('Gil1000000','金錢設為 1,000,000 Gil',(SRC/'gil1000000.lua').read_text())]
def create(entries,path):
 root=E.Element('CheatTable',CheatEngineTableVersion='45');es=E.SubElement(root,'CheatEntries')
 for i,(key,title,body) in enumerate(entries,1):
  e=E.SubElement(es,'CheatEntry');E.SubElement(e,'ID').text=str(i)
  E.SubElement(e,'Description').text='"'+title+'／地圖上執行一次"'
  E.SubElement(e,'VariableType').text='Auto Assembler Script'
  E.SubElement(e,'AssemblerScript').text='[ENABLE]\n{$lua}\nif syntaxcheck then return end\nlocal FF1_READ_ONLY=false\n'+common+'\n'+body+'\nshowMessage("已完成並回讀核對。請重開選單確認，另存新欄位。取消勾選不會還原。")\n{$asm}\n[DISABLE]\n'
 E.SubElement(root,'UserdefinedSymbols');E.indent(root);E.ElementTree(root).write(path,encoding='utf-8',xml_declaration=True)
create(entries,OUT/'FF1_PR_20249397.CT')
for e in entries:create([e],OUT/('FF1_PR_'+e[0]+'_20249397.CT'))
print('Built combined CT and 4 independent CTs; 29 equipment types; build 20249397')
