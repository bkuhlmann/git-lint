# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Branches::Feature do
  subject(:feature_branch) { described_class.new environment: environment }

  include_context "with Git repository"

  let(:environment) { {} }

  describe ".initialize" do
    let(:git_repo) { instance_spy GitPlus::Repository, exist?: exist }

    context "when Git repository exists" do
      let(:exist) { true }

      it "does not fail with error" do
        result = -> { described_class.new git_repo: git_repo }
        expect(&result).not_to raise_error
      end
    end

    context "when Git repository doesn't exist" do
      let(:exist) { false }

      it "fails with base error" do
        result = -> { described_class.new git_repo: git_repo }
        expect(&result).to raise_error(
          Git::Lint::Errors::Base,
          "Invalid repository. Are you within a Git-enabled project?"
        )
      end
    end
  end

  describe "#name" do
    context "with Circle CI environment" do
      let :environment do
        {
          "CIRCLECI" => "true",
          "GITHUB_ACTIONS" => "false",
          "NETLIFY" => "false",
          "TRAVIS" => "false"
        }
      end

      it "answers name" do
        Dir.chdir git_repo_dir do
          `git switch --create test --track`
          expect(feature_branch.name).to eq("origin/test")
        end
      end
    end

    context "with GitHub Action environment" do
      let :environment do
        {
          "CIRCLECI" => "false",
          "GITHUB_ACTIONS" => "true",
          "NETLIFY" => "false",
          "TRAVIS" => "false"
        }
      end

      it "answers name" do
        Dir.chdir git_repo_dir do
          `git switch --create test --track`
          expect(feature_branch.name).to eq("origin/test")
        end
      end
    end

    context "with Netlify CI environment" do
      let :environment do
        {
          "CIRCLECI" => "false",
          "GITHUB_ACTIONS" => "false",
          "NETLIFY" => "true",
          "HEAD" => "test",
          "TRAVIS" => "false"
        }
      end

      it "answers name" do
        Dir.chdir git_repo_dir do
          `git switch --create test --track`
          expect(feature_branch.name).to eq("test")
        end
      end
    end

    context "with Travis CI environment" do
      let :environment do
        {
          "CIRCLECI" => "false",
          "GITHUB_ACTIONS" => "false",
          "NETLIFY" => "false",
          "TRAVIS" => "true",
          "TRAVIS_PULL_REQUEST_BRANCH" => "test"
        }
      end

      it "answers name" do
        Dir.chdir git_repo_dir do
          `git switch --create test --track`
          expect(feature_branch.name).to eq("test")
        end
      end
    end

    context "with local environment" do
      before do
        Dir.chdir git_repo_dir do
          `git switch --create test --track`
        end
      end

      it "answers name" do
        Dir.chdir git_repo_dir do
          expect(feature_branch.name).to eq("test")
        end
      end
    end
  end

  describe "#commits" do
    context "with local environment" do
      before do
        Dir.chdir git_repo_dir do
          `git switch --create test --track`
          `touch test.txt && git add . && git commit --message "Added test file"`
        end
      end

      it "answers SHA strings" do
        Dir.chdir git_repo_dir do
          subjects = feature_branch.commits.map(&:subject)
          expect(subjects).to contain_exactly("Added test file")
        end
      end

      it "answers SHA count" do
        Dir.chdir git_repo_dir do
          expect(feature_branch.commits.count).to eq(1)
        end
      end
    end
  end
end
