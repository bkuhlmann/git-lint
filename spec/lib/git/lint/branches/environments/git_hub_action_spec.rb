# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Branches::Environments::GitHubAction do
  subject(:branch) { described_class.new repository: repository }

  let(:repository) { instance_spy GitPlus::Repository, branch_default: "main", branch_name: "test" }

  describe "#name" do
    it "answers Git branch name" do
      expect(branch.name).to eq("origin/test")
    end
  end

  describe "#commits" do
    it "uses specific start and finish range" do
      branch.commits
      expect(repository).to have_received(:commits).with("origin/main..origin/test")
    end
  end
end
