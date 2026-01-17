require "../spec_helper"

describe Markout::Handlers::HeadingsHandler do
  describe "ATX style (default)" do
    it "converts h1" do
      convert("<h1>Title</h1>").should eq "# Title"
    end
    it "converts h6" do
      convert("<h6>Title</h6>").should eq "###### Title"
    end
  end

  describe "Setext style" do
    it "converts h1 with underline" do
      html = "<h1>Title</h1>"
      options = Markout::Options.new
      options.heading_style = Markout::Options::HeadingStyle::Setext

      convert_with(html, options).should eq "Title\n====="
    end

    it "converts h2 with underline" do
      html = "<h2>Subtitle</h2>"
      options = Markout::Options.new
      options.heading_style = Markout::Options::HeadingStyle::Setext

      convert_with(html, options).should eq "Subtitle\n--------"
    end

    it "uses ATX for h3+" do
      html = "<h3>Small</h3>"
      options = Markout::Options.new
      options.heading_style = Markout::Options::HeadingStyle::Setext

      convert_with(html, options).should eq "### Small"
    end

    it "underline matches heading length" do
      html = "<h1>A</h1>"
      options = Markout::Options.new
      options.heading_style = Markout::Options::HeadingStyle::Setext

      result = convert_with(html, options)
      # Minimum underline length is 3
      result.should eq "A\n==="
    end

    it "handles long headings" do
      html = "<h1>This is a very long heading title</h1>"
      options = Markout::Options.new
      options.heading_style = Markout::Options::HeadingStyle::Setext

      result = convert_with(html, options)
      lines = result.split("\n")
      lines[0].should eq "This is a very long heading title"
      lines[1].size.should eq lines[0].size
    end
  end

  describe "headings with formatting" do
    it "preserves links in headings" do
      html = "<h2><a href=\"/section\">Section</a></h2>"
      convert(html).should eq "## [Section](/section)"
    end

    it "preserves emphasis in headings" do
      html = "<h1><strong>Important</strong> Title</h1>"
      convert(html).should eq "# **Important** Title"
    end
  end
end
