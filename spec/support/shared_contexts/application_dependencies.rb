# frozen_string_literal: true

RSpec.shared_context "with application dependencies" do
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
  let(:logger) { Cogger.new id: "git-lint", io: StringIO.new, level: :debug }

  before { Git::Lint::Container.stub! configuration:, environment:, xdg_config:, kernel:, logger: }

  after { Git::Lint::Container.restore }
end
