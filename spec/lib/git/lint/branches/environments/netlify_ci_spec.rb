# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Branches::Environments::NetlifyCI do
  subject(:netlify_ci) { described_class.new environment: environment, repo: repo, shell: shell }

  let(:environment) { {"HEAD" => "test", "REPOSITORY_URL" => "https://www.example.com/test.git"} }
  let(:repo) { instance_spy Git::Kit::Repo, shas: %w[abc def] }
  let(:shell) { class_spy Open3 }

  describe "#name" do
    it "answers Git branch name" do
      expect(netlify_ci.name).to eq("test")
    end
  end

  describe "#shas" do
    it "adds remote origin branch" do
      netlify_ci.shas

      expect(shell).to have_received(:capture2e).with(
        "git remote add -f origin https://www.example.com/test.git"
      )
    end

    it "fetches feature branch" do
      netlify_ci.shas
      expect(shell).to have_received(:capture2e).with("git fetch origin test:test")
    end

    it "uses specific start and finish range" do
      netlify_ci.shas
      expect(repo).to have_received(:shas).with(start: "origin/master", finish: "origin/test")
    end

    it "answers Git commit SHAs" do
      expect(netlify_ci.shas).to contain_exactly("abc", "def")
    end
  end
end
