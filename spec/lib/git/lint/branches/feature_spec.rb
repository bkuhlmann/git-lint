# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Branches::Feature do
  subject(:feature_branch) { described_class.new environment: environment }

  let(:environment) { {} }

  describe ".initialize", :temp_dir do
    let(:git_repo) { instance_spy Git::Kit::Repo, exist?: exist }

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
    context "with Circle CI environments", :git_repo do
      let :environment do
        {
          "CIRCLECI" => "true",
          "NETLIFY" => "false",
          "TRAVIS" => "false"
        }
      end

      it "answers name" do
        Dir.chdir git_repo_dir do
          git_create_branch
          expect(feature_branch.name).to eq("origin/test")
        end
      end
    end

    context "with Netlify CI environments", :git_repo do
      let :environment do
        {
          "CIRCLECI" => "false",
          "NETLIFY" => "true",
          "HEAD" => "test",
          "TRAVIS" => "false"
        }
      end

      it "answers name" do
        Dir.chdir git_repo_dir do
          git_create_branch
          expect(feature_branch.name).to eq("test")
        end
      end
    end

    context "with Travis CI environments", :git_repo do
      let :environment do
        {
          "CIRCLECI" => "false",
          "NETLIFY" => "false",
          "TRAVIS" => "true",
          "TRAVIS_PULL_REQUEST_BRANCH" => "test"
        }
      end

      it "answers name" do
        Dir.chdir git_repo_dir do
          git_create_branch
          expect(feature_branch.name).to eq("test")
        end
      end
    end

    context "with local environment", :git_repo do
      before do
        Dir.chdir git_repo_dir do
          git_create_branch
        end
      end

      it "answers name" do
        Dir.chdir git_repo_dir do
          expect(feature_branch.name).to eq("test")
        end
      end
    end
  end

  describe "#shas" do
    context "with local environment", :git_repo do
      before do
        Dir.chdir git_repo_dir do
          git_create_branch
          git_commit_file "test.txt"
        end
      end

      it "answers SHA strings" do
        Dir.chdir git_repo_dir do
          expect(feature_branch.shas).to all(match(/[0-9a-f]{40}/))
        end
      end

      it "answers SHA count" do
        Dir.chdir git_repo_dir do
          expect(feature_branch.shas.count).to eq(1)
        end
      end
    end
  end

  describe "#commits" do
    context "with local environment", :git_repo do
      before do
        Dir.chdir git_repo_dir do
          git_create_branch
          git_commit_file "test.txt"
        end
      end

      it "answers saved commits" do
        Dir.chdir git_repo_dir do
          expect(feature_branch.commits).to all(be_a(Git::Lint::Commits::Saved))
        end
      end

      it "answers commit count" do
        Dir.chdir git_repo_dir do
          expect(feature_branch.commits.count).to eq(1)
        end
      end
    end
  end
end
