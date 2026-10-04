import org.neo4j.harness.Neo4j;
import org.neo4j.harness.Neo4jBuilders;
import java.nio.file.*;

public class EmbeddedNeo4j {
  public static void main(String[] args) throws Exception {
    Path dir = Paths.get(args.length > 0 ? args[0] : "run");
    Files.createDirectories(dir);
    Path stop = dir.resolve("STOP");
    Files.deleteIfExists(stop);
    Neo4j neo4j = Neo4jBuilders.newInProcessBuilder().withDisabledServer().build();
    try {
      Files.writeString(dir.resolve("bolt.uri"), neo4j.boltURI().toString());
      System.out.println("BOLT " + neo4j.boltURI());
      System.out.println("EDITION_INFO printed by client query");
      System.out.flush();
      while (!Files.exists(stop)) Thread.sleep(500);
    } finally {
      neo4j.close();
      System.out.println("STOPPED");
    }
  }
}
