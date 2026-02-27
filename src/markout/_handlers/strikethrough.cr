module Markout::Handlers
  # Handler for strikethrough elements.
  #
  # Converts HTML s, del, and strike elements to Markdown strikethrough.
  # Default format is ~~text~~ but respects strikethrough_char option.
  class StrikethroughHandler
    include Handler

    def handles : Array(Symbol)
      [:s, :del, :strike]
    end

    def convert(node : Lexbor::Node, ctx : Context, converter : Converter) : String
      content = converter.process_children(node, ctx)
      char = converter.options.strikethrough_char

      "#{char}#{content}#{char}"
    end
  end

  Handlers.register(StrikethroughHandler.new)
end
