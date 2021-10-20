# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Commits::Systems::TravisCI do
  subject(:system) { described_class.new }

  include_context "with commits container"

  describe "#call" do
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
        system.call
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
        system.call
        expect(repository).to have_received(:commits).with("origin/main..test_name")
      end
    end
  end
end
