require "spec"
require "../src/markout"

def convert(html : String, **options) : String
  # Map named arguments to Options object
  opt_obj = Markout::Options.new

  options.each do |key, value|
    case key
    when :bullet_char then opt_obj.bullet_char = value.as(Char)
      # Add other mappings as needed for tests
    else
      # Try to set property via reflection or ignoring for now if simple types match
      # For now, simplistic manual mapping is safer or we can rely on default if not passed.
    end
  end

  Markout.convert(html, opt_obj)
end

def convert_with(html : String, options : Markout::Options) : String
  Markout.convert(html, options)
end

def fixture(name : String) : String
  File.read(File.join(__DIR__, "fixtures", name))
end

def normalize(text : String) : String
  text.strip.gsub(/\r\n?/, "\n").gsub(/\n{3,}/, "\n\n")
end
