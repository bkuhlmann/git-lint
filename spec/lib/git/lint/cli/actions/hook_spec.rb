# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::CLI::Actions::Hook do
  using Refinements::Pathnames

  subject(:action) { described_class.new }

  include_context "with application dependencies"
  include_context "with Git repository"

  describe "#call" do
    it "answers valid commit results" do
      git_repo_dir.change_dir do
        action.call Bundler.root.join("spec/support/fixtures/commit-valid.txt")
        expect(kernel).to have_received(:puts).with(/1 commit.+0 issues/m)
      end
    end

    it "answers invalid commit results" do
      git_repo_dir.change_dir do
        action.call Bundler.root.join("spec/support/fixtures/commit-invalid.txt")
        expect(kernel).to have_received(:puts).with(/1 commit.+4 issues/m)
      end
    end

    it "aborts with errors" do
      git_repo_dir.change_dir do
        action.call Bundler.root.join("spec/support/fixtures/commit-invalid.txt")
        expect(kernel).to have_received(:abort)
      end
    end
  end
end
