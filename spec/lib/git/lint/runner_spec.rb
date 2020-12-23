# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Runner do
  subject(:runner) { described_class.new configuration: configuration.to_h }

  include_context "with Git repository"

  let :defaults do
    {
      commit_body_leading_line: {enabled: true, severity: :error},
      commit_subject_length: {enabled: true, severity: :error, length: 50},
      commit_subject_prefix: {enabled: true, severity: :error, includes: %w[Fixed Added]},
      commit_subject_suffix: {enabled: true, severity: :error, excludes: ["\\.", "\\?", "\\!"]}
    }
  end

  let :configuration do
    Runcom::Config.new "#{Git::Lint::Identity::NAME}/configuration.yml", defaults: defaults
  end

  let(:branch) { "test" }

  before do
    Dir.chdir git_repo_dir do
      `git switch --create test --track`
      `printf "%s\n" "Test content" > one.txt`
      `git add --all .`
    end
  end

  describe "#call" do
    context "with valid commits" do
      it "reports no issues" do
        Dir.chdir git_repo_dir do
          `git commit --no-verify --message "Added one.txt" --message "- For testing purposes"`
          collector = runner.call

          expect(collector.issues?).to eq(false)
        end
      end
    end

    context "with invalid commits" do
      it "reports issues" do
        Dir.chdir git_repo_dir do
          `git commit --no-verify --message "Add one.txt" --message "- A test bullet"`
          collector = runner.call

          expect(collector.issues?).to eq(true)
        end
      end
    end

    context "with disabled analyzer" do
      let(:defaults) { {commit_subject_prefix: {enabled: false, includes: %w[Added]}} }

      it "reports no issues" do
        Dir.chdir git_repo_dir do
          `git commit --no-verify --message "Bogus commit message"`
          collector = runner.call

          expect(collector.issues?).to eq(false)
        end
      end
    end

    context "with invalid analyzer ID" do
      let(:defaults) { {invalid_analyzer_id: true} }

      it "fails with errors" do
        Dir.chdir git_repo_dir do
          `git commit --no-verify --message "Updated one.txt" --message "- A test bullet"`
          result = -> { runner.call }

          expect(&result).to raise_error(
            Git::Lint::Errors::Base,
            /Invalid\sanalyzer:\sinvalid_analyzer_id.+/
          )
        end
      end
    end

    context "with single commit" do
      include_context "with Git commit"

      it "processes commit" do
        collector = runner.call commits: [git_commit]
        expect(collector.issues?).to eq(true)
      end
    end
  end
end
