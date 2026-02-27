require "../spec_helper"

describe Markout::Handlers::EmphasisHandler do
  describe "bold text" do
    it "converts strong tag" do
      html = "<strong>bold text</strong>"
      convert(html).should eq "**bold text**"
    end

    it "converts b tag" do
      html = "<b>bold text</b>"
      convert(html).should eq "**bold text**"
    end

    it "uses custom strong character" do
      html = "<strong>bold</strong>"
      options = Markout::Options.new
      options.strong_char = "__"
      convert_with(html, options).should eq "__bold__"
    end
  end

  describe "italic text" do
    it "converts em tag" do
      html = "<em>italic text</em>"
      convert(html).should eq "*italic text*"
    end

    it "converts i tag" do
      html = "<i>italic text</i>"
      convert(html).should eq "*italic text*"
    end

    it "uses custom emphasis character" do
      html = "<em>italic</em>"
      options = Markout::Options.new
      options.emphasis_char = '_'
      convert_with(html, options).should eq "_italic_"
    end
  end

  describe "nested emphasis" do
    it "handles bold inside italic" do
      html = "<em>italic <strong>bold</strong> italic</em>"
      convert(html).should eq "*italic **bold** italic*"
    end

    it "handles italic inside bold" do
      html = "<strong>bold <em>italic</em> bold</strong>"
      convert(html).should eq "**bold *italic* bold**"
    end
  end

  describe "ignore emphasis option" do
    it "strips emphasis when ignore_emphasis is true" do
      html = "<strong>bold</strong> and <em>italic</em>"
      options = Markout::Options.new
      options.ignore_emphasis = true
      result = convert_with(html, options)
      result.should eq "bold and italic"
    end
  end

  describe "empty elements" do
    it "handles empty strong tag" do
      html = "<strong></strong>"
      convert(html).should eq "****"
    end

    it "handles empty em tag" do
      html = "<em></em>"
      convert(html).should eq "**"
    end
  end

  describe "whitespace handling" do
    it "trims whitespace from content" do
      html = "<strong>  text  </strong>"
      convert(html).should eq "**text**"
    end

    it "preserves internal whitespace" do
      html = "<em>two words</em>"
      convert(html).should eq "*two words*"
    end
  end
end
