// W23 scenario reset for the disposable embedded test database ONLY (never run against a shared database).
// Removes every node and the W23 leak-probe index so that each scenario starts from an empty graph.
MATCH (n) DETACH DELETE n;
DROP INDEX w23_leak_goal_search IF EXISTS;
