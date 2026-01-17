# Markout: Convert HTML to clean, readable Markdown in Crystal.
#
# Example usage:
# ```
# require "markout"
#
# html = "<h1>Hello</h1><p>This is a <strong>test</strong>.</p>"
# markdown = Markout.convert(html)
# # => "# Hello\n\nThis is a **test**."
# ```
#
# With options:
# ```
# options = Markout::Options.new(
#   heading_style: Markout::Options::HeadingStyle::Setext,
#   bullet_char: '*'
# )
# markdown = Markout.convert(html, options)
# ```
module Markout
  VERSION = "0.1.0"

  # Convert HTML string to Markdown using default options.
  #
  # Parameters:
  # - `html`: The HTML string to convert
  #
  # Returns: String containing Markdown representation
  def self.convert(html : String) : String
    converter = Converter.new
    converter.convert(html)
  end

  # Convert HTML string to Markdown with given options hash.
  #
  # Parameters:
  # - `html`: The HTML string to convert
  # - `options`: Hash of option key-value pairs
  #
  # Returns: String containing Markdown representation
  def self.convert(html : String, **options) : String
    opts = Options.new
    options.each do |key, value|
      opts.respond_to?("#{key}=") && opts.send("#{key}=", value)
    end
    converter = Converter.new(opts)
    converter.convert(html)
  end

  # Convert HTML string to Markdown with given Options object.
  #
  # Parameters:
  # - `html`: The HTML string to convert
  # - `options`: Options object with configuration
  #
  # Returns: String containing Markdown representation
  def self.convert(html : String, options : Options) : String
    converter = Converter.new(options)
    converter.convert(html)
  end
end

# Require all core modules
require "./markout/converter"
require "./markout/context"
require "./markout/options"
require "./markout/handler"
require "./markout/handlers/*"
