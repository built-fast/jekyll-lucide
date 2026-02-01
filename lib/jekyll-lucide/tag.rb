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

      config_defaults = site.config.dig("lucide", "defaults") || {}
      attrs = JekyllLucide::DEFAULT_OPTIONS
        .merge(config_defaults)
        .merge(options)

      inner_svg = load_icon(icon_name)
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

    def load_icon(name)
      path = File.join(JekyllLucide::GEM_ROOT, "icons", "#{name}.svg")
      raise ArgumentError, "Unknown Lucide icon '#{name}'" unless File.exist?(path)

      File.read(path)
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
