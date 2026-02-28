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
        prev_was_inline = false

        node.children.each do |child|
          output = process_node(child, ctx)

          # Check if we need to add a space between inline element and text
          if prev_was_inline && needs_leading_space?(child, output)
            io << " "
          end

          io << output
          prev_was_inline = inline_element?(child)
        end
      end
      result
    end

    # Check if a node is an inline element that might need trailing space.
    private def inline_element?(node : Lexbor::Node) : Bool
      case node.tag_sym
      when :strong, :b, :em, :i, :a, :code, :del, :s, :strike, :img, :span
        true
      else
        false
      end
    end

    # Check if the current node/output needs a leading space after an inline element.
    private def needs_leading_space?(node : Lexbor::Node, output : String) : Bool
      return false if output.empty?

      first_char = output[0]
      return false if first_char.ascii_whitespace?
      return false if punctuation?(first_char)

      # Only text nodes need this special handling
      # We don't add space between inline elements (e.g., **Bold***italic*)
      node.tag_sym == :_text
    end

    # Check if a character is punctuation that shouldn't have space before it.
    private def punctuation?(char : Char) : Bool
      # Common punctuation that should not have space before it
      case char
      when '.', ',', '!', '?', ';', ':', ')', ']', '}', '"', "'", '-', '–', '—'
        true
      else
        false
      end
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
