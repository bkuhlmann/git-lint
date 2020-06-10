# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Branches::Environments::Local do
  subject(:local) { described_class.new repo: repo }

  let(:repo) { instance_spy Git::Kit::Repo, branch_name: "test", shas: %w[abc def] }

  describe "#name" do
    it "answers Git branch name" do
      expect(local.name).to eq("test")
    end
  end

  describe "#shas" do
    it "uses specific start and finish range" do
      local.shas
      expect(repo).to have_received(:shas).with(start: "master", finish: "test")
    end

    it "answers Git commit SHAs" do
      expect(local.shas).to contain_exactly("abc", "def")
    end
  end
end
