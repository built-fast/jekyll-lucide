# frozen_string_literal: true

require "optparse"
require "fileutils"

module JekyllLucide
  module CLI
    module_function

    def run(args)
      command = args.shift

      case command
      when "install-icon"
        install_icon(args)
      when nil, "-h", "--help"
        puts usage
      else
        abort "Unknown command: #{command}\n\n#{usage}"
      end
    end

    def usage
      <<~TEXT
        Usage: jekyll-lucide <command> [options]

        Commands:
          install-icon [OPTIONS] FILE...   Install custom SVG icons
      TEXT
    end

    def install_icon(args)
      dir = "_lucide"
      name = nil

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: jekyll-lucide install-icon [OPTIONS] FILE..."

        opts.on("--dir DIR", "Output directory (default: _lucide)") do |d|
          dir = d
        end

        opts.on("--name NAME", "Override output filename (single file only)") do |n|
          name = n
        end
      end

      parser.parse!(args)

      if args.empty?
        abort "Error: no SVG files specified\n\n#{parser}"
      end

      if name && args.length > 1
        abort "Error: --name can only be used with a single file"
      end

      args.each do |file|
        install_single_icon(file, dir: dir, name: name)
      end
    end

    def install_single_icon(file, dir:, name:)
      abort "Error: file not found: #{file}" unless File.exist?(file)

      content = File.read(file)

      inner = extract_inner_svg(content)

      unless inner
        abort "Error: no <svg> tags found in #{file}"
      end

      output_name = name || File.basename(file, ".svg")
      output_path = File.join(dir, "#{output_name}.svg")

      FileUtils.mkdir_p(dir)
      File.write(output_path, inner)

      puts "Installed #{output_path}"
    end

    def extract_inner_svg(content)
      if content =~ %r{<svg[^>]*>(.*)</svg>}m
        $1.gsub(/\s*\n\s*/, "").strip
      end
    end
  end
end
