# frozen_string_literal: true

require "pathname"
require "open3"
require "securerandom"

module Git
  module Lint
    module Commits
      # Represents a partially formed, unsaved commit.
      # :reek:TooManyMethods
      class Unsaved
        using Refinements::Strings

        SUBJECT_LINE = 1
        SCISSOR_PATTERN = /\#\s-+\s>8\s-+\n.+/m.freeze

        attr_reader :sha, :raw_body

        def initialize path:, sha: SecureRandom.hex(20), shell: Open3
          fail Errors::Base, %(Invalid commit message path: "#{path}".) unless File.exist? path

          @path = Pathname path
          @sha = sha
          @shell = shell
          @raw_body = File.read(path).scrub "?"
        end

        def author_name
          shell.capture2e("git config --get user.name").then { |result, _status| result.chomp }
        end

        def author_email
          shell.capture2e("git config --get user.email").then { |result, _status| result.chomp }
        end

        def author_date_relative
          "0 seconds ago"
        end

        def subject
          String raw_body.split("\n").first
        end

        # :reek:FeatureEnvy
        def body
          raw_body.sub(SCISSOR_PATTERN, "").split("\n").drop(SUBJECT_LINE).then do |lines|
            computed_body = lines.join "\n"
            lines.empty? ? computed_body : "#{computed_body}\n"
          end
        end

        def body_lines
          body_without_trailing_spaces
        end

        # :reek:FeatureEnvy
        def body_paragraphs
          body_without_trailers.split("\n\n")
                               .map { |line| line.delete_prefix "\n" }
                               .map(&:chomp)
                               .reject { |line| line.start_with? "#" }
        end

        def trailers
          trailers, status = shell.capture2e %(git interpret-trailers --only-trailers "#{path}")

          return "" unless status.success?

          trailers
        end

        def trailer_lines
          trailers.split "\n"
        end

        def trailer_index
          body.split("\n").index trailer_lines.first
        end

        def == other
          other.is_a?(self.class) && raw_body == other.raw_body
        end
        alias eql? ==

        def <=> other
          raw_body <=> other.raw_body
        end

        def hash
          raw_body.hash
        end

        def fixup?
          subject.fixup?
        end

        def squash?
          subject.squash?
        end

        private

        attr_reader :path, :shell

        def body_without_trailing_spaces
          body_without_comments.reverse.drop_while(&:empty?).reverse
        end

        def body_without_comments
          body_without_trailers.split("\n").reject { |line| line.start_with? "#" }
        end

        def body_without_trailers
          body.sub trailers, ""
        end
      end
    end
  end
end
