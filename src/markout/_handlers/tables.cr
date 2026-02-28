module Markout::Handlers
  # Handler for table elements.
  #
  # Converts HTML table elements to Markdown table format.
  # Handles thead, tbody, tfoot, tr, th, and td elements.
  # Generates proper header separator row.
  class TablesHandler
    include Handler

    def handles : Array(Symbol)
      [:table, :thead, :tbody, :tfoot, :tr, :th, :td]
    end

    def convert(node : Lexbor::Node, ctx : Context, converter : Converter) : String
      case node.tag_sym
      when :table
        ctx.enter_table
        content = converter.process_children(node, ctx)
        ctx.exit_table
        content + "\n\n"
      when :tr
        handle_row(node, ctx, converter)
      when :td, :th
        " " + converter.process_children(node, ctx).strip + " |"
      when :thead, :tbody, :tfoot
        converter.process_children(node, ctx)
      else
        ""
      end
    end

    private def handle_row(node : Lexbor::Node, ctx : Context, converter : Converter) : String
      content = converter.process_children(node, ctx)

      # If row has no cells (just whitespace), skip it
      return "" if content.strip.empty?

      # Clean up content: TextHandler might have left some whitespace
      # But our cells end with "|".
      # content looks like "  Cell |  Cell | "
      # We want to trim lines? No, it's one line.

      result = "|" + content + "\n"

      if !ctx.current_table_header_printed?
        # Generate separator
        # Count columns by counting pipes in content
        # content is like " Cell 1 | Cell 2 |"
        cols = content.count('|')

        # Build separator |---|---|
        separator = "|" + ("---|" * cols) + "\n"

        result += separator
        ctx.table_header_printed = true
      end

      result
    end
  end

  Handlers.register(TablesHandler.new)
end
