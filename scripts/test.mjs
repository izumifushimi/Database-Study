import assert from 'node:assert/strict';
import {readFile,stat} from 'node:fs/promises';
import initSqlJs from 'sql.js';
import {createRequire} from 'node:module';
const {assertDemoQuery}=createRequire(import.meta.url)('../web/query-guard.js');
const read=async n=>JSON.parse(await readFile(`content/${n}.json`,'utf8'));
const [course,quiz,labs,cases,homework]=await Promise.all(['course','quiz','labs','cases','homework'].map(read));
assert.equal(course.lessons.length,31);assert.equal(quiz.length,42);assert.equal(labs.length,10);assert.equal(homework.reduce((n,g)=>n+g.tasks.length,0),32);
for(const list of [course.modules,course.lessons,quiz,labs,cases,homework])assert.equal(new Set(list.map(x=>x.id)).size,list.length,'IDs must be unique');
for(const l of course.lessons){assert(course.modules.some(m=>m.id===l.module));assert(l.blocks.length>=3);}
for(const q of quiz){assert(q.options[q.answer]);assert(q.explanation.trim().length>0);}
for(const g of homework){assert(g.tasks.every(t=>t.code&&t.answer&&t.dataset));for(const s of g.schemas)assert((await stat(`docs/sql/${s}.sql`)).size>100);}
const SQL=await initSqlJs();const seed=await readFile('content/seed.sql','utf8');
for(const l of labs){const db=new SQL.Database();db.run('PRAGMA foreign_keys=ON;');db.run(seed);const r=db.exec(l.answer);assert.equal(r.length,1,l.id);assert(r[0].values.length>0,l.id+' must have observable results');db.close();}
const db=new SQL.Database();db.run('PRAGMA foreign_keys=ON;');db.run(seed);
assert.throws(()=>db.run("INSERT INTO SC VALUES('S01','C01',80)"));
assert.throws(()=>db.run("INSERT INTO SC VALUES('S05','C01',101)"));
assert.throws(()=>db.run("INSERT INTO SC VALUES('missing','C01',80)"));
assert.equal(db.exec("SELECT COUNT(*) FROM SC WHERE grade IS NULL")[0].values[0][0],1);
assert.equal(db.exec(labs[3].answer)[0].values.length,2,'highest grade preserves ties');
assert.equal(db.exec(labs[6].answer)[0].values.length,6,'left join preserves all students');
assert.equal(db.exec(labs[5].answer)[0].values[0][0],'S01','all courses division');
assert.deepEqual(db.exec(labs[8].answer)[0].values.find(r=>r[0]==='S05'),['S05',0]);
db.close();
// Run portable homework SELECTs / window views against SQLite with adapted MySQL DDL.
const schemas=new Map();
for(const name of ['construction','parcel','sales','library','ecommerce']){
 let sql=await readFile(`docs/sql/${name}.sql`,'utf8');
 sql=sql.replace(/CHAR_LENGTH/g,'LENGTH');
 sql=sql.replace(/BINARY LEFT\((\w+),4\)=BINARY ('[^']*')/g,'substr($1,1,4)=$2');
 const d=new SQL.Database();d.create_function('CONCAT',(...s)=>s.join(''));d.run('PRAGMA foreign_keys=ON;');d.run(sql);schemas.set(name,d);
}
let checked=0;
for(const g of homework)for(const t of g.tasks){if(!/^\s*(SELECT|CREATE VIEW)/.test(t.code))continue;const d=schemas.get(t.dataset);d.exec(t.code);checked++;}
const sales=schemas.get('sales');assert.equal(sales.exec('SELECT sold_qty FROM top_selling_products')[0].values[0][0],80,'sum sales by product');
const library=schemas.get('library');assert.equal(library.exec('SELECT n FROM top_single_reader_books')[0].values[0][0],5,'single loan sums all category lines');
assert.equal(library.exec('SELECT COUNT(*) FROM top_single_reader_categories')[0].values[0][0],2,'ties in category count preserved');
for(const d of schemas.values())d.close();
const teaching=[...course.lessons.flatMap(l=>l.blocks.filter(b=>b.type==='code').map(b=>b.code)),...cases.flatMap(c=>c.tasks.map(t=>t.code)),...homework.flatMap(g=>g.tasks.map(t=>t.code))].join('\n');
assert(!/VARCHAR2|NUMBER\(|%TYPE|%ROWTYPE|DBMS_OUTPUT|CREATE OR REPLACE PROCEDURE|:OLD\.|:NEW\.|RAISE_APPLICATION_ERROR|SQL%ROWCOUNT|ELSIF|FROM dual/i.test(teaching),'Teaching code must use MySQL syntax');
for(const l of course.lessons)for(const b of l.blocks)if(b.type==='code')assert(b.dialect.startsWith('MySQL'));
for(const l of labs)assertDemoQuery(l.answer);
for(const sql of ["SELECT 1; DROP TABLE Student;","/* comment */ PRAGMA foreign_keys=OFF","WITH x AS (SELECT 1) DELETE FROM Student;","CALL print_scores('S01');"])assert.throws(()=>assertDemoQuery(sql));
assertDemoQuery("SELECT 'DROP TABLE Student' AS label; -- SELECT only\n");
console.log(`PASS: content structure, ${labs.length} SQL labs, integrity/NULL/tie boundaries, ${checked} portable homework queries/views. All teaching examples use MySQL; native MySQL validation is provided separately.`);
