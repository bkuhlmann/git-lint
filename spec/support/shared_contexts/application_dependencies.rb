# frozen_string_literal: true

RSpec.shared_context "with application dependencies" do
  using Refinements::Struct

  include_context "with temporary directory"

  let(:settings) { Git::Lint::Container[:settings] }
  let(:environment) { Hash.new }
  let(:kernel) { class_spy Kernel }
  let(:logger) { Cogger.new id: "git-lint", io: StringIO.new, level: :debug }

  before do
    settings.merge! Etcher.call(
      Git::Lint::Container[:registry].remove_loader(1),
      commits_body_presence_enabled: false,
      commits_signature_includes: %w[Good Invalid]
    )

    Git::Lint::Container.stub! environment:, kernel:, logger:
  end

  after { Git::Lint::Container.restore }
end
