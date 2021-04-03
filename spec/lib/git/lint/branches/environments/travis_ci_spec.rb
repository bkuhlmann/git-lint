# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Branches::Environments::TravisCI do
  subject :branch do
    described_class.new repository: repository, shell: shell, environment: environment
  end

  let(:repository) { instance_spy GitPlus::Repository, branch_default: "main" }
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
        expect(branch.name).to eq("pr_test")
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
        expect(branch.name).to eq("ci_test")
      end
    end
  end

  describe "#commits" do
    context "with pull request branch and without slug" do
      let :shell do
        class_spy Open3, capture3: ["git remote set-branches --add origin main", "git fetch"]
      end

      let :environment do
        {
          "TRAVIS_PULL_REQUEST_BRANCH" => "test_name",
          "TRAVIS_PULL_REQUEST_SLUG" => ""
        }
      end

      it "uses specific start and finish range" do
        branch.commits
        expect(repository).to have_received(:commits).with("origin/main..test_name")
      end
    end

    context "with pull request branch and slug" do
      let :shell do
        class_spy Open3,
                  capture3: [
                    "git remote add -f original_branch https://github.com/test_slug.git",
                    "git fetch original_branch test_name:test_name"
                  ]
      end

      let :environment do
        {
          "TRAVIS_PULL_REQUEST_BRANCH" => "test_name",
          "TRAVIS_PULL_REQUEST_SLUG" => "test_slug"
        }
      end

      it "uses specific start and finish range" do
        branch.commits
        expect(repository).to have_received(:commits).with("origin/main..test_name")
      end
    end
  end
end
