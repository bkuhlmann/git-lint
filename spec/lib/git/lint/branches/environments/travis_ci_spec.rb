# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Branches::Environments::TravisCI do
  subject(:travis_ci) { described_class.new environment: environment, repo: repo, shell: shell }

  let(:environment) { {} }
  let(:repo) { instance_spy Git::Kit::Repo, shas: %w[abc def] }
  let(:shell) { class_spy Open3 }

  describe "#name" do
    context "with pull request branch" do
      let :environment do
        {
          "TRAVIS_PULL_REQUEST_BRANCH" => "pr_test",
          "TRAVIS_BRANCH" => "ci_test"
        }
      end

      it "answers pull request branch name" do
        expect(travis_ci.name).to eq("pr_test")
      end
    end

    context "without pull request branch and CI branch" do
      let :environment do
        {
          "TRAVIS_PULL_REQUEST_BRANCH" => "",
          "TRAVIS_BRANCH" => "ci_test"
        }
      end

      it "answers CI branch name" do
        expect(travis_ci.name).to eq("ci_test")
      end
    end
  end

  describe "#shas" do
    let(:commits_command) { %(git log --pretty=format:"%H" origin/master..test_name) }

    before do
      allow(shell).to receive(:capture2e).with("git remote set-branches --add origin master")
      allow(shell).to receive(:capture2e).with("git fetch")
    end

    context "with pull request branch and without slug" do
      let :environment do
        {
          "TRAVIS_PULL_REQUEST_BRANCH" => "test_name",
          "TRAVIS_PULL_REQUEST_SLUG" => ""
        }
      end

      it "uses specific start and finish range" do
        travis_ci.shas
        expect(repo).to have_received(:shas).with(start: "origin/master", finish: "test_name")
      end

      it "answers Git commit SHAs" do
        expect(travis_ci.shas).to contain_exactly("abc", "def")
      end
    end

    context "with pull request branch and slug" do
      let :environment do
        {
          "TRAVIS_PULL_REQUEST_BRANCH" => "test_name",
          "TRAVIS_PULL_REQUEST_SLUG" => "test_slug"
        }
      end

      let :remote_add_command do
        "git remote add -f original_branch https://github.com/test_slug.git"
      end

      let(:remote_fetch_command) { "git fetch original_branch test_name:test_name" }

      before do
        allow(shell).to receive(:capture2e).with(remote_add_command)
        allow(shell).to receive(:capture2e).with(remote_fetch_command)
      end

      it "uses specific start and finish range" do
        travis_ci.shas
        expect(repo).to have_received(:shas).with(start: "origin/master", finish: "test_name")
      end

      it "answers Git commit SHAs" do
        expect(travis_ci.shas).to contain_exactly("abc", "def")
      end
    end
  end
end
