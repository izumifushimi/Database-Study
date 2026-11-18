"""Compile all teaching SQL and check behavior against a native MySQL server.
Run with MYSQL_TEST_SOCKET, or MYSQL_TEST_HOST / MYSQL_TEST_PORT; uses disposable databases.
"""
import json, os, re, subprocess, time
from decimal import Decimal
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
os.chdir(ROOT)
args = [os.environ.get('MYSQL_BIN', 'mysql'), '--no-defaults', '--default-character-set=utf8mb4', '--batch', '--raw', '--skip-column-names', '-u', os.environ.get('MYSQL_TEST_USER', 'root')]
if os.environ.get('MYSQL_TEST_SOCKET'):
    args += ['--socket=' + os.environ['MYSQL_TEST_SOCKET']]
else:
    args += ['--protocol=TCP', '--host=' + os.environ.get('MYSQL_TEST_HOST', '127.0.0.1'), '--port=' + os.environ.get('MYSQL_TEST_PORT', '3306')]
env = os.environ.copy()
if env.get('MYSQL_TEST_PASSWORD'): env['MYSQL_PWD'] = env['MYSQL_TEST_PASSWORD']
prefix = 'codex_study_' + str(time.time_ns())
created = []
def run(sql, db=None, fail=False):
    inp = ('USE `' + db + '`;\n' if db else '') + sql
    p = subprocess.run(args, input=inp, text=True, capture_output=True, env=env, timeout=30)
    if fail:
        assert p.returncode, 'Expected database error: ' + sql
        return p.stderr
    if p.returncode: raise AssertionError(p.stderr + '\nSQL context:\n' + sql[:800])
    return p.stdout.strip()
def fresh(setup=''):
    name = prefix + '_' + str(len(created))
    run('CREATE DATABASE `' + name + '` CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;')
    created.append(name)
    if setup: run(setup, name)
    return name
load = lambda f: json.loads(Path('content/' + f + '.json').read_text())
try:
    version = run('SELECT VERSION();')
    assert version.split('.')[0] == '8', 'This check targets MySQL 8.x, got ' + version
    print('Native MySQL:', version, flush=True)
    seed = Path('content/seed.sql').read_text()
    course, cases, homework, labs = load('course'), load('cases'), load('homework'), load('labs')
    examples = 0
    # Each code block is independently compiled in its own matching sample database.
    for lesson in course['lessons']:
        for block in lesson['blocks']:
            if block['type'] != 'code': continue
            sql = block['code']
            if lesson['id'] == 'ddl-types': db = fresh()
            else:
                db = fresh(seed)
                if lesson['id'] == 'integrity': run('DROP TABLE SC;', db)
                if lesson['id'] == 'views' and sql.startswith('SELECT'):
                    run("CREATE VIEW CS_Student AS SELECT sno,sname,dept FROM Student WHERE dept='计算机' WITH CHECK OPTION;", db)
            run(sql, db)
            examples += 1
    db = fresh(Path('docs/mysql-course.sql').read_text())
    run(Path('docs/mysql-programming.sql').read_text(), db)
    assert Decimal(run("SELECT course_average('C01');",db)) == Decimal('80.67')
    assert run("SELECT course_average('C99') IS NULL;",db) == '1'
    assert run("CALL get_course_count('S01',@n); SELECT @n;",db) == '4'
    assert run("CALL get_course_count('missing',@n); SELECT @n;",db) == '0'
    assert '学生不存在' in run("CALL show_student('missing');",db)
    assert '无此学生' in run("CALL find_student('missing');",db)
    assert run('CALL loop_demo();',db).splitlines() == ['10','10','10']
    assert '1644' in run('CALL validate_grade(101);',db,fail=True)
    assert '1644' in run("CALL enroll('S01','C01');",db,fail=True)
    run("CALL enroll('S05','C01');",db)
    assert run("SELECT grade IS NULL FROM SC WHERE sno='S05' AND cno='C01';",db) == '1'
    assert '1452' in run("CALL enroll('missing','C01');",db,fail=True)
    # NULL-to-value, unchanged update, value-to-NULL; audit is transactional.
    run("UPDATE SC SET grade=85 WHERE sno='S04' AND cno='C01'; UPDATE SC SET grade=85 WHERE sno='S04' AND cno='C01'; UPDATE SC SET grade=NULL WHERE sno='S04' AND cno='C01';",db)
    assert run('SELECT COUNT(*) FROM GradeAudit;',db) == '2'
    run("START TRANSACTION; UPDATE SC SET grade=70 WHERE sno='S04' AND cno='C01'; ROLLBACK;",db)
    assert run('SELECT COUNT(*) FROM GradeAudit;',db) == '2'
    assert run("SELECT grade IS NULL FROM SC WHERE sno='S04' AND cno='C01';",db) == '1'
    book = fresh(Path('docs/sql/library-case.sql').read_text())
    run('CALL return_copy(1);',book)
    assert run('SELECT returned_at IS NOT NULL FROM Loan WHERE loan_id=1;',book) == '1'
    assert '1644' in run('CALL return_copy(1);',book,fail=True)
    payroll = fresh(Path('docs/sql/employee-case.sql').read_text())
    run("CALL raise_salary('D01',0.15);",payroll)
    assert Decimal(run("SELECT avg_salary('D01');",payroll)) == Decimal('1725')
    assert run('SELECT COUNT(*) FROM SalaryAudit;',payroll) == '2'
    assert '1644' in run("CALL raise_salary('D01',-0.1);",payroll,fail=True)
    # Compile each homework reference against its own dataset, including stored routines.
    tasks = 0
    for group in homework:
        for task in group['tasks']:
            sql=task['code']
            setup='' if re.search(r'^CREATE TABLE',sql,re.M) else Path('docs/sql/'+task['dataset']+'.sql').read_text()
            hdb=fresh(setup)
            run(sql,hdb)
            tasks += 1
    lab = fresh(seed)
    for l in labs:
        assert run(l['answer'],lab), 'Empty reference result: ' + l['id']
    assert len(run(labs[3]['answer'],lab).splitlines()) == 2
    assert len(run(labs[6]['answer'],lab).splitlines()) == 6
    assert '3819' in run("INSERT INTO SC VALUES('S05','C01',101);",lab,fail=True)
    assert '1062' in run("INSERT INTO SC VALUES('S01','C01',50);",lab,fail=True)
    print(f'PASS native MySQL: {examples} lesson examples, {tasks} homework answers, 3 complete case scripts, {len(labs)} lab references; OUT, zero-row, NULL, duplicate/FK/CHECK, audit and rollback behavior.', flush=True)
finally:
    for name in created:
        run('DROP DATABASE IF EXISTS `' + name + '`;')
