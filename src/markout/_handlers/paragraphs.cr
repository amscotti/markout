module Markout
  module Handlers
    class ParagraphsHandler
      include Handler

      def handles : Array(Symbol)
        [:p, :br]
      end

      def convert(node : Lexbor::Node, ctx : Context, converter : Converter) : String
        case node.tag_sym
        when :p
          converter.process_children(node, ctx) + "\n\n"
        when :br
          case converter.options.newline_style
          in .spaces?
            "  \n"
          in .backslash?
            "\\\n"
          end
        else
          ""
        end
      end
    end
  end
end

Markout::Handlers.register(Markout::Handlers::ParagraphsHandler.new)
