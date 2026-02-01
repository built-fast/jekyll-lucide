# frozen_string_literal: true

require "jekyll"
require_relative "jekyll-lucide/version"
require_relative "jekyll-lucide/tag"

module JekyllLucide
  GEM_ROOT = File.expand_path("..", __dir__)

  DEFAULT_OPTIONS = {
    "aria-hidden" => "true",
    "width" => "24",
    "height" => "24",
    "viewBox" => "0 0 24 24",
    "fill" => "none",
    "stroke" => "currentColor",
    "stroke-width" => "2",
    "stroke-linecap" => "round",
    "stroke-linejoin" => "round"
  }.freeze
end
