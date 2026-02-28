require "../spec_helper"

describe Markout::Handlers::LinksHandler do
  describe "inline links" do
    it "converts basic link" do
      html = %(<a href="https://example.com">Example</a>)
      convert(html).should eq "[Example](https://example.com)"
    end

    it "skips empty links with no text content" do
      html = %(<a href="https://example.com"></a>)
      convert(html).should eq ""
    end

    it "skips links with only whitespace" do
      html = %(<a href="https://example.com">   </a>)
      convert(html).should eq ""
    end

    it "preserves child content when link has no href" do
      html = %(<a>No href</a>)
      convert(html).should eq "No href"
    end
  end

  describe "reference links" do
    it "converts to reference style" do
      html = %(<p><a href="https://example.com">Example</a></p>)
      options = Markout::Options.new
      options.link_style = Markout::Options::LinkStyle::Referenced

      result = convert_with(html, options)

      result.should contain "[Example][1]"
      result.should contain "\n\n[1]: https://example.com"
    end

    it "handles multiple references" do
      html = %(<a href="u1">One</a> <a href="u2">Two</a>)
      options = Markout::Options.new
      options.link_style = Markout::Options::LinkStyle::Referenced

      result = convert_with(html, options)

      result.should contain "[One][1]"
      result.should contain "[Two][2]"
      result.should contain "[1]: u1"
      result.should contain "[2]: u2"
    end
  end
end
