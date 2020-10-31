# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Branches::Environments::GitHubAction do
  subject(:git_hub_action) { described_class.new repo: repo }

  let(:repo) { instance_spy Git::Kit::Repo, branch_name: "test", shas: %w[abc def] }

  describe "#name" do
    it "answers Git branch name" do
      expect(git_hub_action.name).to eq("origin/test")
    end
  end

  describe "#shas" do
    it "uses spegit_hub_actionfic start and finish range" do
      git_hub_action.shas
      expect(repo).to have_received(:shas).with(start: "origin/master", finish: "origin/test")
    end

    it "answers Git commit SHAs" do
      expect(git_hub_action.shas).to contain_exactly("abc", "def")
    end
  end
end
