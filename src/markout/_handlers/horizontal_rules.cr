module Markout
  module Handlers
    # Handler for horizontal rule elements.
    #
    # Converts HTML <hr> elements to Markdown horizontal rules.
    # Default style is `---` but respects the `hr_style` option.
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
