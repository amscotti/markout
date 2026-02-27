require "../spec_helper"

describe Markout::Handlers::ParagraphsHandler do
  describe "paragraph elements" do
    it "converts p tag to paragraph" do
      html = "<p>This is a paragraph.</p>"
      # strip_document? strips trailing whitespace, so no \n\n at end
      convert(html).should eq "This is a paragraph."
    end

    it "handles multiple paragraphs" do
      html = "<p>First paragraph.</p><p>Second paragraph.</p>"
      result = convert(html)
      # strip_document? strips trailing newlines
      result.should contain "First paragraph."
      result.should contain "Second paragraph."
    end

    it "handles empty paragraph" do
      html = "<p></p>"
      # Empty paragraph results in whitespace that gets stripped
      convert(html).should eq ""
    end

    it "handles paragraph with nested elements" do
      html = "<p>Text with <strong>bold</strong> and <em>italic</em>.</p>"
      # strip_document? strips trailing newlines
      convert(html).should eq "Text with **bold** and *italic*."
    end

    it "handles paragraph with links" do
      html = %(<p>Visit <a href="https://example.com">Example</a> for more.</p>)
      convert(html).should eq "Visit [Example](https://example.com) for more."
    end

    it "handles paragraph with code" do
      html = "<p>Use the <code>print()</code> function.</p>"
      convert(html).should eq "Use the `print()` function."
    end
  end

  describe "line break elements" do
    it "converts br to two spaces and newline by default" do
      html = "Line one<br>Line two"
      convert(html).should eq "Line one  \nLine two"
    end

    it "converts br to backslash and newline when configured" do
      html = "Line one<br>Line two"
      options = Markout::Options.new
      options.newline_style = Markout::Options::NewlineStyle::Backslash
      convert_with(html, options).should eq "Line one\\\nLine two"
    end

    it "handles multiple br tags" do
      html = "Line one<br><br>Line two"
      convert(html).should eq "Line one  \n  \nLine two"
    end

    it "handles br inside paragraph" do
      html = "<p>Line one<br>Line two</p>"
      result = convert(html)
      result.should contain "Line one  \nLine two"
    end
  end

  describe "whitespace handling" do
    it "preserves text content with leading/trailing whitespace" do
      html = "<p>  text  </p>"
      # The text handler normalizes whitespace, but the paragraph preserves what it receives
      convert(html).should contain "text"
    end

    it "handles multiline paragraph" do
      html = "<p>Line one
Line two</p>"
      # Whitespace is normalized by text handler
      result = convert(html)
      result.should contain "Line one"
      result.should contain "Line two"
    end
  end

  describe "edge cases" do
    it "handles paragraph with only whitespace" do
      html = "<p>   </p>"
      result = convert(html)
      # Whitespace-only content gets stripped to empty
      result.should eq ""
    end

    it "handles nested paragraphs" do
      # Invalid HTML but should handle gracefully
      html = "<p>Outer <p>Inner</p> Outer</p>"
      result = convert(html)
      # Should process both paragraphs
      result.should contain "Inner"
    end
  end
end
