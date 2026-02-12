# frozen_string_literal: true

require "jekyll"
require_relative "jekyll-lucide/version"
require_relative "jekyll-lucide/tag"

module JekyllLucide
  GEM_ROOT = File.expand_path("..", __dir__)

  BASE_OPTIONS = {
    "aria-hidden" => "true",
    "width" => "24",
    "height" => "24",
    "viewBox" => "0 0 24 24"
  }.freeze

  STROKE_OPTIONS = {
    "fill" => "none",
    "stroke" => "currentColor",
    "stroke-width" => "2",
    "stroke-linecap" => "round",
    "stroke-linejoin" => "round"
  }.freeze

  DEFAULT_OPTIONS = BASE_OPTIONS.merge(STROKE_OPTIONS).freeze
end
