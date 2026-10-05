// fx07 queries.
// Q07-1 (CQ-RC-05): source recommendations as derived projections with the speech act that licenses them.
MATCH (p:Person)-[r:RECOMMENDS]->(x)
MATCH (a:Assertion) WHERE a.uid IN r.derivedFromAssertionUids
RETURN p.name AS recommender, x.name AS recommended, r.derivationRule AS rule, a.speechAct AS licensingSpeechAct, a.valueString AS conditions;
