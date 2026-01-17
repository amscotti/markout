module Markout::Handlers
  class BlockquotesHandler
    include Handler

    def handles : Array(Symbol)
      [:blockquote]
    end

    def convert(node : Lexbor::Node, ctx : Context, converter : Converter) : String
      ctx.push_blockquote
      content = converter.process_children(node, ctx).strip
      ctx.pop_blockquote

      return "" if content.empty?

      lines = content.lines
      result = String.build do |io|
        lines.each_with_index do |line, i|
          io << "\n" if i > 0
          if line.strip.empty?
            io << ">"
          else
            io << "> " << line
          end
        end
        # Blockquotes are blocks, so ensure newline at end
        io << "\n"
      end

      # If we're nested inside another blockquote, add leading newline
      # so nested blockquote starts on its own line
      if ctx.blockquote_depth > 0
        "\n" + result
      else
        result
      end
    end
  end

  Handlers.register(BlockquotesHandler.new)
end
