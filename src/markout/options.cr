module Markout
  # Configuration options for HTML to Markdown conversion.
  class Options
    # Heading style enum for different markdown heading formats.
    enum HeadingStyle
      ATX    # # Heading (default)
      Setext # Heading\n======= (for h1), Heading\n------ (for h2)
    end

    # Link style enum for different markdown link formats.
    enum LinkStyle
      Inline     # [text](url) (default)
      Referenced # [text][1] ... [1]: url
    end

    # Newline style enum for <br> element conversion.
    enum NewlineStyle
      Spaces    # Two spaces + \n (default)
      Backslash # \\\n
    end

    # ===== MVP Options =====
    property heading_style : HeadingStyle = HeadingStyle::ATX

    property bullet_char : Char = '-'

    property emphasis_char : Char = '*'

    property strong_char : String = "**"

    property code_fence : String = "```"

    property hr_style : String = "---"

    # ===== Tier 2 Options =====
    property link_style : LinkStyle = LinkStyle::Inline

    property? autolinks : Bool = true

    property? default_link_title : Bool = false

    property strikethrough_char : String = "~~"

    property newline_style : NewlineStyle = NewlineStyle::Spaces

    property? strip_document : Bool = true

    # ===== Tier 3 Options =====
    property? ignore_links : Bool = false

    property? ignore_images : Bool = false

    property? ignore_emphasis : Bool = false

    property? images_as_html : Bool = false
  end
end
