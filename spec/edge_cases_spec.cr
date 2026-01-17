require "./spec_helper"

describe "Edge cases" do
  describe "deep nesting" do
    it "handles 100 nested divs" do
      html = "<div>" * 100 + "Deep content" + "</div>" * 100
      result = convert(html)
      result.should eq "Deep content"
    end

    it "handles 20 nested lists" do
      html = ""
      20.times { html += "<ul><li>Level" }
      html += "Deepest"
      20.times { html += "</li></ul>" }
      result = convert(html)
      result.should contain "Deepest"
    end

    it "handles 10 nested blockquotes" do
      html = ""
      10.times { html += "<blockquote>" }
      html += "Quoted"
      10.times { html += "</blockquote>" }
      result = convert(html)
      # Each level adds "> " so 10 levels = "> > > > > > > > > > "
      result.should contain "> > > > > > > > > > Quoted"
    end

    it "handles deeply nested formatting" do
      html = "<strong>" * 10 + "<em>" * 10 + "Text" + "</em>" * 10 + "</strong>" * 10
      result = convert(html)
      result.should contain "Text"
    end
  end

  describe "large tables" do
    it "handles table with 100 columns" do
      html = String.build do |io|
        io << "<table><tr>"
        100.times { |i| io << "<th>H#{i}</th>" }
        io << "</tr><tr>"
        100.times { |i| io << "<td>C#{i}</td>" }
        io << "</tr></table>"
      end
      result = convert(html)
      result.should contain "H0"
      result.should contain "H99"
      result.should contain "C50"
    end

    it "handles table with 500 rows" do
      html = String.build do |io|
        io << "<table><tr><th>A</th><th>B</th></tr>"
        500.times do |i|
          io << "<tr><td>R#{i}A</td><td>R#{i}B</td></tr>"
        end
        io << "</table>"
      end
      result = convert(html)
      result.should contain "R0A"
      result.should contain "R499A"
    end
  end

  describe "whitespace edge cases" do
    it "handles multiple consecutive spaces" do
      html = "<p>Word     with     spaces</p>"
      result = convert(html)
      # Whitespace normalization should collapse multiple spaces
      result.should_not contain "     "
    end

    it "handles tabs and newlines" do
      html = "<p>Line1\n\t\tLine2\nLine3</p>"
      result = convert(html)
      result.should contain "Line1"
      result.should contain "Line2"
      result.should contain "Line3"
    end

    it "handles empty elements between content" do
      html = "<p>Before</p><p></p><p></p><p>After</p>"
      result = convert(html)
      result.should contain "Before"
      result.should contain "After"
    end

    it "handles whitespace-only elements" do
      html = "<p>   </p><p>\n\t</p><p>Real content</p>"
      result = convert(html)
      result.should eq "Real content"
    end
  end

  describe "special content" do
    it "handles very long words" do
      long_word = "a" * 10000
      html = "<p>#{long_word}</p>"
      result = convert(html)
      result.size.should eq 10000
    end

    it "handles many links" do
      html = String.build do |io|
        io << "<p>"
        100.times { |i| io << "<a href=\"/#{i}\">Link#{i}</a> " }
        io << "</p>"
      end
      result = convert(html)
      result.should contain "[Link0](/0)"
      result.should contain "[Link99](/99)"
    end

    it "handles many images" do
      html = String.build do |io|
        io << "<div>"
        50.times { |i| io << "<img src=\"/img#{i}.jpg\" alt=\"Image #{i}\">" }
        io << "</div>"
      end
      result = convert(html)
      result.should contain "![Image 0](/img0.jpg)"
      result.should contain "![Image 49](/img49.jpg)"
    end

    it "handles code with special characters" do
      html = "<pre><code>if x < 10 && y > 5 {\n  return x * y;\n}</code></pre>"
      result = convert(html)
      result.should contain "x < 10"
      result.should contain "y > 5"
    end
  end

  describe "boundary conditions" do
    it "handles empty input" do
      convert("").should eq ""
    end

    it "handles single character" do
      convert("x").should eq "x"
    end

    it "handles single tag" do
      convert("<br>").should eq ""
    end

    it "handles only whitespace" do
      convert("   \n\t   ").should eq ""
    end

    it "handles only comments" do
      convert("<!-- comment -->").should eq ""
    end
  end
end
