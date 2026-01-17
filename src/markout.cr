require "lexbor"

require "./markout/options"
require "./markout/context"
require "./markout/handler"
require "./markout/converter"
require "./markout/_handlers/*"

module Markout
  VERSION = "0.1.0"

  # Convert HTML string to Markdown using default options.
  def self.convert(html : String) : String
    converter = Converter.new
    converter.convert(html)
  end

  # Convert HTML string to Markdown with given Options object.
  def self.convert(html : String, options : Options) : String
    converter = Converter.new(options)
    converter.convert(html)
  end
end
