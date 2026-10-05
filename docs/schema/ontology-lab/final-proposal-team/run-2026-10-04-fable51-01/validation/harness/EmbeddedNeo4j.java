import org.neo4j.harness.Neo4j;
import org.neo4j.harness.Neo4jBuilder;
import org.neo4j.harness.Neo4jBuilders;
import org.neo4j.configuration.GraphDatabaseSettings;
import java.nio.file.*;

public class EmbeddedNeo4j {
  public static void main(String[] args) throws Exception {
    Path dir = Paths.get(args.length > 0 ? args[0] : "run");
    Files.createDirectories(dir);
    Path stop = dir.resolve("STOP");
    Files.deleteIfExists(stop);
    Neo4jBuilder b = Neo4jBuilders.newInProcessBuilder().withDisabledServer();
    if (args.length > 1) {
      Path plugins = Paths.get(args[1]).toAbsolutePath();
      b = b.withConfig(GraphDatabaseSettings.plugin_dir, plugins)
           .withConfig(GraphDatabaseSettings.procedure_unrestricted, java.util.List.of("apoc.*"));
    }
    Neo4j neo4j = b.build();
    try {
      Files.writeString(dir.resolve("bolt.uri"), neo4j.boltURI().toString());
      System.out.println("BOLT " + neo4j.boltURI());
      System.out.flush();
      while (!Files.exists(stop)) Thread.sleep(500);
    } finally {
      neo4j.close();
      System.out.println("STOPPED");
    }
  }
}
