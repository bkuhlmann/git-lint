# frozen_string_literal: true

require "git_plus"
require "git/lint/identity"
require "git/lint/refinements/strings"
require "git/lint/errors/base"
require "git/lint/errors/severity"
require "git/lint/errors/sha"
require "git/lint/kit/filter_list"
require "git/lint/validators/email"
require "git/lint/validators/name"
require "git/lint/validators/capitalization"
require "git/lint/parsers/trailers/collaborator"
require "git/lint/branches/environments/local"
require "git/lint/branches/environments/circle_ci"
require "git/lint/branches/environments/git_hub_action"
require "git/lint/branches/environments/netlify_ci"
require "git/lint/branches/environments/travis_ci"
require "git/lint/branches/feature"
require "git/lint/analyzers/abstract"
require "git/lint/analyzers/commit_author_capitalization"
require "git/lint/analyzers/commit_author_email"
require "git/lint/analyzers/commit_author_name"
require "git/lint/analyzers/commit_body_bullet"
require "git/lint/analyzers/commit_body_bullet_capitalization"
require "git/lint/analyzers/commit_body_bullet_delimiter"
require "git/lint/analyzers/commit_body_issue_tracker_link"
require "git/lint/analyzers/commit_body_leading_line"
require "git/lint/analyzers/commit_body_line_length"
require "git/lint/analyzers/commit_body_paragraph_capitalization"
require "git/lint/analyzers/commit_body_phrase"
require "git/lint/analyzers/commit_body_presence"
require "git/lint/analyzers/commit_body_single_bullet"
require "git/lint/analyzers/commit_subject_length"
require "git/lint/analyzers/commit_subject_prefix"
require "git/lint/analyzers/commit_subject_suffix"
require "git/lint/analyzers/commit_trailer_collaborator_capitalization"
require "git/lint/analyzers/commit_trailer_collaborator_duplication"
require "git/lint/analyzers/commit_trailer_collaborator_email"
require "git/lint/analyzers/commit_trailer_collaborator_key"
require "git/lint/analyzers/commit_trailer_collaborator_name"
require "git/lint/collector"
require "git/lint/reporters/lines/sentence"
require "git/lint/reporters/lines/paragraph"
require "git/lint/reporters/line"
require "git/lint/reporters/style"
require "git/lint/reporters/commit"
require "git/lint/reporters/branch"
require "git/lint/runner"
require "git/lint/cli"
