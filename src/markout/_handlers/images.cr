module Markout
  module Handlers
    class ImagesHandler
      include Handler

      def handles : Array(Symbol)
        [:img]
      end

      def convert(node : Lexbor::Node, ctx : Context, converter : Converter) : String
        return "" if converter.options.ignore_images?

        return node.to_html if converter.options.images_as_html?

        src = node["src"]?
        return "" unless src

        alt = node["alt"]? || ""
        title = node["title"]?

        if title && converter.options.default_link_title?
          "![#{alt}](#{src} \"#{title}\")"
        else
          "![#{alt}](#{src})"
        end
      end
    end
  end
end

Markout::Handlers.register(Markout::Handlers::ImagesHandler.new)
