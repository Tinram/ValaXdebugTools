using Gee;


/**
 * A trace analyzer front-end that reads from a file.
 */
public class XdebugTools.TracefileAnalyzer : GLib.Object {
  public static bool verbose = false;
  public static int max_lines = 0;
  public static string sort_col = "calls";
  
  // Options used by main.
  const OptionEntry entries [] = {
    { "verbose", 'v', 0, OptionArg.NONE, out verbose, "Turn on verbose output.", null },
    { "max-lines", 'n', 0, OptionArg.INT, out max_lines, "Set the max number (N) of lines to print.", "N"},
    { "sort", 's', 0, OptionArg.STRING, out sort_col, "Name of the column to sort on.", "calls | time_own | memory_own | time_inclusive | memory_inclusive"},
    { null }
  };
  
  /**
   * Main entry point.
   */
  public static int main(string [] args) {
    
    // Setup and parse options
    var context = new OptionContext("filename.xt - parse a trace file and print a report");
    context.add_main_entries(entries, null);
    try {
      context.parse(ref args);
    } catch (OptionError oe) {
      stderr.printf("%s\n", oe.message);
      return 1;
    }
    
    // We need a filename
    if (args.length == 1) {
      stdout.printf("ERROR: Wrong number of arguments.\n\n");
      stdout.printf(context.get_help(true, null));
      return 1;
    }
    
    string file_name = args[1];
        
    var f = File.new_for_path(file_name);
    if (!f.query_exists()) {
      stdout.printf("FATAL ERROR: File %s does not exist.\n", file_name);
      return 1;
    }
    
    // Create a new tracer.
    var tracer = new TraceAnalyzer(f, TracefileAnalyzer.sort_col, TracefileAnalyzer.max_lines);
    if (TracefileAnalyzer.verbose) {
      tracer.verbose = true;
    }
    
    try {
      tracer.parse_file();
    } catch (Error e) {
      stderr.printf("%s", e.message);
      return 1;
    }
    
    var functions = tracer.get_functions(TracefileAnalyzer.sort_col);
    var report = new TraceAnalyzerReport(functions);
    
    report.write_report(TracefileAnalyzer.max_lines);
    
    return 0;
  }
}