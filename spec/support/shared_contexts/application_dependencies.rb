# frozen_string_literal: true

require "dry/container/stub"
require "infusible/stub"

RSpec.shared_context "with application dependencies" do
  using Infusible::Stub

  include_context "with temporary directory"

  let :configuration do
    Etcher.new(Git::Lint::Container[:defaults])
          .call(
            commits_body_presence_enabled: false,
            commits_signature_includes: %w[Good Invalid]
          )
          .bind(&:dup)
  end

  let(:environment) { Hash.new }
  let(:xdg_config) { Runcom::Config.new Git::Lint::Container[:defaults_path] }
  let(:kernel) { class_spy Kernel }
  let(:logger) { Cogger.new io: StringIO.new, level: :debug, formatter: :emoji }

  before { Git::Lint::Import.stub configuration:, environment:, xdg_config:, kernel:, logger: }

  after { Git::Lint::Import.unstub :configuration, :environment, :xdg_config, :kernel, :logger }
end
