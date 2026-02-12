# frozen_string_literal: true

require "spec_helper"
require "jekyll-lucide/cli"

RSpec.describe JekyllLucide::CLI do
  let(:sample_svg) do
    <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
        <path d="M12 2L2 7l10 5 10-5-10-5z"/>
        <path d="M2 17l10 5 10-5"/>
      </svg>
    SVG
  end

  let(:expected_inner) { '<path d="M12 2L2 7l10 5 10-5-10-5z"/><path d="M2 17l10 5 10-5"/>' }

  around do |example|
    Dir.mktmpdir do |tmpdir|
      @tmpdir = tmpdir
      example.run
    end
  end

  def write_svg(name, content = sample_svg)
    path = File.join(@tmpdir, name)
    File.write(path, content)
    path
  end

  describe "install-icon" do
    it "strips outer <svg> tags and writes inner content" do
      input = write_svg("logo.svg")
      output = File.join(@tmpdir, "_lucide", "logo.svg")

      expect { described_class.run(["install-icon", "--dir", File.join(@tmpdir, "_lucide"), input]) }
        .to output(/Installed/).to_stdout

      expect(File.read(output)).to eq(expected_inner)
    end

    it "creates the output directory if it doesn't exist" do
      input = write_svg("logo.svg")
      output_dir = File.join(@tmpdir, "_lucide")

      expect(Dir.exist?(output_dir)).to be false

      expect { described_class.run(["install-icon", "--dir", output_dir, input]) }
        .to output(/Installed/).to_stdout

      expect(Dir.exist?(output_dir)).to be true
    end

    it "respects --dir option" do
      input = write_svg("logo.svg")
      custom_dir = File.join(@tmpdir, "_my_icons")

      expect { described_class.run(["install-icon", "--dir", custom_dir, input]) }
        .to output(/Installed/).to_stdout

      expect(File.exist?(File.join(custom_dir, "logo.svg"))).to be true
    end

    it "respects --name option" do
      input = write_svg("logo.svg")
      output_dir = File.join(@tmpdir, "_lucide")

      expect { described_class.run(["install-icon", "--dir", output_dir, "--name", "my-logo", input]) }
        .to output(/Installed/).to_stdout

      expect(File.exist?(File.join(output_dir, "my-logo.svg"))).to be true
      expect(File.exist?(File.join(output_dir, "logo.svg"))).to be false
    end

    it "errors on missing file" do
      expect { described_class.run(["install-icon", "--dir", @tmpdir, "/nonexistent/file.svg"]) }
        .to raise_error(SystemExit)
        .and output(/file not found/).to_stderr
    end

    it "errors on non-SVG / malformed SVG" do
      input = write_svg("bad.svg", "not an svg file")

      expect { described_class.run(["install-icon", "--dir", @tmpdir, input]) }
        .to raise_error(SystemExit)
        .and output(/no <svg> tags found/).to_stderr
    end

    it "handles multiple files" do
      input1 = write_svg("icon1.svg")
      input2 = write_svg("icon2.svg")
      output_dir = File.join(@tmpdir, "_lucide")

      expect { described_class.run(["install-icon", "--dir", output_dir, input1, input2]) }
        .to output(/Installed.*icon1.*\n.*Installed.*icon2/m).to_stdout

      expect(File.exist?(File.join(output_dir, "icon1.svg"))).to be true
      expect(File.exist?(File.join(output_dir, "icon2.svg"))).to be true
    end

    it "errors when --name is used with multiple files" do
      input1 = write_svg("icon1.svg")
      input2 = write_svg("icon2.svg")

      expect { described_class.run(["install-icon", "--dir", @tmpdir, "--name", "foo", input1, input2]) }
        .to raise_error(SystemExit)
        .and output(/--name can only be used with a single file/).to_stderr
    end

    it "errors when no files are specified" do
      expect { described_class.run(["install-icon"]) }
        .to raise_error(SystemExit)
        .and output(/no SVG files specified/).to_stderr
    end
  end

  describe "extract_inner_svg" do
    it "extracts content between svg tags" do
      result = described_class.extract_inner_svg(sample_svg)
      expect(result).to eq(expected_inner)
    end

    it "returns nil for content without svg tags" do
      result = described_class.extract_inner_svg("just some text")
      expect(result).to be_nil
    end

    it "collapses whitespace" do
      svg = "<svg>\n  <path/>\n  <circle/>\n</svg>"
      result = described_class.extract_inner_svg(svg)
      expect(result).to eq("<path/><circle/>")
    end
  end

  describe "unknown command" do
    it "exits with an error for unknown commands" do
      expect { described_class.run(["bogus"]) }
        .to raise_error(SystemExit)
        .and output(/Unknown command: bogus/).to_stderr
    end
  end

  describe "help" do
    it "prints usage with no arguments" do
      expect { described_class.run([]) }
        .to output(/Usage:.*install-icon/m).to_stdout
    end

    it "prints usage with --help" do
      expect { described_class.run(["--help"]) }
        .to output(/Usage:.*install-icon/m).to_stdout
    end
  end
end
