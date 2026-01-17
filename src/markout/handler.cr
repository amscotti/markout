module Markout
  # Base handler module for HTML to Markdown element conversion.
  module Handler
    abstract def handles : Array(Symbol)
    abstract def convert(node : Lexbor::Node, ctx : Context, converter : Converter) : String
  end

  # Registry for all element handlers.
  module Handlers
    @@registry = {} of Symbol => Handler

    # Register a handler instance for the tags it handles.
    def self.register(handler : Handler)
      handler.handles.each do |tag|
        @@registry[tag] = handler
      end
    end

    # Get the handler for a given tag symbol.
    # Returns DefaultHandler if no specific handler is registered.
    def self.for(tag : Symbol) : Handler
      @@registry.fetch(tag) { DefaultHandler.new }
    end

    # Clear the registry (useful for testing).
    def self.clear
      @@registry.clear
    end
  end

  # Default handler for unknown or unhandled HTML elements.
  class DefaultHandler
    include Handler

    def handles : Array(Symbol)
      [] of Symbol
    end

    def convert(node : Lexbor::Node, ctx : Context, converter : Converter) : String
      # Default behavior: process children, stripping the element itself
      converter.process_children(node, ctx)
    end
  end
end
