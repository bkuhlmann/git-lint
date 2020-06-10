# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Commits::Saved, :git_repo do
  subject(:commit) { Dir.chdir(git_repo_dir) { described_class.new sha: sha } }

  let(:sha) { Dir.chdir(git_repo_dir) { `git log --pretty=format:%H -1` } }

  before do
    Dir.chdir git_repo_dir do
      `touch test.md`
      `git add --all .`
      `git commit -m "Added test documentation." -m "- Necessary for testing purposes."`
    end
  end

  describe ".pattern" do
    it "answers pretty format pattern for all known formats" do
      expect(described_class.pattern).to eq(
        "<sha>%H</sha>%n" \
        "<author_name>%an</author_name>%n" \
        "<author_email>%ae</author_email>%n" \
        "<author_date_relative>%ar</author_date_relative>%n" \
        "<subject>%s</subject>%n" \
        "<body>%b</body>%n" \
        "<raw_body>%B</raw_body>%n" \
        "<trailers>%(trailers)</trailers>%n"
      )
    end
  end

  describe "#initialize" do
    it "fails with SHA error for invalid SHA" do
      result = -> { described_class.new sha: "bogus" }

      expect(&result).to raise_error(
        Git::Lint::Errors::SHA,
        %(Invalid commit SHA: "bogus". Unable to obtain commit details.)
      )
    end

    it "fails with SHA error for unknown SHA" do
      result = -> { described_class.new sha: "abcdef123" }

      expect(&result).to raise_error(
        Git::Lint::Errors::SHA,
        %(Invalid commit SHA: "abcdef123". Unable to obtain commit details.)
      )
    end
  end

  describe "#==" do
    let(:sha_1) { `git log --pretty=format:%H -1` }
    let(:sha_2) { `git log --pretty=format:%H -1 @~` }
    let(:similar) { Dir.chdir(git_repo_dir) { described_class.new sha: sha_1 } }
    let(:different) { Dir.chdir(git_repo_dir) { described_class.new sha: sha_2 } }

    context "with same instances" do
      it "answers true" do
        Dir.chdir git_repo_dir do
          expect(commit).to eq(commit)
        end
      end
    end

    context "with same values" do
      it "answers true" do
        Dir.chdir git_repo_dir do
          expect(commit).to eq(similar)
        end
      end
    end

    context "with different values" do
      it "answers false" do
        Dir.chdir git_repo_dir do
          expect(commit).not_to eq(different)
        end
      end
    end

    context "with different type" do
      it "answers false" do
        Dir.chdir git_repo_dir do
          expect(commit).not_to eq("A string.")
        end
      end
    end
  end

  describe "#eql?" do
    let(:sha_1) { `git log --pretty=format:%H -1` }
    let(:sha_2) { `git log --pretty=format:%H -1 @~` }
    let(:similar) { Dir.chdir(git_repo_dir) { described_class.new sha: sha_1 } }
    let(:different) { Dir.chdir(git_repo_dir) { described_class.new sha: sha_2 } }

    context "with same instances" do
      it "answers true" do
        Dir.chdir git_repo_dir do
          expect(commit).to eql(commit)
        end
      end
    end

    context "with same values" do
      it "answers true" do
        Dir.chdir git_repo_dir do
          expect(commit).to eql(similar)
        end
      end
    end

    context "with different values" do
      it "answers false" do
        Dir.chdir git_repo_dir do
          expect(commit).not_to eql(different)
        end
      end
    end

    context "with different type" do
      it "answers false" do
        Dir.chdir git_repo_dir do
          expect(commit).not_to eql("A string.")
        end
      end
    end
  end

  describe "#equal?" do
    let(:sha_1) { `git log --pretty=format:%H -1` }
    let(:sha_2) { `git log --pretty=format:%H -1 @~` }
    let(:similar) { Dir.chdir(git_repo_dir) { described_class.new sha: sha_1 } }
    let(:different) { Dir.chdir(git_repo_dir) { described_class.new sha: sha_2 } }

    context "with same instances" do
      it "answers true" do
        Dir.chdir git_repo_dir do
          expect(commit).to equal(commit)
        end
      end
    end

    context "with same values" do
      it "answers true" do
        Dir.chdir git_repo_dir do
          expect(commit).not_to equal(similar)
        end
      end
    end

    context "with different values" do
      it "answers false" do
        Dir.chdir git_repo_dir do
          expect(commit).not_to equal(different)
        end
      end
    end

    context "with different type" do
      it "answers false" do
        Dir.chdir git_repo_dir do
          expect(commit).not_to equal("A string.")
        end
      end
    end
  end

  describe "#hash" do
    let(:sha_1) { `git log --pretty=format:%H -1` }
    let(:sha_2) { `git log --pretty=format:%H -1 @~` }
    let(:similar) { Dir.chdir(git_repo_dir) { described_class.new sha: sha_1 } }
    let(:different) { Dir.chdir(git_repo_dir) { described_class.new sha: sha_2 } }

    context "with same instances" do
      it "is identical" do
        expect(commit.hash).to eq(commit.hash)
      end
    end

    context "with same values" do
      it "is identical" do
        expect(commit.hash).to eq(similar.hash)
      end
    end

    context "with different values" do
      it "is different" do
        expect(commit.hash).not_to eq(different.hash)
      end
    end

    context "with different type" do
      it "is different" do
        expect(commit.hash).not_to eq("not the same".hash)
      end
    end
  end

  describe "#sha" do
    it "answers SHA" do
      expect(commit.sha).to match(/[0-9a-f]{40}/)
    end
  end

  describe "#author_name" do
    it "answers author name" do
      expect(commit.author_name).to eq("Test Example")
    end
  end

  describe "#author_email" do
    it "answers author email" do
      expect(commit.author_email).to eq("test@example.com")
    end
  end

  describe "#author_date_relative" do
    it "answers author date" do
      expect(commit.author_date_relative).to match(/\A\d{1}\ssecond.+ago\Z/)
    end
  end

  describe "#subject" do
    it "answers subject" do
      expect(commit.subject).to eq("Added test documentation.")
    end
  end

  describe "#body" do
    it "answers body with single line" do
      expect(commit.body).to eq("- Necessary for testing purposes.\n")
    end

    context "with multiple lines" do
      let :commit_message do
        "Added multi text file.\n\n" \
        "- Necessary for multi-line test.\n" \
        "- An extra bullet point.\n"
      end

      before do
        Dir.chdir git_repo_dir do
          `touch multi.txt`
          `git add --all .`
          `git commit --message '#{commit_message}'`
        end
      end

      it "answers body with multiple lines" do
        body = "- Necessary for multi-line test.\n- An extra bullet point.\n"
        expect(commit.body).to eq(body)
      end
    end
  end

  describe "#body_lines" do
    before do
      Dir.chdir git_repo_dir do
        `touch test.txt`
        `git add --all .`
        `git commit --message '#{commit_message}'`
      end
    end

    context "with body" do
      let :commit_message do
        "Added test file.\n\n" \
        "- First bullet.\n" \
        "- Second bullet.\n" \
        "- Third bullet.\n"
      end

      it "answers body lines" do
        Dir.chdir git_repo_dir do
          expect(commit.body_lines).to contain_exactly(
            "- First bullet.",
            "- Second bullet.",
            "- Third bullet."
          )
        end
      end
    end

    context "with comments" do
      let :commit_message do
        "Added test file.\n\n" \
        "- A bullet.\n" \
        "# A comment.\n" \
        "A body line.\n"
      end

      it "excludes comments" do
        Dir.chdir git_repo_dir do
          expect(commit.body_lines).to contain_exactly(
            "- A bullet.",
            "A body line."
          )
        end
      end
    end

    context "with trailers" do
      let :commit_message do
        "Added test file.\n\n" \
        "A body line.\n\n" \
        "Trailer-One: 1\n" \
        "Trailer-Two: 2\n"
      end

      it "excludes trailers" do
        Dir.chdir git_repo_dir do
          expect(commit.body_lines).to contain_exactly("A body line.")
        end
      end
    end

    context "without body" do
      let(:commit_message) { "Added test file." }

      it "answers empty array" do
        Dir.chdir git_repo_dir do
          expect(commit.body_lines).to be_empty
        end
      end
    end
  end

  describe "#body_paragraphs" do
    before do
      Dir.chdir git_repo_dir do
        `touch test.txt`
        `git add --all .`
        `git commit --message '#{commit_message}'`
      end
    end

    context "with body" do
      let :commit_message do
        "Added test.\n\n" \
        "The opening paragraph.\n" \
        "A bunch of words.\n\n" \
        "A bullet list:\n" \
        "- First bullet.\n" \
        "- Second bullet.\n\n"
      end

      it "answers paragraphs" do
        Dir.chdir git_repo_dir do
          expect(commit.body_paragraphs).to contain_exactly(
            "The opening paragraph.\nA bunch of words.",
            "A bullet list:\n- First bullet.\n- Second bullet."
          )
        end
      end
    end

    context "with comments" do
      let :commit_message do
        "Added test.\n\n" \
        "A standard paragraph.\n\n" \
        "# A commented paragraph.\n\n" \
        "Another paragraph.\n\n"
      end

      it "excludes comments" do
        Dir.chdir git_repo_dir do
          expect(commit.body_paragraphs).to contain_exactly(
            "A standard paragraph.",
            "Another paragraph."
          )
        end
      end
    end

    context "with trailers" do
      let :commit_message do
        "Added test.\n\n" \
        "A standard paragraph.\n\n" \
        "Trailer-One: 1\n" \
        "Trailer-Two: 2\n"
      end

      it "excludes trailers" do
        Dir.chdir git_repo_dir do
          expect(commit.body_paragraphs).to contain_exactly("A standard paragraph.")
        end
      end
    end

    context "without body" do
      let(:commit_message) { "Added test file." }

      it "answers empty array" do
        Dir.chdir git_repo_dir do
          expect(commit.body_paragraphs).to be_empty
        end
      end
    end
  end

  describe "#raw_body" do
    it "answers raw body" do
      expect(commit.raw_body).to eq(
        "Added test documentation.\n\n" \
        "- Necessary for testing purposes.\n"
      )
    end

    context "with trailers and comments" do
      before do
        Dir.chdir git_repo_dir do
          `touch test.txt`
          `git add --all .`
          `git commit --message '#{commit_message}'`
        end
      end

      let :commit_message do
        "Added test.\n\n" \
        "An example body.\n\n" \
        "One: 1\n" \
        "Two: 2\n" \
        "# A comment.\n" \
        "# A second comment.\n"
      end

      it "answers raw body" do
        Dir.chdir git_repo_dir do
          expect(commit.raw_body).to eq(
            "Added test.\n\n" \
            "An example body.\n\n" \
            "One: 1\n" \
            "Two: 2\n" \
            "# A comment.\n" \
            "# A second comment.\n"
          )
        end
      end
    end
  end

  describe "#trailers" do
    it "answers empty array without trailers" do
      expect(commit.trailers).to be_empty
    end

    context "with trailers" do
      before do
        Dir.chdir git_repo_dir do
          `touch test.txt`
          `git add --all .`
          `git commit --message '#{commit_message}'`
        end
      end

      let :commit_message do
        "Added test.\n\n" \
        "One: 1\n" \
        "Two: 2\n"
      end

      it "answers trailers" do
        expect(commit.trailers).to eq(
          "One: 1\n" \
          "Two: 2\n"
        )
      end
    end
  end

  describe "#trailer_lines" do
    before do
      Dir.chdir git_repo_dir do
        `touch test.txt`
        `git add --all .`
        `git commit --message '#{commit_message}'`
      end
    end

    context "with trailers" do
      let :commit_message do
        "Added test.\n\n" \
        "One: 1\n" \
        "Two: 2\n" \
      end

      it "answers an array of lines" do
        Dir.chdir git_repo_dir do
          expect(commit.trailer_lines).to contain_exactly(
            "One: 1",
            "Two: 2"
          )
        end
      end
    end

    context "without trailers" do
      let(:commit_message) { "Added test.\n" }

      it "answers empty array" do
        Dir.chdir git_repo_dir do
          expect(commit.trailer_lines).to be_empty
        end
      end
    end
  end

  describe "#trailer_index" do
    it "answers nil without trailers" do
      expect(commit.trailer_index).to eq(nil)
    end

    context "with trailers and comments" do
      let :commit_message do
        "Added test.\n\n" \
        "A paragraph.\n\n" \
        "Trailer-One: 1\n" \
        "Trailer-Two: 2\n\n" \
        "# One\n\n" \
        "# Two\n" \
        "# Three\n\n"
      end

      before do
        Dir.chdir git_repo_dir do
          `touch test.txt`
          `git add --all .`
          `git commit --message '#{commit_message}'`
        end
      end

      it "answers index" do
        Dir.chdir git_repo_dir do
          expect(commit.trailer_index).to eq(2)
        end
      end
    end
  end

  describe "#fixup?" do
    it_behaves_like "a fixup commit"
  end

  describe "#squash?" do
    it_behaves_like "a squash commit"
  end

  describe "#respond_to?" do
    it "answers true for data methods" do
      described_class::FORMATS.each_key do |key|
        expect(commit.respond_to?(key)).to eq(true)
      end
    end

    it "answers false for invalid methods" do
      expect(commit.respond_to?(:bogus)).to eq(false)
    end
  end

  describe "commits with invalid encoding" do
    it "doesn't fail with argument error" do
      Dir.chdir git_repo_dir do
        `git config i18n.commitEncoding Shift_JIS`
        `touch example.txt`
        `git add --all .`
        `git commit -m "Added \210\221\332\332\337\341\341."`
        commit = -> { described_class.new(sha: sha).subject }

        expect(&commit).not_to raise_error
      end
    end
  end
end
