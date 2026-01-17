module Markout
  module Handlers
    class HorizontalRulesHandler
      include Handler

      def handles : Array(Symbol)
        [:hr]
      end

      def convert(node : Lexbor::Node, ctx : Context, converter : Converter) : String
        # HR is a block element - needs newlines before and after
        "\n#{converter.options.hr_style}\n\n"
      end
    end
  end
end

Markout::Handlers.register(Markout::Handlers::HorizontalRulesHandler.new)
