require "../spec_helper"

describe Markout::Handlers::ImagesHandler do
  it "converts basic image" do
    html = %(<img src="img.jpg" alt="Description">)
    convert(html).should eq "![Description](img.jpg)"
  end

  it "includes title if option enabled" do
    html = %(<img src="img.jpg" alt="Alt" title="Title">)
    options = Markout::Options.new
    options.default_link_title = true

    convert_with(html, options).should eq "![Alt](img.jpg \"Title\")"
  end

  it "escapes quotes in image titles" do
    html = %(<img src="img.jpg" alt="Alt" title='He said "hello"'>)
    options = Markout::Options.new
    options.default_link_title = true

    convert_with(html, options).should eq "![Alt](img.jpg \"He said \\\"hello\\\"\")"
  end

  it "ignores images if option enabled" do
    html = %(<img src="img.jpg">)
    options = Markout::Options.new
    options.ignore_images = true

    convert_with(html, options).should eq ""
  end

  it "returns raw HTML when images_as_html is enabled" do
    html = %(<img src="img.jpg" alt="Description">)
    options = Markout::Options.new
    options.images_as_html = true

    convert_with(html, options).should eq html
  end
end
