import { readFileSync } from "node:fs";
import neo4j from "neo4j-driver";
let uri = process.argv[2]; if (!uri.startsWith("bolt")) uri = readFileSync(uri, "utf8").trim();
const db = process.argv[4] || "neo4j";
const driver = neo4j.driver(uri, neo4j.auth.none(), { disableLosslessIntegers: true });
const s = driver.session({ database: db });
const r = await s.run(process.argv[3]);
console.log(JSON.stringify(r.records.map(x => x.toObject()), null, 1));
await s.close(); await driver.close();
