require "../spec_helper"

describe Markout::Handlers::StrikethroughHandler do
  it "converts s tag" do
    html = "<s>deleted</s>"
    convert(html).should eq "~~deleted~~"
  end

  it "converts del tag" do
    html = "<del>deleted</del>"
    convert(html).should eq "~~deleted~~"
  end

  it "converts strike tag" do
    html = "<strike>deleted</strike>"
    convert(html).should eq "~~deleted~~"
  end

  it "respects custom strikethrough characters" do
    html = "<del>deleted</del>"
    options = Markout::Options.new
    options.strikethrough_char = "~~!"

    convert_with(html, options).should eq "~~!deleted~~!"
  end
end
