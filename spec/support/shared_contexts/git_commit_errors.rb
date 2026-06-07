# frozen_string_literal: true

RSpec.shared_context "with Git commit errors" do
  let :git_commit_invalid_pattern do
    Regexp.new "Commit Subject Prefix Error.+" \
               "Commit Trailer Milestone Key Error.+" \
               "1 commit inspected.*2 issues.+detected.+",
               Regexp::MULTILINE
  end
end
