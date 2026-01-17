module Markout::Handlers
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
