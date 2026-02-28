require "../spec_helper"

describe Markout::Handlers::BlockquotesHandler do
  it "converts simple blockquote" do
    html = "<blockquote><p>Quote</p></blockquote>"
    convert(html).should eq "> Quote"
  end

  it "converts multiline blockquote" do
    html = "<blockquote><p>Line 1</p><p>Line 2</p></blockquote>"
    result = convert(html)
    result.should contain "> Line 1"
    result.should contain ">\n"
    result.should contain "> Line 2"
  end

  it "converts nested blockquote" do
    html = "<blockquote><p>Level 1</p><blockquote><p>Level 2</p></blockquote></blockquote>"
    result = convert(html)
    result.should contain "> Level 1"
    result.should contain "> > Level 2"
  end

  it "places nested blockquote on its own line" do
    html = "<blockquote>Outer<blockquote>Inner</blockquote></blockquote>"
    result = convert(html)
    result.should eq "> Outer\n> > Inner"
  end

  it "handles deeply nested blockquotes" do
    html = "<blockquote>L1<blockquote>L2<blockquote>L3</blockquote></blockquote></blockquote>"
    result = convert(html)
    result.should contain "> L1"
    result.should contain "> > L2"
    result.should contain "> > > L3"
  end

  describe "block spacing" do
    it "adds trailing newlines to separate from following content" do
      html = "<blockquote><p>Quote</p></blockquote><p>After</p>"
      result = convert(html)
      result.should eq "> Quote\n\nAfter"
    end

    it "adds trailing newlines after nested blockquote" do
      html = "<blockquote>Outer<blockquote>Inner</blockquote></blockquote><p>Text</p>"
      result = convert(html)
      result.should eq "> Outer\n> > Inner\n\nText"
    end
  end
end
