# frozen_string_literal: true

require "open3"

module Git
  module Lint
    module Commits
      # Represents an existing commit.
      # :reek:TooManyMethods
      class Saved
        using Refinements::Strings

        FORMATS = {
          sha: "%H",
          author_name: "%an",
          author_email: "%ae",
          author_date_relative: "%ar",
          subject: "%s",
          body: "%b",
          raw_body: "%B",
          trailers: "%(trailers)"
        }.freeze

        def self.pattern
          FORMATS.reduce("") { |pattern, (key, value)| pattern + "<#{key}>#{value}</#{key}>%n" }
        end

        def initialize sha:, shell: Open3
          data, status = shell.capture2e show_command(sha)
          fail Errors::SHA, sha unless status.success?

          @data = data.scrub "?"
        end

        def == other
          other.is_a?(self.class) && sha == other.sha
        end
        alias eql? ==

        def <=> other
          sha <=> other.sha
        end

        def hash
          sha.hash
        end

        def body_lines
          body_without_trailing_spaces
        end

        def body_paragraphs
          body_without_trailers.split("\n\n").map(&:chomp).reject { |line| line.start_with? "#" }
        end

        def trailer_lines
          trailers.split "\n"
        end

        def trailer_index
          body.split("\n").index trailer_lines.first
        end

        def fixup?
          subject.fixup?
        end

        def squash?
          subject.squash?
        end

        private

        attr_reader :data

        def show_command sha
          %(git show --stat --pretty=format:"#{self.class.pattern}" #{sha})
        end

        def body_without_trailing_spaces
          body_without_comments.reverse.drop_while(&:empty?).reverse
        end

        def body_without_comments
          body_without_trailers.split("\n").reject { |line| line.start_with? "#" }
        end

        def body_without_trailers
          body.sub trailers, ""
        end

        def method_missing name, *arguments, &block
          return super unless respond_to_missing? name

          String data[%r(<#{name}>(?<content>.*?)</#{name}>)m, :content]
        end

        def respond_to_missing? name, include_private = false
          FORMATS.key?(name.to_sym) || super
        end
      end
    end
  end
end
