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
          format_inline_code(content)
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

    private def format_inline_code(content : String) : String
      fence_length = longest_backtick_run(content) + 1
      fence = "`" * fence_length
      padded_content = if content.starts_with?('`') || content.ends_with?('`')
                         " #{content} "
                       else
                         content
                       end

      "#{fence}#{padded_content}#{fence}"
    end

    private def longest_backtick_run(content : String) : Int32
      max_run = 0
      current_run = 0

      content.each_char do |char|
        if char == '`'
          current_run += 1
          max_run = current_run if current_run > max_run
        else
          current_run = 0
        end
      end

      max_run
    end
  end

  Handlers.register(CodeHandler.new)
end
