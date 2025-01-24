# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::CLI::Actions::Hook do
  using Refinements::Pathname
  using Refinements::StringIO

  subject(:action) { described_class.new }

  include_context "with application dependencies"
  include_context "with Git repository"

  describe "#call" do
    it "answers valid commit results" do
      git_repo_dir.change_dir do
        action.call SPEC_ROOT.join("support/fixtures/commit-valid.txt")
        expect(io.reread).to match(/1 commit.+0 issues/m)
      end
    end

    it "answers invalid commit results" do
      git_repo_dir.change_dir do
        action.call SPEC_ROOT.join("support/fixtures/commit-invalid.txt")
        expect(io.reread).to match(/1 commit.+2 issues/m)
      end
    end

    it "aborts with invalid commit" do
      git_repo_dir.change_dir do
        action.call SPEC_ROOT.join("support/fixtures/commit-invalid.txt")
        expect(kernel).to have_received(:abort)
      end
    end
  end
end
