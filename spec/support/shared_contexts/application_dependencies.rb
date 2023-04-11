# frozen_string_literal: true

require "dry/container/stub"
require "infusible/stub"

RSpec.shared_context "with application dependencies" do
  using Infusible::Stub

  let :configuration do
    YAML.load_file(Bundler.root.join("tmp/defaults.yml")).then do |settings|
      Git::Lint::Configuration::Loader.new(client: settings).call
    end
  end

  let(:environment) { Hash.new }
  let(:kernel) { class_spy Kernel }
  let(:logger) { Cogger.new io: StringIO.new, formatter: :emoji }

  before { Git::Lint::Import.stub configuration:, environment:, kernel:, logger: }

  after { Git::Lint::Import.unstub :configuration, :environment, :kernel, :logger }
end
