# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Commits::Loader do
  using Refinements::Pathname
  using Infusible::Stub

  subject(:loader) { described_class.new }

  include_context "with Git repository"
  include_context "with host dependencies"

  before { Git::Lint::Commits::Hosts::Import.stub git:, environment: }

  after { Git::Lint::Commits::Hosts::Import.unstub :git, :environment }

  describe "#call" do
    context "with Circle CI" do
      let :environment do
        {
          "CIRCLECI" => "true",
          "GITHUB_ACTIONS" => "false",
          "NETLIFY" => "false",
          "TRAVIS" => "false"
        }
      end

      it "computes correct commit range" do
        loader.call
        expect(git).to have_received(:commits).with("origin/main..origin/test")
      end
    end

    context "with GitHub Actions" do
      let :environment do
        {
          "CIRCLECI" => "false",
          "GITHUB_ACTIONS" => "true",
          "NETLIFY" => "false",
          "TRAVIS" => "false"
        }
      end

      it "computes correct commit range" do
        loader.call
        expect(git).to have_received(:commits).with("origin/main..origin/test")
      end
    end

    context "with Netlify CI" do
      let :environment do
        {
          "CIRCLECI" => "false",
          "GITHUB_ACTIONS" => "false",
          "NETLIFY" => "true",
          "HEAD" => "test",
          "TRAVIS" => "false"
        }
      end

      it "computes correct commit range" do
        loader.call
        expect(git).to have_received(:commits).with("origin/main..origin/test")
      end
    end

    context "with local host" do
      let(:git) { Gitt::Repository.new }

      before do
        git_repo_dir.change_dir do
          `git switch --quiet --create test --track`
          `touch test.txt && git add . && git commit --message "Added test file"`
        end
      end

      it "answers commits" do
        git_repo_dir.change_dir do
          expect(loader.call.success.map(&:subject)).to contain_exactly("Added test file")
        end
      end
    end

    context "when Git repository doesn't exist" do
      let(:git) { instance_spy Gitt::Repository, exist?: false }

      it "fails with base error" do
        expectation = -> { loader.call }

        expect(&expectation).to raise_error(
          Git::Lint::Errors::Base,
          "Invalid repository. Are you within a Git repository?"
        )
      end
    end
  end
end
