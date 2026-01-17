# Markout

Convert HTML to clean, readable Markdown in Crystal. Designed for content migration, static site generators, documentation tools, and LLM data preparation pipelines.

## Features

- **Fast**: 25-40x faster than Python alternatives (markdownify, html2text)
- **Clean output**: Strips navigation, scripts, styles, and UI chrome automatically
- **LLM-ready**: Produces clean markdown ideal for RAG pipelines and context windows
- **Configurable**: ATX/Setext headings, bullet styles, reference links, and more
- **Comprehensive**: Tables, nested lists, blockquotes, code blocks, images, links

## Installation

Add the dependency to your `shard.yml`:

```yaml
dependencies:
  markout:
    github: amscotti/markout
```

Then run:

```bash
shards install
```

## Quick Start

```crystal
require "markout"

html = "<h1>Hello</h1><p>This is <strong>bold</strong> text.</p>"
markdown = Markout.convert(html)
# => "# Hello\n\nThis is **bold** text."
```

## Usage Examples

### Basic Conversion

```crystal
require "markout"

# Simple HTML to Markdown
html = <<-HTML
  <h1>Welcome</h1>
  <p>This is a <strong>test</strong> with a <a href="https://example.com">link</a>.</p>
  <ul>
    <li>Item one</li>
    <li>Item two</li>
  </ul>
HTML

puts Markout.convert(html)
# Output:
# # Welcome
#
# This is a **test** with a [link](https://example.com).
#
# - Item one
# - Item two
```

### With Options

```crystal
require "markout"

html = "<h1>Title</h1><ul><li>Item</li></ul>"

# Use Setext-style headings and asterisk bullets
options = Markout::Options.new
options.heading_style = Markout::Options::HeadingStyle::Setext
options.bullet_char = '*'

puts Markout.convert(html, options)
# Output:
# Title
# =====
#
# * Item
```

### Reference-Style Links

```crystal
require "markout"

html = <<-HTML
  <p>Visit <a href="https://example.com">Example</a> and
  <a href="https://test.com">Test</a> for more info.</p>
HTML

options = Markout::Options.new
options.link_style = Markout::Options::LinkStyle::Referenced

puts Markout.convert(html, options)
# Output:
# Visit [Example][1] and [Test][2] for more info.
#
# [1]: https://example.com
# [2]: https://test.com
```

### Processing Web Pages

```crystal
require "markout"
require "http/client"

# Fetch and convert a web page
response = HTTP::Client.get("https://example.com/article")
markdown = Markout.convert(response.body)

# Navigation, scripts, and styles are automatically stripped
# Only the article content remains
```

### Reusable Converter

```crystal
require "markout"

# Create a converter instance for multiple documents
options = Markout::Options.new
options.code_fence = "~~~"

converter = Markout::Converter.new(options)

docs = ["<p>Doc 1</p>", "<p>Doc 2</p>", "<p>Doc 3</p>"]
results = docs.map { |html| converter.convert(html) }
```

## Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `heading_style` | `HeadingStyle` | `ATX` | `ATX` (#) or `Setext` (underline) |
| `bullet_char` | `Char` | `'-'` | Bullet character for unordered lists |
| `emphasis_char` | `Char` | `'*'` | Character for italic text |
| `strong_char` | `String` | `"**"` | Characters for bold text |
| `code_fence` | `String` | `"```"` | Code fence delimiter |
| `hr_style` | `String` | `"---"` | Horizontal rule style |
| `link_style` | `LinkStyle` | `Inline` | `Inline` or `Referenced` links |
| `autolinks` | `Bool` | `true` | Use `<url>` when link text matches URL |
| `strip_document` | `Bool` | `true` | Strip leading/trailing whitespace |

## Performance

Benchmarks against Python's markdownify (210KB Wikipedia page):

| Library | Time | Output Size |
|---------|------|-------------|
| **Markout** | 2.2ms | 47KB |
| markdownify | 61ms | 65KB |

Markout is **28x faster** and produces **28% smaller** output by stripping non-content elements.

## Use Cases

- **RAG Pipelines**: Extract clean content from web pages for vector databases
- **Content Migration**: Convert HTML documentation to Markdown
- **LLM Context**: Maximize useful content in context windows
- **Static Sites**: Process HTML for Jekyll, Hugo, or other generators
- **Web Scraping**: Clean article extraction from web pages

## Development

```bash
# Install dependencies
shards install

# Run tests
crystal spec

# Run linter
bin/ameba
```

## Contributing

1. Fork it (<https://github.com/amscotti/markout/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

- [Anthony Scotti](https://github.com/amscotti) - creator and maintainer
