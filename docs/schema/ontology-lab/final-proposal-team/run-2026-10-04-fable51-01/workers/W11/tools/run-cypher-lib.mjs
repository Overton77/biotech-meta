export function splitStatements(text) {
  // split on ';' outside of quotes, backticks and comments; keep preceding comment lines as the statement's header
  const out = []; let cur = ""; let i = 0; let inS = null; let inLine = false; let inBlock = false;
  while (i < text.length) {
    const c = text[i], n = text[i+1];
    if (inLine) { cur += c; if (c === "\n") inLine = false; i++; continue; }
    if (inBlock) { cur += c; if (c === "*" && n === "/") { cur += n; i += 2; inBlock = false; continue; } i++; continue; }
    if (inS) { cur += c; if (c === "\\" ) { cur += n; i += 2; continue; } if (c === inS) inS = null; i++; continue; }
    if (c === "/" && n === "/") { inLine = true; cur += c; i++; continue; }
    if (c === "/" && n === "*") { inBlock = true; cur += c; i++; continue; }
    if (c === "'" || c === '"' || c === "`") { inS = c; cur += c; i++; continue; }
    if (c === ";") { out.push(cur); cur = ""; i++; continue; }
    cur += c; i++;
  }
  if (cur.trim()) out.push(cur);
  return out.map(s => {
    const lines = s.split("\n");
    const header = lines.filter(l => l.trim().startsWith("//")).map(l => l.trim()).join("\n");
    const body = lines.filter(l => !l.trim().startsWith("//")).join("\n").trim();
    const idm = header.match(/\b([VCI]-\d{3}[a-z]?|QS-\d[a-z\-]*)\b/);
    return { id: idm ? idm[1] : null, header, body };
  }).filter(s => s.body.length > 0);
}
