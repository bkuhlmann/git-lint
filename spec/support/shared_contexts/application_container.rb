# frozen_string_literal: true

require "dry/container/stub"

RSpec.shared_context "with application container" do
  let(:container) { Git::Lint::Container }
  let(:configuration) { Git::Lint::Configuration::Loader.with_defaults.call }
  let(:environment) { Hash.new }
  let(:kernel) { class_spy Kernel }
  let(:logger) { Logger.new io, formatter: ->(_severity, _name, _at, message) { "#{message}\n" } }
  let(:io) { StringIO.new }

  before do
    container.enable_stubs!
    container.stub :configuration, configuration
    container.stub :environment, environment
    container.stub :kernel, kernel
    container.stub :logger, logger
  end

  after do
    container.unstub :environment
    container.unstub :kernel
    container.unstub :logger
  end
end
