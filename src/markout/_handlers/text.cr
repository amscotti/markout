module Markout::Handlers
  class TextHandler
    include Handler

    def handles : Array(Symbol)
      [:_text]
    end

    def convert(node : Lexbor::Node, ctx : Context, converter : Converter) : String
      text = node.tag_text
      return "" unless text

      if ctx.in_code_block?
        text
      else
        # Normalize whitespace
        # Replace newlines with spaces and collapse multiple spaces
        text.gsub(/[\r\n]+/, " ").gsub(/[ \t]+/, " ")
      end
    end
  end

  Handlers.register(TextHandler.new)
end
