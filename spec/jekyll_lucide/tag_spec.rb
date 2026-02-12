# frozen_string_literal: true

require "spec_helper"

RSpec.describe JekyllLucide::Tag do
  describe "basic rendering" do
    it "renders an icon with default attributes" do
      result = render_tag('"home"')

      expect(result).to include("<svg")
      expect(result).to include("</svg>")
      expect(result).to include('aria-hidden="true"')
      expect(result).to include('width="24"')
      expect(result).to include('height="24"')
      expect(result).to include('viewBox="0 0 24 24"')
      expect(result).to include('fill="none"')
      expect(result).to include('stroke="currentColor"')
      expect(result).to include('stroke-width="2"')
      expect(result).to include('stroke-linecap="round"')
      expect(result).to include('stroke-linejoin="round"')
    end

    it "includes the icon's SVG content" do
      result = render_tag('"home"')

      expect(result).to include("<path")
      expect(result).to include("<polyline")
    end

    it "renders different icons" do
      home = render_tag('"home"')
      search = render_tag('"search"')

      expect(home).not_to eq(search)
      expect(search).to include("<circle")
    end
  end

  describe "icon name parsing" do
    it "accepts double-quoted names" do
      result = render_tag('"arrow-right"')
      expect(result).to include("<svg")
    end

    it "accepts single-quoted names" do
      result = render_tag("'arrow-right'")
      expect(result).to include("<svg")
    end

    it "accepts variable names" do
      result = render_tag("icon_name", variables: { "icon_name" => "home" })
      expect(result).to include("<svg")
      expect(result).to include("<path")
    end

    it "accepts nested variable names" do
      result = render_tag("page.icon", variables: { "page" => { "icon" => "search" } })
      expect(result).to include("<svg")
      expect(result).to include("<circle")
    end
  end

  describe "options" do
    it "accepts a size option that sets width and height" do
      result = render_tag('"home" size="32"')

      expect(result).to include('width="32"')
      expect(result).to include('height="32"')
    end

    it "accepts a class option" do
      result = render_tag('"home" class="my-icon"')

      expect(result).to include('class="my-icon"')
    end

    it "accepts multiple classes" do
      result = render_tag('"home" class="icon icon-home"')

      expect(result).to include('class="icon icon-home"')
    end

    it "accepts stroke-width option" do
      result = render_tag('"home" stroke-width="1.5"')

      expect(result).to include('stroke-width="1.5"')
      expect(result).not_to include('stroke-width="2"')
    end

    it "accepts stroke option" do
      result = render_tag('"home" stroke="red"')

      expect(result).to include('stroke="red"')
    end

    it "accepts fill option" do
      result = render_tag('"home" fill="blue"')

      expect(result).to include('fill="blue"')
    end

    it "accepts multiple options" do
      result = render_tag('"home" size="20" class="icon" stroke-width="1"')

      expect(result).to include('width="20"')
      expect(result).to include('height="20"')
      expect(result).to include('class="icon"')
      expect(result).to include('stroke-width="1"')
    end

    it "accepts variable values for options" do
      result = render_tag('"home" size=icon_size', variables: { "icon_size" => "48" })

      expect(result).to include('width="48"')
      expect(result).to include('height="48"')
    end
  end

  describe "configuration defaults" do
    it "uses defaults from site config" do
      site = make_site("lucide" => { "defaults" => { "class" => "lucide-icon" } })
      result = render_tag('"home"', site: site)

      expect(result).to include('class="lucide-icon"')
    end

    it "allows tag options to override config defaults" do
      site = make_site("lucide" => { "defaults" => { "class" => "lucide-icon" } })
      result = render_tag('"home" class="custom"', site: site)

      expect(result).to include('class="custom"')
      expect(result).not_to include('class="lucide-icon"')
    end

    it "merges config defaults with tag options" do
      site = make_site("lucide" => { "defaults" => { "class" => "lucide-icon", "stroke-width" => "1" } })
      result = render_tag('"home" size="32"', site: site)

      expect(result).to include('class="lucide-icon"')
      expect(result).to include('stroke-width="1"')
      expect(result).to include('width="32"')
    end
  end

  describe "custom icons" do
    around do |example|
      Dir.mktmpdir do |tmpdir|
        @tmpdir = tmpdir
        example.run
      end
    end

    def write_custom_icon(dir, name, content)
      FileUtils.mkdir_p(dir)
      File.write(File.join(dir, "#{name}.svg"), content)
    end

    it "loads a custom icon from _lucide/" do
      custom_dir = File.join(@tmpdir, "_lucide")
      write_custom_icon(custom_dir, "my-custom-icon", "<circle/>")

      site = make_site("source" => @tmpdir)
      result = render_tag('"my-custom-icon"', site: site)

      expect(result).to include("<circle/>")
    end

    it "uses minimal defaults for custom icons" do
      custom_dir = File.join(@tmpdir, "_lucide")
      write_custom_icon(custom_dir, "my-custom-icon", "<circle/>")

      site = make_site("source" => @tmpdir)
      result = render_tag('"my-custom-icon"', site: site)

      expect(result).to include('aria-hidden="true"')
      expect(result).to include('width="24"')
      expect(result).to include('height="24"')
      expect(result).to include('viewBox="0 0 24 24"')
      expect(result).not_to include('fill=')
      expect(result).not_to include('stroke=')
      expect(result).not_to include('stroke-width=')
      expect(result).not_to include('stroke-linecap=')
      expect(result).not_to include('stroke-linejoin=')
    end

    it "allows custom icons to set fill and stroke via tag options" do
      custom_dir = File.join(@tmpdir, "_lucide")
      write_custom_icon(custom_dir, "my-filled-icon", '<path d="M0 0"/>')

      site = make_site("source" => @tmpdir)
      result = render_tag('"my-filled-icon" fill="currentColor"', site: site)

      expect(result).to include('fill="currentColor"')
      expect(result).not_to include('stroke=')
    end

    it "overrides a bundled icon with a custom one" do
      custom_dir = File.join(@tmpdir, "_lucide")
      write_custom_icon(custom_dir, "home", "<rect/>")

      site = make_site("source" => @tmpdir)
      result = render_tag('"home"', site: site)

      expect(result).to include("<rect/>")
      expect(result).not_to include("<path")
    end

    it "supports a custom directory via lucide.custom_icons_dir" do
      custom_dir = File.join(@tmpdir, "_my_icons")
      write_custom_icon(custom_dir, "my-icon", "<line/>")

      site = make_site("source" => @tmpdir, "lucide" => { "custom_icons_dir" => "_my_icons" })
      result = render_tag('"my-icon"', site: site)

      expect(result).to include("<line/>")
    end

    it "falls back to bundled icons with full defaults" do
      site = make_site("source" => @tmpdir)
      result = render_tag('"home"', site: site)

      expect(result).to include("<path")
      expect(result).to include('stroke="currentColor"')
      expect(result).to include('fill="none"')
    end

    it "raises an error when icon not found in either location" do
      site = make_site("source" => @tmpdir)
      result = render_tag('"nonexistent-icon-xyz"', site: site)

      expect(result).to include("Liquid error")
    end
  end

  describe "error handling" do
    it "raises an error for unknown icons" do
      result = render_tag('"nonexistent-icon-xyz"')

      expect(result).to include("Liquid error")
    end
  end

  describe "HTML escaping" do
    it "escapes HTML in attribute values" do
      result = render_tag('"home" class="<script>alert(1)</script>"')

      expect(result).not_to include("<script>")
      expect(result).to include("&lt;script&gt;")
    end
  end
end
