require "./spec_helper"

describe "Malformed HTML handling" do
  describe "unclosed tags" do
    it "handles unclosed paragraph" do
      html = "<p>Unclosed paragraph"
      result = convert(html)
      result.should contain "Unclosed paragraph"
    end

    it "handles unclosed bold" do
      html = "<p>Text with <strong>unclosed bold</p>"
      result = convert(html)
      result.should contain "unclosed bold"
    end

    it "handles unclosed list" do
      html = "<ul><li>Item 1<li>Item 2"
      result = convert(html)
      result.should contain "Item 1"
      result.should contain "Item 2"
    end

    it "handles unclosed nested tags" do
      html = "<div><p><strong>Deeply <em>nested"
      result = convert(html)
      result.should contain "nested"
    end
  end

  describe "mismatched tags" do
    it "handles mismatched closing tags" do
      html = "<p>Text</div>"
      result = convert(html)
      result.should contain "Text"
    end

    it "handles wrong nesting order" do
      html = "<strong><em>Bold italic</strong></em>"
      result = convert(html)
      result.should contain "Bold italic"
    end
  end

  describe "missing required attributes" do
    it "handles link without href" do
      html = "<a>Link text</a>"
      result = convert(html)
      result.should eq "Link text"
    end

    it "handles image without src" do
      html = "<img alt=\"Alt text\">"
      result = convert(html)
      result.should eq ""
    end
  end

  describe "invalid HTML" do
    it "handles text with random angle brackets" do
      html = "5 < 10 and 20 > 15"
      result = convert(html)
      result.should contain "5"
      result.should contain "10"
    end

    it "handles empty tags" do
      html = "<p></p><div></div><span></span>"
      result = convert(html)
      result.should eq ""
    end

    it "handles self-closing tags in wrong places" do
      html = "<p/>Text<br/>More"
      result = convert(html)
      result.should contain "Text"
      result.should contain "More"
    end

    it "handles comments" do
      html = "<p>Before<!-- comment -->After</p>"
      result = convert(html)
      result.should contain "Before"
      result.should contain "After"
    end

    it "handles CDATA sections" do
      html = "<p>Text<![CDATA[data]]>More</p>"
      result = convert(html)
      result.should contain "Text"
    end
  end

  describe "edge cases" do
    it "handles deeply nested structure" do
      html = "<div>" * 50 + "Content" + "</div>" * 50
      result = convert(html)
      result.should eq "Content"
    end

    it "handles extremely long lines" do
      long_word = "word" * 1000
      html = "<p>#{long_word}</p>"
      result = convert(html)
      result.should contain "word"
    end

    it "handles mixed valid and invalid" do
      html = "<h1>Valid</h1><invalidtag>Unknown</invalidtag><p>Also valid</p>"
      result = convert(html)
      result.should contain "# Valid"
      result.should contain "Unknown"
      result.should contain "Also valid"
    end
  end
end
