require "./spec_helper"

describe Markout do
  describe ".convert" do
    it "converts plain text" do
      html = "Hello world"
      Markout.convert(html).should eq "Hello world"
    end

    it "converts simple heading" do
      html = "<h1>Title</h1>"
      Markout.convert(html).should eq "# Title"
    end

    it "converts paragraph" do
      html = "<p>This is a paragraph.</p>"
      Markout.convert(html).should eq "This is a paragraph."
    end

    it "converts bold text" do
      html = "<p>This is <strong>bold</strong> text.</p>"
      Markout.convert(html).should eq "This is **bold** text."
    end

    it "converts link" do
      html = %(<a href="https://example.com">Example</a>)
      Markout.convert(html).should eq "[Example](https://example.com)"
    end

    it "handles empty input" do
      Markout.convert("").should eq ""
    end
  end
end
