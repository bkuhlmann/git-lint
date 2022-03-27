# frozen_string_literal: true

require "dry/container/stub"
require "auto_injector/stub"

RSpec.shared_context "with application dependencies" do
  using AutoInjector::Stub

  let(:configuration) { Git::Lint::Configuration::Loader.with_defaults.call }
  let(:environment) { Hash.new }
  let(:kernel) { class_spy Kernel }

  let :logger do
    Cogger::Client.new Logger.new(StringIO.new),
                       formatter: ->(_severity, _name, _at, message) { "#{message}\n" }
  end

  before { Git::Lint::Import.stub configuration:, environment:, kernel:, logger: }

  after { Git::Lint::Import.unstub :configuration, :environment, :kernel, :logger }
end
