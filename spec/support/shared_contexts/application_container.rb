# frozen_string_literal: true

require "dry/container/stub"
require "auto_injector/stub"

RSpec.shared_context "with application container" do
  using AutoInjector::Stub

  let(:configuration) { Git::Lint::Configuration::Loader.with_defaults.call }
  let(:environment) { Hash.new }
  let(:kernel) { class_spy Kernel }
  let(:logger) { Logger.new io, formatter: ->(_severity, _name, _at, message) { "#{message}\n" } }
  let(:io) { StringIO.new }

  before { Git::Lint::Import.stub configuration:, environment:, kernel:, logger: }

  after { Git::Lint::Import.unstub configuration:, environment:, kernel:, logger: }
end
