require "../spec_helper"

describe Markout::Handlers::HorizontalRulesHandler do
  it "converts hr to markdown" do
    html = "<hr>"
    convert(html).should contain "---"
  end

  it "adds newlines around hr" do
    html = "<p>Above</p><hr><p>Below</p>"
    result = convert(html)
    result.should contain "Above"
    result.should contain "---"
    result.should contain "Below"
    # Verify HR is on its own line
    result.should match /Above.*\n.*---.*\n.*Below/m
  end

  it "respects hr_style option" do
    html = "<hr>"
    options = Markout::Options.new
    options.hr_style = "***"
    result = Markout.convert(html, options)
    result.should contain "***"
  end
end
