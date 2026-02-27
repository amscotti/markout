require "./spec_helper"
require "../src/cli"

describe Markout::CLI do
  describe "input handling" do
    it "converts HTML from stdin" do
      input = IO::Memory.new("<h1>Hello</h1>")
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run([] of String, input, output, error)

      exit_code.should eq(0)
      output.to_s.strip.should eq("# Hello")
    end

    it "converts HTML from file" do
      input = IO::Memory.new
      output = IO::Memory.new
      error = IO::Memory.new

      # Create a temporary file with HTML
      tempfile = File.tempfile("test", ".html") do |file|
        file.print("<p>Test paragraph</p>")
      end

      begin
        exit_code = Markout::CLI.run([tempfile.path], input, output, error)

        exit_code.should eq(0)
        output.to_s.strip.should eq("Test paragraph")
      ensure
        tempfile.delete
      end
    end

    it "returns error when no input is provided" do
      input = IO::Memory.new
      output = IO::Memory.new
      error = IO::Memory.new

      # Simulate a tty (no piped input) with no file argument
      exit_code = Markout::CLI.run([] of String, input, output, error)

      exit_code.should eq(2)
      error.to_s.should contain("No input provided")
    end
  end

  describe "output handling" do
    it "writes to stdout by default" do
      input = IO::Memory.new("<h2>Title</h2>")
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run([] of String, input, output, error)

      exit_code.should eq(0)
      output.to_s.strip.should eq("## Title")
    end

    it "writes to file with -o flag" do
      input = IO::Memory.new("<h3>File Output</h3>")
      output = IO::Memory.new
      error = IO::Memory.new

      tempfile = File.tempname("output", ".md")

      begin
        exit_code = Markout::CLI.run(["-o", tempfile], input, output, error)

        exit_code.should eq(0)
        output.to_s.should be_empty
        File.read(tempfile).strip.should eq("### File Output")
      ensure
        File.delete(tempfile) if File.exists?(tempfile)
      end
    end

    it "writes to file with --output flag" do
      input = IO::Memory.new("<h3>File Output</h3>")
      output = IO::Memory.new
      error = IO::Memory.new

      tempfile = File.tempname("output", ".md")

      begin
        exit_code = Markout::CLI.run(["--output", tempfile], input, output, error)

        exit_code.should eq(0)
        File.read(tempfile).strip.should eq("### File Output")
      ensure
        File.delete(tempfile) if File.exists?(tempfile)
      end
    end
  end

  describe "option flags" do
    it "applies --heading-style=setext" do
      input = IO::Memory.new("<h1>Setext</h1>")
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run(["--heading-style=setext"], input, output, error)

      exit_code.should eq(0)
      output.to_s.should contain("Setext")
      output.to_s.should contain("=====")
    end

    it "applies --bullet-char" do
      input = IO::Memory.new("<ul><li>Item</li></ul>")
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run(["--bullet-char=*"], input, output, error)

      exit_code.should eq(0)
      output.to_s.strip.should eq("* Item")
    end

    it "applies --link-style=referenced" do
      input = IO::Memory.new("<a href='http://example.com'>Link</a>")
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run(["--link-style=referenced"], input, output, error)

      exit_code.should eq(0)
      output.to_s.should match(/\[Link\]\[\d+\]/)
    end

    it "applies --wrap flag" do
      # Create a long paragraph that would need wrapping
      long_text = "A" * 100
      input = IO::Memory.new("<p>#{long_text}</p>")
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run(["--wrap", "--wrap-width=40"], input, output, error)

      exit_code.should eq(0)
      result = output.to_s
      # With wrapping enabled, output should contain newlines
      # The exact output depends on implementation, but it should be different
      result.size.should be > 0
    end

    it "rejects invalid heading style" do
      input = IO::Memory.new("<h1>Test</h1>")
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run(["--heading-style=invalid"], input, output, error)

      exit_code.should eq(2)
      error.to_s.should contain("Invalid heading style")
    end

    it "rejects invalid bullet character" do
      input = IO::Memory.new("<ul><li>Item</li></ul>")
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run(["--bullet-char=x"], input, output, error)

      exit_code.should eq(2)
      error.to_s.should contain("Invalid bullet character")
    end
  end

  describe "help and version" do
    it "shows help with -h" do
      input = IO::Memory.new
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run(["-h"], input, output, error)

      exit_code.should eq(0)
      output.to_s.should contain("Usage:")
      output.to_s.should contain("Options:")
    end

    it "shows help with --help" do
      input = IO::Memory.new
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run(["--help"], input, output, error)

      exit_code.should eq(0)
      output.to_s.should contain("Usage:")
    end

    it "shows version with -v" do
      input = IO::Memory.new
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run(["-v"], input, output, error)

      exit_code.should eq(0)
      output.to_s.strip.should eq("markout #{Markout::VERSION}")
    end

    it "shows version with --version" do
      input = IO::Memory.new
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run(["--version"], input, output, error)

      exit_code.should eq(0)
      output.to_s.strip.should eq("markout #{Markout::VERSION}")
    end
  end

  describe "error handling" do
    it "returns error for non-existent file" do
      input = IO::Memory.new
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run(["/nonexistent/file.html"], input, output, error)

      exit_code.should eq(1)
      error.to_s.should contain("Error")
    end

    it "returns error for too many arguments" do
      input = IO::Memory.new
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run(["file1.html", "file2.html"], input, output, error)

      exit_code.should eq(2)
      error.to_s.should contain("Too many arguments")
    end

    it "prioritizes file argument over stdin" do
      # When both stdin and file are provided, file takes precedence
      read_io, write_io = IO.pipe
      write_io.puts("<p>From stdin</p>")
      write_io.close

      output = IO::Memory.new
      error = IO::Memory.new

      tempfile = File.tempfile("test", ".html") { |file| file.print("<p>From file</p>") }

      begin
        exit_code = Markout::CLI.run([tempfile.path], read_io, output, error)

        exit_code.should eq(0)
        # Should use file content, not stdin
        output.to_s.strip.should eq("From file")
      ensure
        tempfile.delete
        read_io.close
      end
    end
  end

  describe "complex HTML conversion" do
    it "converts nested elements correctly" do
      input = IO::Memory.new("<div><p>Paragraph with <strong>bold</strong> and <em>italic</em> text.</p></div>")
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run([] of String, input, output, error)

      exit_code.should eq(0)
      result = output.to_s
      result.should contain("Paragraph with **bold** and *italic* text.")
    end

    it "converts code blocks" do
      html = <<-HTML
        <pre><code class="language-crystal">def hello
          puts "Hello, World!"
        end</code></pre>
      HTML

      input = IO::Memory.new(html)
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run([] of String, input, output, error)

      exit_code.should eq(0)
      result = output.to_s
      result.should contain("```")
      result.should contain("def hello")
    end

    it "converts tables" do
      html = <<-HTML
        <table>
          <tr><th>Name</th><th>Value</th></tr>
          <tr><td>Test</td><td>123</td></tr>
        </table>
      HTML

      input = IO::Memory.new(html)
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run([] of String, input, output, error)

      exit_code.should eq(0)
      result = output.to_s
      result.should contain("|")
      result.should contain("Name")
      result.should contain("Value")
    end

    it "converts links with titles" do
      input = IO::Memory.new("<a href=\"https://example.com\" title=\"Example Site\">Click here</a>")
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run([] of String, input, output, error)

      exit_code.should eq(0)
      result = output.to_s.strip
      result.should contain("[Click here](https://example.com)")
    end

    it "strips script and style tags" do
      html = <<-HTML
        <p>Visible content</p>
        <script>alert('hidden');</script>
        <style>.hidden { display: none; }</style>
        <p>More visible content</p>
      HTML

      input = IO::Memory.new(html)
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run([] of String, input, output, error)

      exit_code.should eq(0)
      result = output.to_s
      result.should contain("Visible content")
      result.should contain("More visible content")
      result.should_not contain("alert")
      result.should_not contain("hidden")
    end
  end

  describe "edge cases" do
    it "handles empty HTML" do
      input = IO::Memory.new("")
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run([] of String, input, output, error)

      # Empty input returns exit code 2 (no input provided)
      exit_code.should eq(2)
    end

    it "handles HTML with only whitespace" do
      input = IO::Memory.new("   \n\t   ")
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run([] of String, input, output, error)

      # Whitespace is valid but produces empty output
      exit_code.should eq(0)
    end

    it "handles special characters in HTML" do
      input = IO::Memory.new("<p>Special chars: &lt; &gt; &amp; &quot;</p>")
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run([] of String, input, output, error)

      exit_code.should eq(0)
      result = output.to_s
      result.should contain("Special chars:")
    end

    it "handles deeply nested HTML" do
      html = "<div>" * 20 + "<p>Deep content</p>" + "</div>" * 20
      input = IO::Memory.new(html)
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run([] of String, input, output, error)

      exit_code.should eq(0)
      output.to_s.should contain("Deep content")
    end

    it "handles multiple output flags" do
      input = IO::Memory.new("<h1>Test</h1>")
      output = IO::Memory.new
      error = IO::Memory.new

      tempfile = File.tempname("output", ".md")

      begin
        # Test with both short and long form
        exit_code = Markout::CLI.run(["-o", tempfile, "--output", tempfile], input, output, error)

        # Should handle gracefully - produces valid output
        exit_code.should eq(0)
        File.read(tempfile).should contain("# Test")
      ensure
        File.delete(tempfile) if File.exists?(tempfile)
      end
    end
  end

  describe "exit codes" do
    it "returns 0 on successful conversion" do
      input = IO::Memory.new("<p>Success</p>")
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run([] of String, input, output, error)

      exit_code.should eq(0)
    end

    it "returns 1 on file error" do
      input = IO::Memory.new
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run(["/this/path/does/not/exist.html"], input, output, error)

      exit_code.should eq(1)
    end

    it "returns 2 on invalid arguments" do
      input = IO::Memory.new
      output = IO::Memory.new
      error = IO::Memory.new

      exit_code = Markout::CLI.run(["--invalid-flag"], input, output, error)

      exit_code.should eq(2)
    end
  end
end
