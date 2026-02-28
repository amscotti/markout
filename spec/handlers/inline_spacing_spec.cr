require "../spec_helper"

describe "Inline element spacing" do
  describe "emphasis handler" do
    it "adds space after bold when followed by text without space in HTML" do
      # HTML: <strong>Label.</strong>Content (no space between </strong> and Content)
      # Expected: **Label.** Content (with space)
      html = "<p><strong>Label.</strong>Content</p>"
      result = Markout.convert(html)
      result.should eq("**Label.** Content")
    end

    it "adds space after italic when followed by text without space" do
      html = "<p><em>Label.</em>Content</p>"
      result = Markout.convert(html)
      result.should eq("*Label.* Content")
    end

    it "does not add extra space when space already exists in HTML" do
      # HTML: <strong>Label.</strong> Content (space exists)
      # Expected: **Label.** Content (no double space)
      html = "<p><strong>Label.</strong> Content</p>"
      result = Markout.convert(html)
      result.should eq("**Label.** Content")
    end

    it "does not add space when next element is another inline element" do
      # HTML: <strong>Bold</strong><em>italic</em>
      # Expected: **Bold***italic* (no space between inline elements)
      html = "<p><strong>Bold</strong><em>italic</em></p>"
      result = Markout.convert(html)
      result.should eq("**Bold***italic*")
    end

    it "does not add space when followed by punctuation" do
      # HTML: <strong>Important</strong>.
      # Expected: **Important**. (no space before period)
      html = "<p><strong>Important</strong>.</p>"
      result = Markout.convert(html)
      result.should eq("**Important**.")
    end
  end

  describe "links handler" do
    it "adds space after link when followed by text without space" do
      html = %(<p><a href="http://example.com">Link</a>Next word</p>)
      result = Markout.convert(html)
      result.should eq("[Link](http://example.com) Next word")
    end

    it "does not add extra space when space already exists" do
      html = %(<p><a href="http://example.com">Link</a> Next word</p>)
      result = Markout.convert(html)
      result.should eq("[Link](http://example.com) Next word")
    end

    it "does not add space when next element is punctuation" do
      html = %(<p><a href="http://example.com">Link</a>.</p>)
      result = Markout.convert(html)
      result.should eq("[Link](http://example.com).")
    end

    it "does not add space when next element is an inline element" do
      html = %(<p><a href="http://example.com">Link</a><em>emphasis</em></p>)
      result = Markout.convert(html)
      result.should eq("[Link](http://example.com)*emphasis*")
    end
  end

  describe "images handler" do
    it "adds space after image when followed by text without space" do
      html = %(<p><img src="pic.jpg" alt="Pic">Text after</p>)
      result = Markout.convert(html)
      result.should eq("![Pic](pic.jpg) Text after")
    end

    it "does not add space when followed by punctuation" do
      html = %(<p><img src="pic.jpg" alt="Pic">.</p>)
      result = Markout.convert(html)
      result.should eq("![Pic](pic.jpg).")
    end
  end

  describe "code handler (inline)" do
    it "adds space after inline code when followed by text without space" do
      html = "<p><code>code</code>Next word</p>"
      result = Markout.convert(html)
      result.should eq("`code` Next word")
    end

    it "does not add space when followed by punctuation" do
      html = "<p><code>code</code>.</p>"
      result = Markout.convert(html)
      result.should eq("`code`.")
    end
  end

  describe "strikethrough handler" do
    it "adds space after strikethrough when followed by text without space" do
      html = "<p><del>deleted</del>Next word</p>"
      result = Markout.convert(html)
      result.should eq("~~deleted~~ Next word")
    end
  end

  describe "complex scenarios" do
    it "handles mixed inline elements correctly" do
      html = %(<p><strong>Bold.</strong>Text <em>italic.</em>More <a href="http://x.com">link.</a>End</p>)
      result = Markout.convert(html)
      result.should eq("**Bold.** Text *italic.* More [link.](http://x.com) End")
    end

    it "handles image link followed by text link (author pattern)" do
      html = %(<p><a href="/author/"><img src="pic.jpg" alt="Author"></a><a href="/author/">Author Name</a></p>)
      result = Markout.convert(html)
      # Note: No space between consecutive links since they're both inline elements
      result.should eq("[![Author](pic.jpg)](/author/)[Author Name](/author/)")
    end
  end
end
