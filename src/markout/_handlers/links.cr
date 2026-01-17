module Markout
  module Handlers
    class LinksHandler
      include Handler

      def handles : Array(Symbol)
        [:a]
      end

      def convert(node : Lexbor::Node, ctx : Context, converter : Converter) : String
        return converter.process_children(node, ctx) if converter.options.ignore_links?

        href = node["href"]?
        return converter.process_children(node, ctx) unless href

        text = converter.process_children(node, ctx).strip
        title = node["title"]?

        case converter.options.link_style
        in .inline?
          if converter.options.autolinks? && text == href
            "<#{href}>"
          elsif title && converter.options.default_link_title?
            "[#{text}](#{href} \"#{title}\")"
          else
            "[#{text}](#{href})"
          end
        in .referenced?
          ref_id = ctx.add_reference(href, title)
          "[#{text}][#{ref_id}]"
        end
      end
    end
  end
end

Markout::Handlers.register(Markout::Handlers::LinksHandler.new)
