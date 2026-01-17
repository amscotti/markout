require "../spec_helper"

describe Markout::Handlers::TextHandler do
  it "collapses whitespace in normal text" do
    html = "<p>Hello   World</p>"
    convert(html).should eq "Hello World"
  end

  it "converts newlines to spaces" do
    html = "<p>Hello\nWorld</p>"
    convert(html).should eq "Hello World"
  end

  it "preserves whitespace in pre/code" do
    html = "<pre>  Hello\n  World</pre>"
    convert(html).should contain "  Hello\n  World"
  end
end
