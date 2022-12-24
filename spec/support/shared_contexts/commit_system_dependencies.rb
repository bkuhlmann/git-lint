# frozen_string_literal: true

require "dry/monads"

RSpec.shared_context "with commit system dependencies" do
  include Dry::Monads[:result]

  using Infusible::Stub

  include_context "with application dependencies"

  let :git do
    instance_spy Gitt::Repository,
                 call: Success(),
                 branch_default: Success("main"),
                 branch_name: Success("test")
  end

  before { Git::Lint::Import.stub git: }

  after { Git::Lint::Import.unstub :git }
end
