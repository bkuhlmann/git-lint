# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::Commits::Many do
  using Refinements::Pathname
  using Refinements::Struct

  subject(:analyzer) { described_class.new collector: }

  include_context "with Git repository"
  include_context "with application dependencies"

  let(:collector) { Git::Lint::Collector.new }

  describe "#call" do
    let(:commits) { Git::Lint::Commits::Loader.new.call.value_or [] }

    before do
      settings.commits_subject_duplication_enabled = true

      git_repo_dir.change_dir do
        `git switch --quiet --create test --track`
        `printf "%s\n" "Test content" > one.txt`
        `git add --all .`
      end
    end

    it "reports no items or issues with valid commits" do
      git_repo_dir.change_dir do
        `git commit --no-verify --message "Added one.txt" --message "For testing purposes"`
        collector = analyzer.call commits

        expect(collector.total).to eq(Git::Lint::Models::Total.new)
      end
    end

    it "reports issues with zero items for invalid commits" do
      git_repo_dir.change_dir do
        `git commit --no-verify --message "Added one.txt" --message "A test."`
        `printf "%s\n" "Test content" > two.txt`
        `git add --all .`
        `git commit --no-verify --message "Added one.txt" --message "A test."`
        collector = analyzer.call commits

        expect(collector.total).to eq(Git::Lint::Models::Total[items: 0, issues: 1, errors: 1])
      end
    end

    it "reports no issues with disabled analyzers" do
      settings.commits_subject_duplication_enabled = false

      git_repo_dir.change_dir do
        `git commit --no-verify --message "Bogus commit message"`
        collector = analyzer.call commits

        expect(collector.total).to eq(Git::Lint::Models::Total.new)
      end
    end

    it "answers collector" do
      expect(analyzer.call(commits)).to be_a(Git::Lint::Collector)
    end
  end
end
