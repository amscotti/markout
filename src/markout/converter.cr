module Markout
  # Main conversion engine for HTML to Markdown transformation.
  #
  # The Converter parses HTML using Lexbor and recursively processes
  # each node, delegating to appropriate handlers based on tag type.
  class Converter
    # Configuration options for this converter instance.
    getter options : Options

    # Create a new converter with the given options.
    def initialize(@options : Options = Options.new)
    end

    # Convert an HTML string to Markdown.
    #
    # Parameters:
    # - `html`: The HTML string to convert
    #
    # Returns: String containing Markdown representation
    def convert(html : String) : String
      return "" if html.empty?

      parser = Lexbor::Parser.new(html)
      ctx = Context.new
      result = process_node(parser.root!, ctx)

      # Append references if any
      if !ctx.references.empty?
        result += "\n\n"
        ctx.references.each do |id, ref|
          title_part = ref.title ? " \"#{ref.title}\"" : ""
          result += "[#{id}]: #{ref.url}#{title_part}\n"
        end
      end

      if options.strip_document?
        result.strip
      else
        result
      end
    end

    # Process a single DOM node and return its Markdown representation.
    #
    # Parameters:
    # - `node`: The Lexbor node to process
    # - `ctx`: The current conversion context
    #
    # Returns: String containing Markdown for this node
    def process_node(node : Lexbor::Node, ctx : Context) : String
      tag = node.tag_sym

      # Get the handler for this tag
      handler = Handlers.for(tag)
      handler.convert(node, ctx, self)
    end

    # Process all children of a node and concatenate their output.
    #
    # Parameters:
    # - `node`: The parent node whose children to process
    # - `ctx`: The current conversion context
    #
    # Returns: String containing concatenated Markdown for all children
    def process_children(node : Lexbor::Node, ctx : Context) : String
      result = String.build do |io|
        node.children.each do |child|
          io << process_node(child, ctx)
        end
      end
      result
    end

    # Add a reference link to the context for reference-style output.
    # Returns the reference ID.
    #
    # Parameters:
    # - `url`: The link URL
    # - `title`: Optional link title
    #
    # Returns: Int32 reference ID
    def add_reference(url : String, title : String? = nil) : Int32
      # Delegate to context - this is a convenience method
      raise "Reference links require a context with reference tracking"
    end
  end
end
