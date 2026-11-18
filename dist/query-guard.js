'use strict';
// The browser demo executes only a read-only subset shared with MySQL.
// Ignore comments and quoted values before recognizing statement keywords.
function assertDemoQuery(sql) {
  const stripped = sql.replace(/'(?:''|\\.|[^'\\])*'|"(?:""|\\.|[^"\\])*"|`(?:``|[^`])*`|\/\*[\s\S]*?\*\/|--[^\n]*|#[^\n]*/g, ' ');
  const words = stripped.match(/[A-Za-z_][A-Za-z_0-9]*/g) || [];
  const forbidden = /^(?:CREATE|INSERT|UPDATE|DELETE|REPLACE|DROP|ALTER|PRAGMA|ATTACH|DETACH|BEGIN|COMMIT|ROLLBACK|VACUUM|ANALYZE|REINDEX|SAVEPOINT|RELEASE|TRIGGER|PROCEDURE|FUNCTION|DELIMITER|CALL|GRANT|REVOKE|SET|INTO)$/i;
  if (!words.length || !/^(SELECT|WITH)$/i.test(words[0]) || words.some(w => forbidden.test(w))) {
    throw Error('浏览器仅演示通用 SELECT / WITH 查询。建表、数据修改、存储过程、函数与触发器请下载脚本，在 MySQL 8.0.16+ 中执行。');
  }
}
if (typeof module !== 'undefined') module.exports = {assertDemoQuery};
