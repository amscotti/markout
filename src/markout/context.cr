module Markout
  # Context object for tracking conversion state during HTML processing.
  #
  # This class maintains current state while traversing the HTML tree,
  # including nesting levels, list state, and reference tracking.
  class Context
    # Current nesting depth (for lists, blockquotes, etc.).
    property depth : Int32 = 0

    # Current blockquote nesting depth.
    property blockquote_depth : Int32 = 0

    # Track if we're inside a pre/code block.
    property? in_code_block : Bool = false

    # Track if we're inside a link.
    property? in_link : Bool = false

    # Reference links for reference-style output (if enabled).
    property references : Hash(Int32, Reference) = {} of Int32 => Reference

    # Next reference ID for reference-style links.
    @next_ref_id : Int32 = 1

    # Reference link data structure.
    record Reference,
      url : String,
      title : String? = nil

    @reference_ids : Hash(Reference, Int32) = {} of Reference => Int32

    # List state tracking
    class ListState
      property type : Symbol # :ul or :ol
      property index : Int32 # Current index for ordered lists

      def initialize(@type : Symbol, @index : Int32 = 1)
      end
    end

    @list_stack : Array(ListState) = [] of ListState

    # Table state tracking
    class TableState
      property? header_printed : Bool = false

      def initialize
      end
    end

    @table_stack : Array(TableState) = [] of TableState

    # Create a new context with default state.
    def initialize
    end

    # Enter a new table context
    def enter_table
      @table_stack << TableState.new
    end

    # Exit the current table context
    def exit_table
      @table_stack.pop unless @table_stack.empty?
    end

    # Check if header is printed for current table
    def current_table_header_printed? : Bool
      @table_stack.last?.try(&.header_printed?) || false
    end

    # Set header printed for current table
    def table_header_printed=(val : Bool)
      @table_stack.last?.try(&.header_printed=(val))
    end

    # Enter a new list context
    def enter_list(type : Symbol, start_index : Int32 = 1)
      @list_stack << ListState.new(type, start_index)
    end

    # Exit the current list context
    def exit_list
      @list_stack.pop unless @list_stack.empty?
    end

    # Get current list depth (0 if not in list)
    def list_depth : Int32
      @list_stack.size
    end

    # Get current list type (:ul, :ol, or nil)
    def current_list_type : Symbol?
      @list_stack.last?.try(&.type)
    end

    # Get and increment current list index (for ordered lists)
    def next_list_index : Int32
      return 0 unless state = @list_stack.last?
      current = state.index
      state.index += 1
      current
    end

    # Increment the blockquote depth.
    def push_blockquote
      @blockquote_depth += 1
    end

    # Decrement the blockquote depth.
    def pop_blockquote
      @blockquote_depth -= 1 if @blockquote_depth > 0
    end

    # Add a reference link for reference-style output.
    # Returns the reference ID.
    # Parameters:
    # - `url`: The link URL
    # - `title`: Optional link title
    #
    # Returns: Int32 reference ID
    def add_reference(url : String, title : String? = nil) : Int32
      ref = Reference.new(url, title)
      if id = @reference_ids[ref]?
        return id
      end

      id = @next_ref_id
      @references[id] = ref
      @reference_ids[ref] = id
      @next_ref_id += 1
      id
    end

    # Get the current indentation string based on nesting depth.
    def indent(level : Int32 = 0) : String
      "  " * (@depth + level)
    end
  end
end
