module Markout
  module Handlers
    class EmphasisHandler
      include Handler

      def handles : Array(Symbol)
        [:strong, :b, :em, :i]
      end

      def convert(node : Lexbor::Node, ctx : Context, converter : Converter) : String
        text = converter.process_children(node, ctx).strip

        return text if converter.options.ignore_emphasis?

        case node.tag_sym
        when :strong, :b
          converter.options.strong_char + text + converter.options.strong_char
        when :em, :i
          converter.options.emphasis_char + text + converter.options.emphasis_char
        else
          text
        end
      end
    end
  end
end

Markout::Handlers.register(Markout::Handlers::EmphasisHandler.new)
