# frozen_string_literal: true

require "dry/container/stub"

RSpec.shared_context "with application container" do
  let(:container) { Git::Lint::Container }
  let(:configuration) { Git::Lint::Configuration::Loader.with_defaults.call }
  let(:environment) { Hash.new }
  let(:kernel) { class_spy Kernel }

  before do
    container.enable_stubs!
    container.stub :configuration, configuration
    container.stub :environment, environment
    container.stub :kernel, kernel
  end

  after do
    container.unstub :environment
    container.unstub :kernel
  end
end
