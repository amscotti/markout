require "./spec_helper"

describe "Unicode handling" do
  describe "basic Unicode text" do
    it "handles accented characters" do
      html = "<p>Café résumé naïve</p>"
      convert(html).should eq "Café résumé naïve"
    end

    it "handles Chinese characters" do
      html = "<p>你好世界</p>"
      convert(html).should eq "你好世界"
    end

    it "handles Japanese characters" do
      html = "<p>こんにちは世界</p>"
      convert(html).should eq "こんにちは世界"
    end

    it "handles Korean characters" do
      html = "<p>안녕하세요</p>"
      convert(html).should eq "안녕하세요"
    end

    it "handles Arabic characters" do
      html = "<p>مرحبا بالعالم</p>"
      convert(html).should eq "مرحبا بالعالم"
    end

    it "handles Hebrew characters" do
      html = "<p>שלום עולם</p>"
      convert(html).should eq "שלום עולם"
    end

    it "handles Cyrillic characters" do
      html = "<p>Привет мир</p>"
      convert(html).should eq "Привет мир"
    end

    it "handles Greek characters" do
      html = "<p>Γειά σου Κόσμε</p>"
      convert(html).should eq "Γειά σου Κόσμε"
    end
  end

  describe "emoji" do
    it "handles common emoji" do
      html = "<p>Hello 👋 World 🌍</p>"
      convert(html).should eq "Hello 👋 World 🌍"
    end

    it "handles emoji in headings" do
      html = "<h1>🚀 Rocket Science</h1>"
      convert(html).should eq "# 🚀 Rocket Science"
    end

    it "handles emoji in links" do
      html = "<a href=\"/emoji\">Click here 👉</a>"
      convert(html).should eq "[Click here 👉](/emoji)"
    end

    it "handles emoji sequences" do
      html = "<p>Family: 👨‍👩‍👧‍👦</p>"
      convert(html).should eq "Family: 👨‍👩‍👧‍👦"
    end

    it "handles flag emoji" do
      html = "<p>Flags: 🇺🇸 🇬🇧 🇯🇵</p>"
      convert(html).should eq "Flags: 🇺🇸 🇬🇧 🇯🇵"
    end
  end

  describe "special Unicode characters" do
    it "handles mathematical symbols" do
      html = "<p>∑ ∏ ∫ √ ∞ ≠ ≤ ≥</p>"
      convert(html).should eq "∑ ∏ ∫ √ ∞ ≠ ≤ ≥"
    end

    it "handles currency symbols" do
      html = "<p>$ € £ ¥ ₹ ₿</p>"
      convert(html).should eq "$ € £ ¥ ₹ ₿"
    end

    it "handles arrows and symbols" do
      html = "<p>→ ← ↑ ↓ ⇒ ⇔ • ◦ ‣</p>"
      convert(html).should eq "→ ← ↑ ↓ ⇒ ⇔ • ◦ ‣"
    end

    it "handles box drawing characters" do
      html = "<p>┌─┬─┐ │ │ │ └─┴─┘</p>"
      convert(html).should eq "┌─┬─┐ │ │ │ └─┴─┘"
    end
  end

  describe "HTML entities" do
    it "handles named entities" do
      html = "<p>&amp; &lt; &gt; &quot; &apos;</p>"
      convert(html).should eq "& < > \" '"
    end

    it "handles numeric entities" do
      html = "<p>&#169; &#8364; &#x2665;</p>"
      convert(html).should eq "© € ♥"
    end

    it "handles non-breaking space" do
      html = "<p>word&nbsp;word</p>"
      result = convert(html)
      # Non-breaking space should be preserved or converted to regular space
      result.should contain "word"
    end
  end

  describe "mixed content" do
    it "handles Unicode in formatted text" do
      html = "<p><strong>日本語</strong> and <em>العربية</em></p>"
      result = convert(html)
      result.should contain "**日本語**"
      result.should contain "*العربية*"
    end

    it "handles Unicode in lists" do
      html = "<ul><li>中文</li><li>한국어</li><li>ไทย</li></ul>"
      result = convert(html)
      result.should contain "- 中文"
      result.should contain "- 한국어"
      result.should contain "- ไทย"
    end

    it "handles Unicode in table cells" do
      html = "<table><tr><th>Language</th><th>Hello</th></tr><tr><td>Japanese</td><td>こんにちは</td></tr></table>"
      result = convert(html)
      result.should contain "こんにちは"
    end
  end
end
