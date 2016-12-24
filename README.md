
# Vala Xdebug Tools

This package has tools that are useful for parsing Xdebug trace file data.

(If you are not sure how to collect Xdebug trace data, see the section 'Collecting Data with Xdebug' below.)


## Installation

Install the Vala environment.

Mac OS X: `brew install vala libgee`

Linux: use the package manager to search for 'vala'.

Compile:

```
    valac --pkg gio-2.0 --pkg gee-0.8 src/*.vala -o trace_analyzer
```

or:

```
    make build
```

Run:

```
    ./trace_analyzer trace_file.xt
```


## Usage

The trace analyzer has a number of features. In its basic form, it
simply prints performance data about time and memory usage in a trace
file.

To get an idea as to how it works, try:

    trace_analyzer --help


## CSV Output

By running `trace_analyzer -c some_file`, you can generate CSV output.
This explains the columns.

Columns of output:

* function: Name of the function called
* calls: Number of times the function was called
* time_inclusive: Aggregated time for calling this function and all
  children functions
* memory_inclusive: Aggregated memory for calling this function
* time_own: Aggregated time for calling this function, MINUS the
  aggregated time for calling its children
* memory_own: Aggregated memory for this function, MINUS the aggregated
  memory of children functions
* time_own_min: The fastest this function was executed
* time_own_max: The slowest this function executed
* time_own_avg: The average time it took to execute the function
* memory_own_min: The minimum amount of memory this required to run
* memory_own_max: The maximum amount of memory this required to run
* memory_own_avg: The average memory consumed by this function

Note that memory numbers are somewhat suspect because of PHP's garbage
collection, which may deallocate memory between function entry and
function exit, essentially creating a negative memory usage number.


## Collecting Data with Xdebug

Example `php.ini` config for Xdebug:

```ini
xdebug.auto_trace = 1
xdebug.trace_format = 1
xdebug.trace_output_name = php-trace.%t
```

The second one is the most important: Set the tracing format to 1.


## Developers: Build Your Own Trace Tools

Included in this tool is a straightforward library for building your own
tracefile analyzers. In a nutshell, here's how you do it:

1. Create a class that extends XdebugTools.TraceObserver
2. Write a simple wrapper that creates a new XdebugTools.TraceParser()
3. Register your observer (e.g.
`trace_parser.register(my_trace_observer)`)
4. Parse the file (e.g. `trace_parser.parse()`)


### Why Vala?

Why is this tool written in Vala and not PHP? There are two reasons:

1. Vala is compiled to a native executable, and is thus substantially faster than its PHP equivalent. This is important for larger trace files.
2. The author (technosophos) regards Vala as a fantastic language.


## Acknowledgements

Thanks to Derick Rethans, who [posted a PHP
tool](http://derickrethans.nl/xdebug-and-tracing-memory-usage.html) for
parsing Xdebug trace files.

## Platforms

This program was written and originally tested on Mac OS X using the
[homebrew](https://github.com/mxcl/homebrew) package of Vala and Gee. It
was written in TextMate using the [Vala
bundle](https://github.com/technosophos/Vala-TMBundle).

Compiled and tested (Tinram, 2016) on Debian-based Linux, using Vala 0.16.1
