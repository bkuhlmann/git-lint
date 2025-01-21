# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::Commits::Sole do
  using Refinements::Pathname
  using Refinements::Struct

  subject(:analyzer) { described_class.new collector: }

  include_context "with Git repository"
  include_context "with application dependencies"

  let(:collector) { Git::Lint::Collector.new }

  describe "#call" do
    let(:commits) { Git::Lint::Commits::Loader.new.call.value_or [] }

    before do
      git_repo_dir.change_dir do
        `git switch --quiet --create test --track`
        `printf "%s\n" "Test content" > one.txt`
        `git add --all .`
      end
    end

    it "reports no issues with valid commits" do
      git_repo_dir.change_dir do
        `git commit --no-verify --message "Added one.txt" --message "For testing purposes"`
        collector = analyzer.call commits

        expect(collector.total).to eq(Git::Lint::Models::Total[items: 1])
      end
    end

    it "reports issues with invalid commits" do
      git_repo_dir.change_dir do
        `git commit --no-verify --message "Add one.txt" --message "- A test bullet"`
        collector = analyzer.call commits

        expect(collector.total).to eq(Git::Lint::Models::Total[items: 1, issues: 2, errors: 2])
      end
    end

    it "reports no issues with disabled analyzer" do
      settings.commits_subject_prefix_enabled = false

      git_repo_dir.change_dir do
        `git commit --no-verify --message "Bogus commit message"`
        collector = analyzer.call commits

        expect(collector.total).to eq(Git::Lint::Models::Total[items: 1])
      end
    end

    it "reports no issues with no analyzers" do
      described_class.new(collector:, analyzers: []).call commits
      expect(collector.total).to eq(Git::Lint::Models::Total.new)
    end

    context "with single commit" do
      include_context "with Git commit"

      it "processes commit" do
        collector = analyzer.call [git_commit]
        expect(collector.total).to eq(Git::Lint::Models::Total[items: 1, issues: 1, warnings: 1])
      end
    end

    it "answers collector" do
      expect(analyzer.call).to be_a(Git::Lint::Collector)
    end
  end
end
