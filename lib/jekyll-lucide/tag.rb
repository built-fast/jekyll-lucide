# frozen_string_literal: true

module JekyllLucide
  class Tag < Liquid::Tag
    # Regex patterns based on Jekyll's include tag
    VALID_SYNTAX = %r!
      ([\w-]+)\s*=\s*
      (?:"([^"\\]*(?:\\.[^"\\]*)*)"|'([^'\\]*(?:\\.[^'\\]*)*)'|([\w.-]+))
    !x.freeze

    VARIABLE_SYNTAX = %r!
      (?<variable>[^{]*(\{\{\s*[\w\-.]+\s*(\|.*)?\}\}[^\s{}]*)+)
      |(?<name>[\w.-]+)
      |(?<quoted>(?:"[^"]*"|'[^']*'))
    !x.freeze

    def initialize(tag_name, markup, tokens)
      super
      @markup = markup.strip
    end

    def render(context)
      site = context.registers[:site]
      icon_name = parse_icon_name(context)
      options = parse_options(context)

      inner_svg, custom = load_icon(site, icon_name)

      defaults = custom ? JekyllLucide::BASE_OPTIONS : JekyllLucide::DEFAULT_OPTIONS
      config_defaults = site.config.dig("lucide", "defaults") || {}
      attrs = defaults
        .merge(config_defaults)
        .merge(options)

      build_svg(inner_svg, attrs)
    end

    private

    def parse_icon_name(context)
      match = @markup.match(VARIABLE_SYNTAX)
      return "" unless match

      if match[:quoted]
        match[:quoted].gsub(/\A['"]|['"]\z/, "")
      elsif match[:variable]
        Liquid::Template.parse("{{#{match[:variable]}}}").render(context)
      elsif match[:name]
        context[match[:name]] || match[:name]
      else
        ""
      end
    end

    def parse_options(context)
      options = {}

      @markup.scan(VALID_SYNTAX) do |key, d_quoted, s_quoted, variable|
        value = if d_quoted
                  d_quoted.gsub('\\"', '"')
                elsif s_quoted
                  s_quoted.gsub("\\'", "'")
                elsif variable
                  context[variable].to_s
                else
                  ""
                end

        options[key] = value
      end

      if (size = options.delete("size"))
        options["width"] = size
        options["height"] = size
      end

      options
    end

    def load_icon(site, name)
      custom_dir = site.config.dig("lucide", "custom_icons_dir") || "_lucide"
      custom_path = File.join(site.source, custom_dir, "#{name}.svg")
      return [File.read(custom_path), true] if File.exist?(custom_path)

      bundled_path = File.join(JekyllLucide::GEM_ROOT, "icons", "#{name}.svg")
      raise ArgumentError, "Unknown icon '#{name}'" unless File.exist?(bundled_path)

      [File.read(bundled_path), false]
    end

    def build_svg(inner, attrs)
      attr_str = attrs.map { |k, v| %(#{k}="#{escape_html(v)}") }.join(" ")
      %(<svg #{attr_str}>#{inner}</svg>)
    end

    def escape_html(str)
      str.to_s
        .gsub("&", "&amp;")
        .gsub('"', "&quot;")
        .gsub("<", "&lt;")
        .gsub(">", "&gt;")
    end
  end
end

Liquid::Template.register_tag("lucide_icon", JekyllLucide::Tag)
