require "./markout"
require "option_parser"

module Markout
  # Command-line interface for converting HTML to Markdown.
  class CLI
    EXIT_SUCCESS = 0
    EXIT_ERROR   = 1
    EXIT_INVALID = 2

    # Run the CLI with the given arguments and IO streams.
    def self.run(args : Array(String), input : IO, output : IO, error : IO) : Int32
      new(args, input, output, error).run
    end

    @output_file : String | Nil
    @input_file : String | Nil
    @show_help : Bool
    @show_version : Bool

    def initialize(@args : Array(String), @input : IO, @output : IO, @error : IO)
      @options = Options.new
      @output_file = nil
      @input_file = nil
      @show_help = false
      @show_version = false
    end

    # Main entry point - parses arguments and executes the conversion.
    def run : Int32
      parser = build_parser

      begin
        parser.parse(@args)
      rescue ex : OptionParser::InvalidOption
        @error.puts "Error: #{ex.message}"
        @error.puts
        @error.puts parser
        return EXIT_INVALID
      rescue ex : OptionParser::MissingOption
        @error.puts "Error: #{ex.message}"
        @error.puts
        @error.puts parser
        return EXIT_INVALID
      end

      # Handle explicit stdin request ("-") when no input file set
      @input_file = "-" if @input_file.nil? && @args.includes?("-")

      # Show help if requested
      if @show_help
        @output.puts parser
        return EXIT_SUCCESS
      end

      # Show version if requested
      if @show_version
        @output.puts "markout #{Markout::VERSION}"
        return EXIT_SUCCESS
      end

      # Read HTML input
      html = nil
      begin
        html = read_input
      rescue ex : File::NotFoundError
        @error.puts "Error: File not found - #{ex.message}"
        return EXIT_ERROR
      end

      if html.nil?
        @error.puts "Error: No input provided. Provide a file or use '-' for stdin."
        @error.puts
        @error.puts parser
        return EXIT_INVALID
      end

      # Convert to Markdown
      begin
        markdown = Markout.convert(html, @options)
      rescue ex : Exception
        @error.puts "Error: Conversion failed - #{ex.message}"
        return EXIT_ERROR
      end

      # Write output
      begin
        write_output(markdown)
      rescue ex : IO::Error | File::Error
        @error.puts "Error: Cannot write output - #{ex.message}"
        return EXIT_ERROR
      end

      EXIT_SUCCESS
    end

    private def build_parser : OptionParser
      OptionParser.new do |parser|
        parser.banner = <<-BANNER
          markout #{Markout::VERSION} - Convert HTML to Markdown

          Usage: markout [options] [file|-]
                 cat file.html | markout [options]

          Arguments:
            file    Input HTML file (default: read from stdin)
            -       Read HTML from stdin explicitly

          Options:
          BANNER

        parser.on("-o FILE", "--output FILE", "Output file (default: stdout)") do |file|
          @output_file = file
        end

        parser.on("--heading-style=STYLE", "Heading style: atx (default) or setext") do |style|
          case style.downcase
          when "atx"    then @options.heading_style = Options::HeadingStyle::ATX
          when "setext" then @options.heading_style = Options::HeadingStyle::Setext
          else
            raise OptionParser::InvalidOption.new("Invalid heading style: #{style}")
          end
        end

        parser.on("--bullet-char=CHAR", "Bullet character: - (default), *, or +") do |char|
          case char
          when "-", "*", "+"
            @options.bullet_char = char[0]
          else
            raise OptionParser::InvalidOption.new("Invalid bullet character: #{char}")
          end
        end

        parser.on("--link-style=STYLE", "Link style: inline (default) or referenced") do |style|
          case style.downcase
          when "inline"     then @options.link_style = Options::LinkStyle::Inline
          when "referenced" then @options.link_style = Options::LinkStyle::Referenced
          else
            raise OptionParser::InvalidOption.new("Invalid link style: #{style}")
          end
        end

        parser.on("--strip-document", "Strip HTML document wrapper (default: true)") do
          @options.strip_document = true
        end

        parser.on("--no-strip-document", "Don't strip HTML document wrapper") do
          @options.strip_document = false
        end

        parser.on("-h", "--help", "Show this help") do
          @show_help = true
        end

        parser.on("-v", "--version", "Show version") do
          @show_version = true
        end

        parser.unknown_args do |args|
          if args.size > 1
            raise OptionParser::InvalidOption.new("Too many arguments: #{args.join(", ")}")
          elsif args.size == 1
            @input_file = args[0]
          end
        end
      end
    end

    private def read_input : String?
      if input_file = @input_file
        if input_file == "-"
          # Explicit stdin request
          content = @input.gets_to_end
          content.empty? ? nil : content
        else
          # Read from file
          begin
            File.read(input_file)
          rescue ex : File::NotFoundError
            raise ex
          rescue ex : IO::Error
            @error.puts "Error: Cannot read file - #{ex.message}"
            nil
          end
        end
      else
        # Default to stdin when no input file is provided
        content = @input.gets_to_end
        content.empty? ? nil : content
      end
    end

    private def write_output(markdown : String)
      if output_file = @output_file
        File.write(output_file, markdown)
      else
        @output.puts markdown
      end
    end
  end
end
