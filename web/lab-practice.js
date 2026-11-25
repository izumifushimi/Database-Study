'use strict';
(function (root) {
  const limit = 1000000;
  function count(value, fallback) {
    return Number.isSafeInteger(value) && value >= 0 && value <= limit ? value : fallback;
  }
  function clean(value, labs) {
    const records = {};
    if (!value || typeof value !== 'object' || Array.isArray(value)) return records;
    for (const {id} of labs) {
      const entry = value[id];
      if (!entry || typeof entry !== 'object' || Array.isArray(entry)) continue;
      records[id] = {
        round: Math.max(1, count(entry.round, 1)),
        attempts: count(entry.attempts, 0),
        everPassed: entry.everPassed === true,
        previousSql: typeof entry.previousSql === 'string' && entry.previousSql.length <= 100000 ? entry.previousSql : ''
      };
    }
    return records;
  }
  function record(state, id) {
    return state.labPractice?.[id] || {
      round: 1, attempts: 0, everPassed: state.labDone[id] === true, previousSql: ''
    };
  }
  function restart(state, labs, ids, drafts = {}) {
    const targets = labs.filter(lab => ids.includes(lab.id));
    for (const lab of targets) {
      const sql = Object.hasOwn(drafts, lab.id) ? drafts[lab.id] : state.drafts[lab.id] ?? lab.starter;
      if (typeof sql !== 'string' || sql.length > 100000) throw Error('代码过长，请先保存到文件后再重练。');
    }
    state.labPractice ||= {};
    for (const lab of targets) {
      const current = record(state, lab.id);
      const sql = Object.hasOwn(drafts, lab.id) ? drafts[lab.id] : state.drafts[lab.id] ?? lab.starter;
      state.labPractice[lab.id] = {
        round: Math.min(limit, current.round + 1),
        attempts: 0,
        everPassed: current.everPassed || state.labDone[lab.id] === true,
        previousSql: sql.trim() && sql.trim() !== lab.starter.trim() ? sql : current.previousSql
      };
      state.drafts[lab.id] = lab.starter;
      delete state.labDone[lab.id];
    }
  }
  function grade(state, id, passed) {
    const current = record(state, id);
    state.labPractice ||= {};
    state.labPractice[id] = {...current, attempts: Math.min(limit, current.attempts + 1), everPassed: current.everPassed || state.labDone[id] === true || passed};
    if (passed) state.labDone[id] = true;
  }
  function restore(state, id) {
    const previous = record(state, id).previousSql;
    if (previous) state.drafts[id] = previous;
    return previous;
  }
  function passedCount(state, labs, historical = false) {
    return labs.filter(lab => state.labDone[lab.id] || (historical && record(state, lab.id).everPassed)).length;
  }
  const api = {clean, record, restart, grade, restore, passedCount};
  root.LabPractice = api;
  if (typeof module !== 'undefined') module.exports = api;
})(globalThis);
