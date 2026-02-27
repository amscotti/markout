module Markout::Handlers
  # Handler for list elements (unordered and ordered).
  #
  # Converts HTML ul, ol, and li elements to Markdown lists.
  # Supports nested lists and respects bullet_char option.
  class ListsHandler
    include Handler

    def handles : Array(Symbol)
      [:ul, :ol, :li]
    end

    def convert(node : Lexbor::Node, ctx : Context, converter : Converter) : String
      tag = node.tag_sym

      case tag
      when :ul, :ol
        handle_list(node, ctx, converter)
      when :li
        handle_list_item(node, ctx, converter)
      else
        ""
      end
    end

    private def handle_list(node : Lexbor::Node, ctx : Context, converter : Converter) : String
      start_index = 1
      if node.tag_sym == :ol
        if start_attr = node["start"]?
          start_index = start_attr.to_i? || 1
        end
      end

      # Check if we're already inside a list (nested list)
      is_nested = ctx.list_depth > 0

      ctx.enter_list(node.tag_sym, start_index)
      content = converter.process_children(node, ctx)
      ctx.exit_list

      # If this is a nested list, add leading newline so it starts on its own line
      if is_nested
        "\n" + content
      else
        content
      end
    end

    private def handle_list_item(node : Lexbor::Node, ctx : Context, converter : Converter) : String
      # Determine marker
      marker = ""
      if ctx.current_list_type == :ol
        index = ctx.next_list_index
        marker = "#{index}. "
      else
        marker = "#{converter.options.bullet_char} "
      end

      # Process content
      content = converter.process_children(node, ctx).strip

      if content.empty?
        return "#{marker}\n"
      end

      # Indent subsequent lines
      marker_len = marker.size
      subsequent_indent = " " * marker_len

      lines = content.lines
      first_line = lines.shift

      String.build do |io|
        io << marker << first_line

        lines.each do |line|
          if line.blank?
            io << "\n"
          else
            io << "\n" << subsequent_indent << line
          end
        end
        io << "\n"
      end
    end
  end

  Handlers.register(ListsHandler.new)
end
