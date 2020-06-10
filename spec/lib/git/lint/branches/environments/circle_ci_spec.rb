# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Branches::Environments::CircleCI do
  subject(:circle_ci) { described_class.new repo: repo }

  let(:repo) { instance_spy Git::Kit::Repo, branch_name: "test", shas: %w[abc def] }

  describe "#name" do
    it "answers Git branch name" do
      expect(circle_ci.name).to eq("origin/test")
    end
  end

  describe "#shas" do
    it "uses specific start and finish range" do
      circle_ci.shas
      expect(repo).to have_received(:shas).with(start: "origin/master", finish: "origin/test")
    end

    it "answers Git commit SHAs" do
      expect(circle_ci.shas).to contain_exactly("abc", "def")
    end
  end
end
