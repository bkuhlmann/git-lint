# frozen_string_literal: true

require "dry/monads"
require "spec_helper"

RSpec.describe Git::Lint::Analyzer do
  include Dry::Monads[:result]

  using Refinements::Pathnames

  subject(:analyzer) { described_class.new }

  include_context "with Git repository"
  include_context "with application dependencies"

  let(:branch) { "test" }

  before do
    git_repo_dir.change_dir do
      `git switch --quiet --create test --track`
      `printf "%s\n" "Test content" > one.txt`
      `git add --all .`
    end
  end

  describe "#call" do
    it "answers collector and reporter without block" do
      git_repo_dir.change_dir do
        `git commit --no-verify --message "Added one.txt" --message "- For testing purposes"`

        expect(analyzer.call).to contain_exactly(
          kind_of(Git::Lint::Collector),
          kind_of(Git::Lint::Reporters::Branch)
        )
      end
    end

    it "yields collector and reporter with block" do
      git_repo_dir.change_dir do
        `git commit --no-verify --message "Added one.txt" --message "- For testing purposes"`

        analyzer.call do |collector, reporter|
          expect([collector, reporter]).to contain_exactly(
            kind_of(Git::Lint::Collector),
            kind_of(Git::Lint::Reporters::Branch)
          )
        end
      end
    end

    it "reports no issues with valid commits" do
      git_repo_dir.change_dir do
        `git commit --no-verify --message "Added one.txt" --message "For testing purposes"`
        collector, _reporter = analyzer.call

        expect(collector.issues?).to be(false)
      end
    end

    it "reports issues with invalid commits" do
      git_repo_dir.change_dir do
        `git commit --no-verify --message "Add one.txt" --message "- A test bullet"`
        collector, _reporter = analyzer.call

        expect(collector.issues?).to be(true)
      end
    end

    it "reports no issues with disabled analyzer" do
      analyzer = described_class.new(
        configuration: configuration.with(commits_subject_prefix_enabled: false)
      )

      git_repo_dir.change_dir do
        `git commit --no-verify --message "Bogus commit message"`
        collector, _reporter = analyzer.call

        expect(collector.issues?).to be(false)
      end
    end

    context "with single commit" do
      include_context "with Git commit"

      it "processes commit" do
        collector, _reporter = analyzer.call commits: Success([git_commit])
        expect(collector.issues?).to be(true)
      end
    end
  end
end
