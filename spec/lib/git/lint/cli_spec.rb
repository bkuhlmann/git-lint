# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::CLI do
  subject(:cli) { described_class.start command_line }

  include_context "with Git repository"

  let(:options) { [] }
  let(:command_line) { Array(command).concat options }

  shared_examples_for "a config command" do
    context "with no options" do
      it "prints help text" do
        result = -> { cli }
        expect(&result).to output(/Manage gem configuration./).to_stdout
      end
    end
  end

  shared_examples_for "an analyze command" do
    context "with warnings" do
      before do
        Dir.chdir git_repo_dir do
          `git switch --create test --track`
          `printf "%s\n" "Test content" > one.txt`
          `git add --all .`
          `git commit --no-verify --message "Added test file"`
        end
      end

      it "prints program label" do
        Dir.chdir git_repo_dir do
          result = -> { cli }
          expect(&result).to output(/Running\sGit\sLint/).to_stdout
        end
      end

      it "prints commit label" do
        Dir.chdir git_repo_dir do
          result = -> { cli }
          pattern = /[0-9a-f]{40}\s\(Test\sUser,\s\d\sseconds\sago\):\sAdded\stest\sfile/

          expect(&result).to output(pattern).to_stdout
        end
      end

      it "prints warning" do
        Dir.chdir git_repo_dir do
          result = -> { cli }
          expect(&result).to output(/Commit\sBody\sPresence\sWarning\..+/).to_stdout
        end
      end

      it "prints stats" do
        Dir.chdir git_repo_dir do
          result = -> { cli }
          pattern = /1\scommit\sinspected\.\s.+1\sissue.+1\swarning.+0\serrors.+/

          expect(&result).to output(pattern).to_stdout
        end
      end

      it "does not abort program" do
        Dir.chdir git_repo_dir do
          result = -> { cli }
          expect(&result).not_to raise_error
        end
      end
    end

    context "with errors" do
      before do
        Dir.chdir git_repo_dir do
          `git switch --create test --track`
          `printf "%s\n" "Test content." > one.txt`
          `git add --all .`
          `git commit --no-verify --message "Made a test commit"`
        end
      end

      it "aborts program" do
        Dir.chdir git_repo_dir do
          result = -> { cli }
          expect(&result).to raise_error(SystemExit)
        end
      end
    end

    context "with no commits" do
      it "prints zero issues for zero commits" do
        Dir.chdir git_repo_dir do
          result = -> { cli }
          text = "Running Git Lint...\n" \
                 "0 commits inspected. \e[32m0 issues\e[0m detected.\n"

          expect(&result).to output(text).to_stdout
        end
      end

      it "does not abort program" do
        Dir.chdir git_repo_dir do
          result = -> { cli }
          expect(&result).not_to raise_error
        end
      end
    end

    context "with no issues" do
      before do
        Dir.chdir git_repo_dir do
          `git switch --create test --track`
          `printf "%s\n" "Test content" > one.txt`
          `git add --all .`
          `git commit --no-verify --message "Added a test commit" --message "A test body."`
        end
      end

      it "prints zero issues for one commit" do
        Dir.chdir git_repo_dir do
          result = -> { cli }
          text = "Running Git Lint...\n" \
                 "1 commit inspected. \e[32m0 issues\e[0m detected.\n"

          expect(&result).to output(text).to_stdout
        end
      end

      it "does not abort program" do
        Dir.chdir git_repo_dir do
          result = -> { cli }
          expect(&result).not_to raise_error
        end
      end
    end

    it "prints error when gem error is rescued" do
      allow(Git::Lint::Reporters::Branch).to receive(:new).and_raise(
        Git::Lint::Errors::Base, "Test."
      )

      Dir.chdir git_repo_dir do
        result = -> { cli }
        expect(&result).to raise_error(SystemExit, /Git\sLint:\sTest\./)
      end
    end
  end

  shared_examples_for "a hook command" do
    context "with valid commit" do
      let(:commit) { Bundler.root.join "spec", "support", "fixtures", "commit-valid.txt" }
      let(:options) { ["--commit-message", commit] }

      it "prints zero issues" do
        Dir.chdir git_repo_dir do
          result = -> { cli }
          expect(&result).to output(/.+1\scommit\sinspected.+0\sissues.+detected.+/m).to_stdout
        end
      end

      it "does not abort program" do
        Dir.chdir git_repo_dir do
          result = -> { cli }
          expect(&result).not_to raise_error
        end
      end
    end

    context "with invalid commit" do
      let(:commit) { Bundler.root.join "spec", "support", "fixtures", "commit-invalid.txt" }
      let(:options) { ["--commit-message", commit] }

      it "aborts program" do
        Dir.chdir git_repo_dir do
          result = -> { cli }
          expect(&result).to raise_error(SystemExit)
        end
      end
    end

    context "with no options" do
      it "prints help" do
        Dir.chdir git_repo_dir do
          result = -> { cli }
          expect(&result).to output(/Usage.+Options.+Add Git Hook support/m).to_stdout
        end
      end
    end

    context "with invalid path" do
      let(:options) { ["--commit-message", "/a/bogus/path"] }

      it "prints error" do
        Dir.chdir git_repo_dir do
          result = -> { cli }
          expect(&result).to raise_error(SystemExit, %r(Invalid.+path.+/a/bogus/path.+))
        end
      end
    end
  end

  shared_examples_for "a version command" do
    it "prints version" do
      result = -> { cli }
      expect(&result).to output(/#{Git::Lint::Identity::VERSION_LABEL}\n/o).to_stdout
    end
  end

  shared_examples_for "a help command" do
    it "prints usage" do
      result = -> { cli }
      expect(&result).to output(/#{Git::Lint::Identity::VERSION_LABEL}\scommands:\n/o).to_stdout
    end
  end

  describe "--config" do
    let(:command) { "--config" }

    it_behaves_like "a config command"
  end

  describe "-c" do
    let(:command) { "-c" }

    it_behaves_like "a config command"
  end

  describe "--analyze" do
    let(:command) { "--analyze" }

    it_behaves_like "an analyze command"
  end

  describe "-a" do
    let(:command) { "-a" }

    it_behaves_like "an analyze command"
  end

  describe "--hook" do
    let(:command) { "--hook" }

    it_behaves_like "a hook command"
  end

  describe "--version" do
    let(:command) { "--version" }

    it_behaves_like "a version command"
  end

  describe "-v" do
    let(:command) { "-v" }

    it_behaves_like "a version command"
  end

  describe "--help" do
    let(:command) { "--help" }

    it_behaves_like "a help command"
  end

  describe "-h" do
    let(:command) { "-h" }

    it_behaves_like "a help command"
  end

  context "with no command" do
    let(:command) { nil }

    it_behaves_like "a help command"
  end
end
