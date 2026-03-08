require "../spec_helper"

describe Markout::Handlers::StripHandler do
  describe "script elements" do
    it "removes script tags completely" do
      html = %(<p>Text</p><script>alert("xss")</script><p>More</p>)
      result = convert(html)
      result.should contain "Text"
      result.should contain "More"
      result.should_not contain "script"
      result.should_not contain "alert"
    end

    it "removes script tags with src attribute" do
      html = %(<script src="evil.js"></script><p>Safe content</p>)
      result = convert(html)
      # strip_document? strips trailing newlines
      result.should eq "Safe content"
    end

    it "removes script tags with type attribute" do
      html = %(<script type="text/javascript">var x = 1;</script><p>Text</p>)
      result = convert(html)
      result.should_not contain "var x"
      result.should contain "Text"
    end

    it "removes multiple script tags" do
      html = %(<script>1</script><p>A</p><script>2</script><p>B</p><script>3</script>)
      result = convert(html)
      result.should_not contain "1"
      result.should_not contain "2"
      result.should_not contain "3"
      result.should contain "A"
      result.should contain "B"
    end
  end

  describe "style elements" do
    it "removes style tags" do
      html = %(<style>body { color: red; }</style><p>Text</p>)
      result = convert(html)
      result.should_not contain "style"
      result.should_not contain "color: red"
      result.should contain "Text"
    end

    it "removes style tags in head" do
      html = %(<head><style>.class { font-size: 12px; }</style></head><body><p>Text</p></body>)
      result = convert(html)
      result.should_not contain "font-size"
      result.should contain "Text"
    end
  end

  describe "noscript elements" do
    it "removes noscript tags" do
      html = %(<noscript>Please enable JavaScript</noscript><p>Text</p>)
      result = convert(html)
      result.should_not contain "noscript"
      # Note: HTML parsers put noscript content in body as text
      # This is standard HTML parsing behavior
      result.should contain "Text"
    end
  end

  describe "metadata elements" do
    it "removes head element" do
      html = %(<head><title>Title</title><meta charset="utf-8"></head><body><p>Text</p></body>)
      result = convert(html)
      result.should_not contain "Title"
      result.should_not contain "charset"
      result.should contain "Text"
    end

    it "removes meta tags" do
      html = %(<meta name="description" content="Desc"><p>Text</p>)
      result = convert(html)
      result.should_not contain "description"
      result.should contain "Text"
    end

    it "removes link tags" do
      html = %(<link rel="stylesheet" href="style.css"><p>Text</p>)
      result = convert(html)
      result.should_not contain "stylesheet"
      result.should contain "Text"
    end

    it "removes title tags" do
      html = %(<title>Page Title</title><p>Text</p>)
      result = convert(html)
      result.should_not contain "Page Title"
      result.should contain "Text"
    end
  end

  describe "media elements" do
    it "removes svg elements" do
      html = %(<svg><circle cx="50" cy="50" r="40"/></svg><p>Text</p>)
      result = convert(html)
      result.should_not contain "svg"
      result.should_not contain "circle"
      result.should contain "Text"
    end

    it "removes canvas elements" do
      html = %(<canvas id="myCanvas"></canvas><p>Text</p>)
      result = convert(html)
      result.should_not contain "canvas"
      result.should contain "Text"
    end

    it "removes audio elements" do
      html = %(<audio src="sound.mp3"></audio><p>Text</p>)
      result = convert(html)
      result.should_not contain "audio"
      result.should contain "Text"
    end

    it "removes video elements" do
      html = %(<video src="movie.mp4"></video><p>Text</p>)
      result = convert(html)
      result.should_not contain "video"
      result.should contain "Text"
    end

    it "removes iframe elements" do
      html = %(<iframe src="other.html"></iframe><p>Text</p>)
      result = convert(html)
      result.should_not contain "iframe"
      result.should contain "Text"
    end

    it "removes object and embed elements" do
      html = %(<object data="file.pdf"></object><embed src="movie.swf"><p>Text</p>)
      result = convert(html)
      result.should_not contain "object"
      result.should_not contain "embed"
      result.should contain "Text"
    end
  end

  describe "form elements" do
    it "removes form tags" do
      html = %(<form><input type="text"><button>Submit</button></form><p>Text</p>)
      result = convert(html)
      result.should_not contain "form"
      result.should_not contain "input"
      result.should_not contain "button"
      result.should contain "Text"
    end

    it "removes input tags" do
      html = %(<input type="text" value="test"><p>Text</p>)
      result = convert(html)
      result.should_not contain "input"
      result.should_not contain "test"
      result.should contain "Text"
    end

    it "removes button tags" do
      html = %(<button>Click me</button><p>Text</p>)
      result = convert(html)
      result.should_not contain "button"
      result.should_not contain "Click me"
      result.should contain "Text"
    end

    it "removes select and option tags" do
      html = %(<select><option>One</option><option>Two</option></select><p>Text</p>)
      result = convert(html)
      result.should_not contain "select"
      result.should_not contain "option"
      result.should_not contain "One"
      result.should contain "Text"
    end

    it "removes textarea tags" do
      html = %(<textarea>Content</textarea><p>Text</p>)
      result = convert(html)
      result.should_not contain "textarea"
      result.should_not contain "Content"
      result.should contain "Text"
    end

    it "removes label tags" do
      html = %(<label>Name:</label><p>Text</p>)
      result = convert(html)
      result.should_not contain "label"
      result.should_not contain "Name:"
      result.should contain "Text"
    end
  end

  describe "layout elements" do
    it "removes nav elements" do
      html = %(<nav><a href="/">Home</a></nav><p>Text</p>)
      result = convert(html)
      result.should_not contain "nav"
      result.should_not contain "Home"
      result.should contain "Text"
    end

    it "removes aside elements" do
      html = %(<aside>Sidebar content</aside><p>Text</p>)
      result = convert(html)
      result.should_not contain "aside"
      result.should_not contain "Sidebar"
      result.should contain "Text"
    end

    it "removes header elements" do
      html = %(<header>Logo</header><p>Text</p>)
      result = convert(html)
      result.should_not contain "header"
      result.should_not contain "Logo"
      result.should contain "Text"
    end

    it "removes footer elements" do
      html = %(<footer>Copyright</footer><p>Text</p>)
      result = convert(html)
      result.should_not contain "footer"
      result.should_not contain "Copyright"
      result.should contain "Text"
    end
  end

  describe "template elements" do
    it "removes template tags" do
      html = %(<template><p>Template content</p></template><p>Text</p>)
      result = convert(html)
      result.should_not contain "template"
      result.should_not contain "Template content"
      result.should contain "Text"
    end
  end

  describe "complex stripping" do
    it "strips mixed non-content elements" do
      html = %(
        <head>
          <title>Page Title</title>
          <style>body { margin: 0; }</style>
        </head>
        <body>
          <header>Site Header</header>
          <nav><a href="/">Home</a></nav>
          <article>
            <h1>Real Content</h1>
            <p>This is the actual article.</p>
          </article>
          <aside>Related links</aside>
          <footer>Site Footer</footer>
          <script>analytics();</script>
        </body>)

      result = convert(html)
      result.should contain "Real Content"
      result.should contain "This is the actual article."
      result.should_not contain "Page Title"
      result.should_not contain "Site Header"
      result.should_not contain "Home"
      result.should_not contain "Related links"
      result.should_not contain "Site Footer"
      result.should_not contain "analytics"
      result.should_not contain "margin: 0"
    end

    it "handles deeply nested script tags" do
      html = %(<div><div><script>deep();</script></div></div><p>Text</p>)
      result = convert(html)
      result.should_not contain "deep"
      result.should contain "Text"
    end

    it "handles script with HTML-like content" do
      html = %(<script>var x = "<p>fake paragraph</p>";</script><p>Real</p>)
      result = convert(html)
      result.should_not contain "fake paragraph"
      result.should contain "Real"
    end
  end

  describe "stripped elements add newlines to prevent merging" do
    it "adds newline after stripped nav to prevent merging with heading" do
      html = %(<nav>Breadcrumb</nav><h1>Title</h1>)
      result = convert(html)
      result.should eq "# Title"
    end
  end

  describe "security considerations" do
    it "removes XSS attempt in script" do
      html = %(<script>document.location="evil.com"</script><p>Safe</p>)
      result = convert(html)
      result.should_not contain "evil.com"
      result.should contain "Safe"
    end

    it "removes event handlers via script stripping" do
      # Note: The strip handler removes entire script tags, not event attributes
      # Event attributes would be handled by other mechanisms
      html = %(<script>document.write("<div onclick='evil()'>X</div>")</script><p>Safe</p>)
      result = convert(html)
      result.should_not contain "evil"
      result.should contain "Safe"
    end
  end
end
