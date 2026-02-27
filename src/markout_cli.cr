# CLI entry point - requires the CLI class and executes it
require "./cli"

exit Markout::CLI.run(ARGV, STDIN, STDOUT, STDERR)
