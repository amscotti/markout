module Markout::Handlers
  # Handler for div elements.
  #
  # Divs are block-level containers that may contain either:
  # - Block content (h1-h6, p, etc.) - processed normally
  # - Inline content only (text, spans, etc.) - treated as a block with newlines
  #
  # This prevents UI metadata (breadcrumbs, dates) from merging with adjacent content.
  class DivsHandler
    include Handler

    def handles : Array(Symbol)
      [:div]
    end

    def convert(node : Lexbor::Node, ctx : Context, converter : Converter) : String
      content = converter.process_children(node, ctx).strip

      return "" if content.empty?

      # Divs are block-level elements and should always add trailing newlines
      # to separate from adjacent content, regardless of their contents
      content + "\n\n"
    end

    private def inline_only?(node : Lexbor::Node) : Bool
      # Check if all children are inline elements or text
      node.children.each do |child|
        tag = child.tag_sym
        # Skip text nodes (they're inline)
        next if tag == :_text
        # Skip comment nodes
        next if tag == :_comment
        # If we find a block element, this div is not inline-only
        return false if block_element?(tag)
      end
      true
    end

    private def block_element?(tag : Symbol) : Bool
      case tag
      when :p, :h1, :h2, :h3, :h4, :h5, :h6, :ul, :ol, :li,
           :blockquote, :pre, :code, :table, :tr, :td, :th,
           :article, :section, :nav, :aside, :header, :footer,
           :div, :hr, :br
        true
      else
        false
      end
    end
  end

  Handlers.register(DivsHandler.new)
end
