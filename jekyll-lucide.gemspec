# frozen_string_literal: true

require_relative "lib/jekyll-lucide/version"

Gem::Specification.new do |spec|
  spec.name = "jekyll-lucide"
  spec.version = JekyllLucide::VERSION
  spec.authors = ["Joshua Priddle"]
  spec.email = ["jpriddle@me.com"]

  spec.summary = "Lucide icons for Jekyll"
  spec.description = "A Jekyll plugin that provides Lucide icons as inline SVGs via a Liquid tag."
  spec.homepage = "https://github.com/built-fast/jekyll-lucide"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage

  spec.files = Dir.chdir(__dir__) do
    Dir["{lib,icons}/**/*", "LICENSE", "README.md"]
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "jekyll", ">= 3.7", "< 5.0"
end
