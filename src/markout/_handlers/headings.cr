module Markout
  module Handlers
    # Handler for heading elements (h1-h6).
    #
    # Converts HTML headings to Markdown format:
    # - ATX style: # Heading, ## Heading, etc.
    # - Setext style: underline with === (h1) or --- (h2)
    #
    # Respects the `heading_style` option. Setext only applies to h1/h2.
    class HeadingsHandler
      include Handler

      def handles : Array(Symbol)
        [:h1, :h2, :h3, :h4, :h5, :h6]
      end

      def convert(node : Lexbor::Node, ctx : Context, converter : Converter) : String
        level = heading_level(node)
        text = converter.process_children(node, ctx).strip

        case converter.options.heading_style
        in .atx?
          "#" * level + " #{text}"
        in .setext?
          if level <= 2
            "#{text}\n#{underline(level, text.size)}"
          else
            "#" * level + " #{text}"
          end
        end
      end

      private def heading_level(node : Lexbor::Node) : Int32
        case node.tag_sym
        when :h1 then 1
        when :h2 then 2
        when :h3 then 3
        when :h4 then 4
        when :h5 then 5
        when :h6 then 6
        else          1
        end
      end

      private def underline(level : Int32, length : Int32) : String
        char = level == 1 ? "=" : "-"
        char * [length, 3].max
      end
    end
  end
end

Markout::Handlers.register(Markout::Handlers::HeadingsHandler.new)
