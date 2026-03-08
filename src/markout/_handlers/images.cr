module Markout
  module Handlers
    # Handler for image elements.
    #
    # Converts HTML img elements to Markdown image syntax: ![alt](src "title")
    # Supports ignore_images? and images_as_html? options.
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
          escaped_title = converter.escape_title(title)
          "![#{alt}](#{src} \"#{escaped_title}\")"
        else
          "![#{alt}](#{src})"
        end
      end
    end
  end
end

Markout::Handlers.register(Markout::Handlers::ImagesHandler.new)
