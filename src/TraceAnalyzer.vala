using Gee;

/**
 * Trace analyzer parses Xdebug trace files and produces a report.
 */
public class XdebugTools.TraceAnalyzer : GLib.Object {

  protected int max;
  protected string sort;
  protected File file;
  //protected string[][];
  protected ArrayList<FunctionCall> stack;
  protected HashMap<string, FunctionReport> functions;
  
  protected bool _verbose = false;
  
  /**
   * Set the verbose flag.
   */
  public bool verbose {
    get { return this._verbose; }
    set {this._verbose = value; }
  }
  
  /**
   * 
   */
  public TraceAnalyzer(File file, string sort, int max) {
    this.file = file;
    this.sort = sort;
    this.max = max;
    
    this.stack = new ArrayList<FunctionCall>();
    this.functions = new HashMap<string, FunctionReport>();
  }
  
  /**
   * Parse the file.
   */
  public void parse_file() throws Error {
    string line;
    
    if (this.verbose) {
      stdout.printf("Parsing file...\n\n");
    }
    
    // Add the wrapper.
    var stack_item = new FunctionCall("<main>", 0, 0, 0, 0);
    this.stack.add(stack_item);
    
    var input = new DataInputStream(this.file.read());
    while ((line = input.read_line(null)) != null) {
      this.parse_line(line);
    }
  }
  
  /**
   * Get the results of a parsing run.
   */
  public ArrayList<FunctionReport> get_functions(string sort) {
    
    var sortable_list = new ArrayList<FunctionReport>();
    // Compute time and memory usage.
    foreach (var entry in this.functions.entries) {
      var function = entry.value;
      function.memory_own = function.memory_inclusive - function.memory_children;
      function.time_own = function.time_inclusive - function.time_children;
      sortable_list.add(function);
    }
    return sortable_list;
  }
  
  protected void parse_line(string line) {
    string [] parts = line.split("\t");
    
    // Short lines are for non-important details.
    if (parts.length < 5) {
      return;
    }
    
    int depth = parts[0].to_int();
    string func_nr = parts[1];
    int time = parts[3].to_int();
    int memory = parts[4].to_int();
    
    // Entering function
    if (parts[2] == "0") {
      string func_name = parts[5];
      string int_func = parts[6];
      
      var stack_item = new FunctionCall(func_name, time, memory, 0, 0);
      
      //stdout.printf("> %d %s\n", depth, func_name);
      
      if (this.stack.size >= depth + 1) {
        this.stack.set(depth, stack_item);
      }
      else {
        this.stack.add(stack_item);
      }
    }
    // Leaving function
    else if (parts[2] == "1") {
      
      //stdout.printf("< %d\n", depth);
      
      // We retrieve the already-set stack item.
      var stack_item = this.stack.get(depth);
      var parent_item = this.stack.get(depth -1);
      
      parent_item.nested_time += (time - stack_item.time);
      parent_item.nested_memory += (memory - stack_item.memory);
      
      this.add_to_function(stack_item);
    }
  }
  
  protected void add_to_function(FunctionCall func) {
    
    FunctionReport report;
    if (!this.functions.has_key(func.name)) {
      report = new FunctionReport(func.name);
      this.functions.set(func.name, report);
    }
    else {
      report = this.functions.get(func.name);
    }
    
    // Increment call counter.
    report.calls++;
    
    // Add data.
    if (this.function_is_in_stack(func.name)) {
      report.time_inclusive = func.time;
      report.time_children = func.nested_time;
      
      report.memory_inclusive = func.memory;
      report.memory_children = func.nested_memory;
    }
  }
  

  
  protected bool function_is_in_stack(string func_name) {
    
    // XXX: Might need to slice stack.
    int count = 0;
    int stack_size = this.stack.size;
    foreach (var stack_item in this.stack) {
      if (++count < stack_size && stack_item.name == func_name) return true;
    }
    return false;
  }
  



}

/**
 * Class describing a function call.
 */
public class XdebugTools.FunctionCall : GLib.Object {
  public string name;
  public int time;
  public int memory;
  public int nested_time;
  public int nested_memory;
  
  public FunctionCall(string name, int time, int memory, int nested_time, int nested_memory) {
    this.name = name;
    this.time = time;
    this.memory = memory;
    this.nested_time = nested_time;
    this.nested_memory = nested_memory;
  }
}

/**
 * Class describing how many times a function was run.
 */
public class XdebugTools.FunctionReport : GLib.Object {
  public int calls = 0;
  
  public int time_inclusive = 0;
  public int time_own = 0;
  public int time_children = 0;
  
  public int memory_inclusive = 0;
  public int memory_own = 0;
  public int memory_children = 0;
  
  public string name;
  
  public FunctionReport(string name) {
    this.name = name;
  }
}