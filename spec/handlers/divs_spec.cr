require "../spec_helper"

describe Markout::Handlers::DivsHandler do
  describe "basic div handling" do
    it "adds newlines after div with text content" do
      html = %(<div>Feb 26, 2026</div><p>Paragraph</p>)
      result = Markout.convert(html)
      result.should contain "Feb 26, 2026"
      result.should contain "Paragraph"
      # Should have blank line between
      result.should match(/Feb 26, 2026\s+Paragraph/)
    end

    it "adds newlines after div with spans (breadcrumbs)" do
      html = %(
        <div>
          <span>Announcements</span>
          <span>Policy</span>
        </div>
        <h1>Title</h1>)
      result = Markout.convert(html)
      # Spans are stripped, div should be empty and skipped
      result.should eq "# Title"
    end

    it "handles div with block elements inside" do
      html = %(
        <div>
          <h2>Heading</h2>
          <p>Text</p>
        </div>
        <p>Outside</p>)
      result = Markout.convert(html)
      result.should contain "## Heading"
      result.should contain "Text"
      result.should contain "Outside"
    end
  end

  describe "nested divs" do
    it "handles deeply nested divs" do
      html = %(
        <div>
          <div>
            <div>Deep content</div>
          </div>
        </div>
        <p>After</p>)
      result = Markout.convert(html)
      result.should contain "Deep content"
      result.should contain "After"
    end

    it "handles date div in header structure" do
      # Simulates the Anthropic article structure
      html = %(
        <div class="header">
          <h1>Title</h1>
          <div class="date">Feb 26, 2026</div>
        </div>
        <div class="content">
          <p>Paragraph</p>
        </div>)
      result = Markout.convert(html)
      result.should contain "# Title"
      result.should contain "Feb 26, 2026"
      result.should contain "Paragraph"
      # All elements should be separated
      result.should match(/Title\s+Feb 26.*\s+Paragraph/m)
    end
  end

  describe "empty divs" do
    it "skips empty divs" do
      html = %(<div></div><p>Text</p>)
      result = Markout.convert(html)
      result.should eq "Text"
    end

    it "skips divs with only whitespace" do
      html = %(<div>   </div><p>Text</p>)
      result = Markout.convert(html)
      result.should eq "Text"
    end
  end

  describe "divs with mixed content" do
    it "handles div with text and block elements" do
      html = %(
        <div>
          Some text
          <p>Block paragraph</p>
          More text
        </div>)
      result = Markout.convert(html)
      result.should contain "Some text"
      result.should contain "Block paragraph"
      result.should contain "More text"
    end
  end
end
