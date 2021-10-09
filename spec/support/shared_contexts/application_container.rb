# frozen_string_literal: true

require "dry/container/stub"

RSpec.shared_context "with application container" do
  let(:container) { Git::Lint::Container }
  let(:configuration) { Git::Lint::Configuration::Loader.with_defaults.call }
  let(:kernel) { class_spy Kernel }

  before do
    container.enable_stubs!
    container.stub :configuration, configuration
    container.stub :kernel, kernel
  end

  after { container.unstub :kernel }
end
