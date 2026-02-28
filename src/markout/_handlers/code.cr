module Markout::Handlers
  # Handler for code elements (inline and blocks).
  #
  # Converts HTML code elements to Markdown:
  # - <code> inside <pre> → fenced code block
  # - <code> alone → inline code with backticks
  # - <pre> → wraps content in code fence
  #
  # Respects the `code_fence` option for block delimiters.
  class CodeHandler
    include Handler

    def handles : Array(Symbol)
      [:code, :pre]
    end

    def convert(node : Lexbor::Node, ctx : Context, converter : Converter) : String
      case node.tag_sym
      when :code
        if ctx.in_code_block?
          # Inside pre, just return content so pre can fence it
          node.tag_text || ""
        else
          # Inline code
          content = node.tag_text || ""
          "`#{content}`"
        end
      when :pre
        ctx.in_code_block = true
        content = converter.process_children(node, ctx)
        ctx.in_code_block = false

        # Ensure content doesn't end with excessive newlines before fence
        content = content.strip("\n")

        "#{converter.options.code_fence}\n#{content}\n#{converter.options.code_fence}\n\n"
      else
        ""
      end
    end
  end

  Handlers.register(CodeHandler.new)
end
