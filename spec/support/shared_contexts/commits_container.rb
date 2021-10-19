# frozen_string_literal: true

require "dry/container/stub"

RSpec.shared_context "with commits container" do
  let(:container) { Git::Lint::Commits::Container }
  let(:repository) { instance_spy GitPlus::Repository, branch_default: "main", branch_name: "test" }
  let(:shell) { class_spy Open3 }
  let(:environment) { Hash.new }

  before do
    container.enable_stubs!
    container.stub :repository, repository
    container.stub :shell, shell
    container.stub :environment, environment
  end

  after do
    container.unstub :repository
    container.unstub :shell
    container.unstub :environment
  end
end
