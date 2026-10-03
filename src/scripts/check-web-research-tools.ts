import { spawn } from "node:child_process";

type Check = {
  name: string;
  command: string;
  args: string[];
};

const checks: Check[] = [
  { name: "Firecrawl CLI help", command: "firecrawl", args: ["--help"] },
  { name: "Firecrawl auth/status", command: "firecrawl", args: ["--status"] },
  { name: "Tavily CLI help", command: "tvly", args: ["--help"] },
  { name: "Tavily auth/status", command: "tvly", args: ["--status"] },
];

function runCheck(check: Check): Promise<boolean> {
  return new Promise((resolve) => {
    const child = spawn(check.command, check.args, {
      shell: process.platform === "win32",
      stdio: ["ignore", "pipe", "pipe"],
    });

    let output = "";

    child.stdout.on("data", (chunk: Buffer) => {
      output += chunk.toString();
    });

    child.stderr.on("data", (chunk: Buffer) => {
      output += chunk.toString();
    });

    child.on("error", (error) => {
      console.error(`FAIL ${check.name}: ${error.message}`);
      resolve(false);
    });

    child.on("close", (code) => {
      const firstLines = output
        .split(/\r?\n/)
        .map((line) => line.trim())
        .filter(Boolean)
        .slice(0, 6);

      if (code === 0) {
        console.log(`PASS ${check.name}`);
      } else {
        console.error(`FAIL ${check.name} exited with code ${code ?? "unknown"}`);
      }

      for (const line of firstLines) {
        console.log(`  ${line}`);
      }

      resolve(code === 0);
    });
  });
}

let allPassed = true;

for (const check of checks) {
  const passed = await runCheck(check);
  allPassed = allPassed && passed;
}

if (!allPassed) {
  process.exitCode = 1;
}
