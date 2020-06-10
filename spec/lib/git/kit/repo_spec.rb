# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Kit::Repo do
  subject(:repo) { described_class.new }

  describe "#exist?" do
    it "answers true when Git repository exists", :git_repo do
      Dir.chdir(git_repo_dir) { expect(repo.exist?).to eq(true) }
    end

    it "answers true when nested within a Git repository", :temp_dir do
      nested_root = Pathname "#{temp_dir}/a/deeply/nested/path"
      FileUtils.mkdir_p nested_root

      Dir.chdir(nested_root) { expect(repo.exist?).to eq(true) }
    end

    it "answer false when Git repository doesn't exist" do
      Dir.mktmpdir "git-lint" do |dir|
        Dir.chdir(dir) { expect(repo.exist?).to eq(false) }
      end
    end
  end

  describe "#branch_name", :git_repo do
    it "answers master branch name" do
      Dir.chdir(git_repo_dir) { expect(repo.branch_name).to eq("master") }
    end

    it "answers feature branch name" do
      Dir.chdir git_repo_dir do
        git_create_branch
        expect(repo.branch_name).to eq("test")
      end
    end
  end

  describe "#shas", :git_repo do
    context "with default start and finish" do
      it "answers array of SHAs" do
        Dir.chdir git_repo_dir do
          git_create_branch
          git_commit_file "test.md"
          sha = `git log --pretty=format:%H -1`

          expect(repo.shas).to eq([sha])
        end
      end
    end

    context "with custom start and finish" do
      it "answers array of SHAs" do
        Dir.chdir git_repo_dir do
          git_create_branch
          git_commit_file "test.md"
          sha = `git log --pretty=format:%H -1`

          expect(repo.shas(start: "master", finish: "test")).to eq([sha])
        end
      end
    end

    context "with multiple commits" do
      it "answers empty array" do
        Dir.chdir git_repo_dir do
          git_create_branch
          git_commit_file "one.md"
          git_commit_file "two.md"
          shas = `git log --pretty=format:%H -2`.split "\n"

          expect(repo.shas(start: "master", finish: "test")).to eq(shas)
        end
      end
    end

    context "with no commits" do
      it "answers empty array" do
        Dir.chdir(git_repo_dir) { expect(repo.shas).to eq([]) }
      end
    end
  end
end
