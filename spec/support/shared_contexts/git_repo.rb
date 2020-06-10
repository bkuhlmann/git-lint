# frozen_string_literal: true

RSpec.shared_context "with git repository", :git_repo do
  let(:temp_dir) { Bundler.root.join "tmp", "rspec" }
  let(:git_repo_dir) { File.join temp_dir, "repo" }
  let(:git_user_name) { "Test Example" }
  let(:git_user_email) { "test@example.com" }

  around do |example|
    FileUtils.mkdir_p git_repo_dir

    Dir.chdir git_repo_dir do
      FileUtils.touch "one.txt"
      FileUtils.touch "two.txt"
      FileUtils.touch "three.txt"
      `git init`
      `git config user.name "#{git_user_name}"`
      `git config user.email "#{git_user_email}"`
      `git config core.hooksPath /dev/null`
      `git config remote.origin.url https://github.com/bkuhlmann/test.git`
      `git add --all .`
      `git commit --all --message "Added dummy files"`
    end

    example.run

    FileUtils.rm_rf temp_dir
  end

  def git_create_branch name = "test"
    `git checkout -b "#{name}" > /dev/null 2>&1`
  end

  def git_commit_file name
    `touch #{name}`
    `git add --all`
    `git commit -m "Added #{name}"`
  end
end
