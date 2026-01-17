require "../spec_helper"

describe Markout::Handlers::ListsHandler do
  describe "unordered lists" do
    it "converts simple lists" do
      html = "<ul><li>One</li><li>Two</li></ul>"
      convert(html).should eq "- One\n- Two"
    end

    it "respects bullet_char option" do
      html = "<ul><li>One</li></ul>"
      convert(html, bullet_char: '*').should eq "* One"
    end
  end

  describe "ordered lists" do
    it "converts with numbers" do
      html = "<ol><li>First</li><li>Second</li></ol>"
      convert(html).should eq "1. First\n2. Second"
    end

    it "handles start attribute" do
      html = %(<ol start="5"><li>Fifth</li><li>Sixth</li></ol>)
      convert(html).should eq "5. Fifth\n6. Sixth"
    end
  end

  describe "nested lists" do
    it "indents nested items" do
      html = <<-HTML
        <ul>
          <li>One
            <ul>
              <li>Nested</li>
            </ul>
          </li>
        </ul>
      HTML
      result = convert(html)
      result.should contain "- One"
      result.should contain "  - Nested"
    end

    it "handles mixed list types" do
      html = <<-HTML
        <ul>
          <li>Bullet
            <ol>
              <li>Numbered</li>
            </ol>
          </li>
        </ul>
      HTML
      result = convert(html)
      result.should contain "- Bullet"
      result.should contain "  1. Numbered"
    end

    it "places nested list on its own line" do
      html = "<ul><li>Item<ul><li>Nested</li></ul></li></ul>"
      result = convert(html)
      result.should eq "- Item\n  - Nested"
    end

    it "handles multiple nested items correctly" do
      html = "<ul><li>Item 1<ul><li>A</li><li>B</li></ul></li><li>Item 2</li></ul>"
      result = convert(html)
      result.should eq "- Item 1\n  - A\n  - B\n- Item 2"
    end

    it "handles deeply nested lists" do
      html = "<ul><li>L1<ul><li>L2<ul><li>L3</li></ul></li></ul></li></ul>"
      result = convert(html)
      result.should eq "- L1\n  - L2\n    - L3"
    end
  end
end
