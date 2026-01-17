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

  it "ignores images if option enabled" do
    html = %(<img src="img.jpg">)
    options = Markout::Options.new
    options.ignore_images = true

    convert_with(html, options).should eq ""
  end
end
