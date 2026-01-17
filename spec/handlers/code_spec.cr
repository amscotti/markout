require "../spec_helper"

describe Markout::Handlers::CodeHandler do
  it "converts inline code" do
    html = "<code>def foo; end</code>"
    convert(html).should eq "`def foo; end`"
  end

  it "converts pre block" do
    html = "<pre>def foo\n  bar\nend</pre>"
    result = convert(html)
    result.should contain "```"
    result.should contain "def foo\n  bar\nend"
  end

  it "converts pre code block" do
    html = "<pre><code>def foo\n  bar\nend</code></pre>"
    result = convert(html)
    # Should only have one set of fences
    result.scan("```").size.should eq 2 # Start and end
    result.should contain "def foo\n  bar\nend"
  end
end
