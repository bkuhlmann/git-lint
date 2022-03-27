# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzer do
  using Refinements::Pathnames

  subject(:runner) { described_class.new }

  include_context "with Git repository"
  include_context "with application dependencies"

  let :configuration do
    Git::Lint::Configuration::Content[
      analyzers: [
        Git::Lint::Configuration::Setting[
          id: :commit_body_leading_line,
          enabled: true,
          severity: :error
        ],
        Git::Lint::Configuration::Setting[
          id: :commit_subject_length,
          enabled: true,
          severity: :error,
          maximum: 50
        ],
        Git::Lint::Configuration::Setting[
          id: :commit_subject_prefix,
          enabled: true,
          severity: :error,
          includes: %w[Fixed Added]
        ],
        Git::Lint::Configuration::Setting[
          id: :commit_subject_suffix,
          enabled: true,
          severity: :error,
          excludes: ["\\.", "\\?", "\\!"]
        ]
      ]
    ]
  end

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

        expect(runner.call).to contain_exactly(
          kind_of(Git::Lint::Collector),
          kind_of(Git::Lint::Reporters::Branch)
        )
      end
    end

    it "yields collector and reporter with block" do
      git_repo_dir.change_dir do
        `git commit --no-verify --message "Added one.txt" --message "- For testing purposes"`

        runner.call do |collector, reporter|
          expect([collector, reporter]).to contain_exactly(
            kind_of(Git::Lint::Collector),
            kind_of(Git::Lint::Reporters::Branch)
          )
        end
      end
    end

    it "reports no issues with valid commits" do
      git_repo_dir.change_dir do
        `git commit --no-verify --message "Added one.txt" --message "- For testing purposes"`
        collector, _reporter = runner.call

        expect(collector.issues?).to be(false)
      end
    end

    it "reports issues with invalid commits" do
      git_repo_dir.change_dir do
        `git commit --no-verify --message "Add one.txt" --message "- A test bullet"`
        collector, _reporter = runner.call

        expect(collector.issues?).to be(true)
      end
    end

    context "with disabled analyzer" do
      let :configuration do
        Git::Lint::Configuration::Content[
          analyzers: [
            Git::Lint::Configuration::Setting[
              id: :commit_subject_prefix,
              enabled: false,
              includes: %w[Added]
            ]
          ]
        ]
      end

      it "reports no issues" do
        git_repo_dir.change_dir do
          `git commit --no-verify --message "Bogus commit message"`
          collector, _reporter = runner.call

          expect(collector.issues?).to be(false)
        end
      end
    end

    context "with invalid analyzer ID" do
      let :configuration do
        Git::Lint::Configuration::Content[
          analyzers: [Git::Lint::Configuration::Setting[id: :bogus]]
        ]
      end

      it "fails with errors" do
        git_repo_dir.change_dir do
          `git commit --no-verify --message "Updated one.txt" --message "- A test bullet"`
          result = -> { runner.call }

          expect(&result).to raise_error(
            Git::Lint::Errors::Base,
            /Invalid\sanalyzer detected:\sbogus/
          )
        end
      end
    end

    context "with single commit" do
      include_context "with Git commit"

      it "processes commit" do
        collector, _reporter = runner.call commits: [git_commit]
        expect(collector.issues?).to be(true)
      end
    end
  end
end
