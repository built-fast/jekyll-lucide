# frozen_string_literal: true

require "jekyll"
require "jekyll-lucide"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run_when_matching :focus
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
end

Jekyll.logger.log_level = :error

def make_site(options = {})
  config = Jekyll.configuration(options.merge(skip_config_files: true))
  Jekyll::Site.new(config)
end

def make_context(site: nil, page: nil, variables: {})
  site ||= make_site
  page ||= {}
  registers = { site: site, page: page }
  Liquid::Context.new(variables, {}, registers)
end

def render_tag(markup, context: nil, site: nil, page: nil, variables: {})
  context ||= make_context(site: site, page: page, variables: variables)
  template = Liquid::Template.parse("{% lucide_icon #{markup} %}")
  template.render(context)
end
