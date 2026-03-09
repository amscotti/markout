require "../spec_helper"

describe Markout::Handlers::TablesHandler do
  it "converts simple table" do
    html = "<table><tr><td>A</td><td>B</td></tr><tr><td>1</td><td>2</td></tr></table>"
    result = convert(html)
    result.should contain "| A | B |"
    result.should contain "|---|---|"
    result.should contain "| 1 | 2 |"
  end

  it "converts table with headers" do
    html = "<table><thead><tr><th>H1</th><th>H2</th></tr></thead><tbody><tr><td>D1</td><td>D2</td></tr></tbody></table>"
    result = convert(html)
    result.should contain "| H1 | H2 |"
    result.should contain "|---|---|"
    result.should contain "| D1 | D2 |"
  end

  it "escapes pipe characters and replaces newlines in cells" do
    html = "<table><tr><th>Name | Title</th><th>Value</th></tr><tr><td>A\nB</td><td>x | y</td></tr></table>"
    result = convert(html)
    result.should contain "| Name \\| Title | Value |"
    result.should contain "|---|---|"
    result.should contain "| A B | x \\| y |"
  end

  describe "block spacing" do
    it "adds trailing newlines after table to separate from following content" do
      html = "<table><tr><td>Cell</td></tr></table><p>After</p>"
      result = convert(html)
      result.should contain "| Cell |"
      result.should contain "|---|"
      result.should contain "After"
      # Should have blank line separator (2 newlines added by handler)
      result.should match(/\|---\|\s+After/)
    end
  end
end
