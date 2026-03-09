module Markout::Handlers
  # Handler for elements that should be stripped from output.
  # These elements contain no user-visible content.
  class StripHandler
    include Handler

    def handles : Array(Symbol)
      [
        :script,
        :style,
        :noscript,
        :head,
        :meta,
        :link,
        :title,
        :svg,
        :template,
        :iframe,
        :object,
        :embed,
        :audio,
        :video,
        :canvas,
        :map,
        :area,
        :nav,
        :aside,
        :header,
        :footer,
        :form,
        :input,
        :button,
        :select,
        :textarea,
        :label,
        :fieldset,
        :legend,
        :datalist,
        :output,
        :progress,
        :meter,
      ]
    end

    def convert(node : Lexbor::Node, ctx : Context, converter : Converter) : String
      # Return newline to prevent merging with adjacent content
      # This ensures stripped block-level elements don't cause concatenation
      "\n"
    end
  end

  Handlers.register(StripHandler.new)
end
