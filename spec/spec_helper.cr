require "spec"
require "../src/markout"

macro convert(html, **options)
  begin
    %options = Markout::Options.new

    {% for key, value in options %}
      {% if key == :heading_style %}
        %options.heading_style = {{value}}
      {% elsif key == :bullet_char %}
        %options.bullet_char = {{value}}
      {% elsif key == :emphasis_char %}
        %options.emphasis_char = {{value}}
      {% elsif key == :strong_char %}
        %options.strong_char = {{value}}
      {% elsif key == :code_fence %}
        %options.code_fence = {{value}}
      {% elsif key == :hr_style %}
        %options.hr_style = {{value}}
      {% elsif key == :link_style %}
        %options.link_style = {{value}}
      {% elsif key == :autolinks %}
        %options.autolinks = {{value}}
      {% elsif key == :default_link_title %}
        %options.default_link_title = {{value}}
      {% elsif key == :strikethrough_char %}
        %options.strikethrough_char = {{value}}
      {% elsif key == :newline_style %}
        %options.newline_style = {{value}}
      {% elsif key == :strip_document %}
        %options.strip_document = {{value}}
      {% elsif key == :ignore_links %}
        %options.ignore_links = {{value}}
      {% elsif key == :ignore_images %}
        %options.ignore_images = {{value}}
      {% elsif key == :ignore_emphasis %}
        %options.ignore_emphasis = {{value}}
      {% elsif key == :images_as_html %}
        %options.images_as_html = {{value}}
      {% else %}
        {% raise "Unsupported test option: #{key.id}" %}
      {% end %}
    {% end %}

    Markout.convert({{html}}, %options)
  end
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
