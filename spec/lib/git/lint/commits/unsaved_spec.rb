# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Commits::Unsaved, :git_repo do
  subject(:commit) { described_class.new path: path }

  let(:path) { "#{Bundler.root}/spec/support/fixtures/commit-valid.txt" }

  describe "#initialize" do
    it "raises base error for invalid path" do
      result = -> { described_class.new path: "/bogus/path" }

      expect(&result).to raise_error(
        Git::Lint::Errors::Base,
        %(Invalid commit message path: "/bogus/path".)
      )
    end
  end

  describe "#raw_body" do
    let :raw_body do
      "Added example\n" \
      "\n" \
      "An example paragraph.\n" \
      "\n" \
      "A bullet list:\n" \
      "  - One.\n" \
      "\n" \
      "# A comment block.\n\n" \
      "Example-One: 1\n" \
      "Example-Two: 2\n"
    end

    it "answers file contents" do
      expect(commit.raw_body).to eq(raw_body)
    end
  end

  describe "#sha" do
    it "answers random SHA" do
      expect(commit.sha).to match(/[0-9a-f]{40}/)
    end
  end

  describe "#author_name" do
    it "answers name" do
      Dir.chdir git_repo_dir do
        expect(commit.author_name).to eq("Test Example")
      end
    end
  end

  describe "#author_email" do
    it "answers email address" do
      Dir.chdir git_repo_dir do
        expect(commit.author_email).to eq("test@example.com")
      end
    end
  end

  describe "#author_date_relative" do
    it "answers zero seconds" do
      expect(commit.author_date_relative).to eq("0 seconds ago")
    end
  end

  describe "#subject" do
    it "answers subject from file" do
      expect(commit.subject).to eq("Added example")
    end

    it "answers raw body when raw body is a single line" do
      allow(commit).to receive(:raw_body).and_return("A test body.")
      expect(commit.subject).to eq("A test body.")
    end

    it "answers empty string when raw body is empty" do
      allow(commit).to receive(:raw_body).and_return("")
      expect(commit.subject).to eq("")
    end
  end

  describe "#body" do
    let :body do
      "\n" \
      "An example paragraph.\n" \
      "\n" \
      "A bullet list:\n" \
      "  - One.\n" \
      "\n" \
      "# A comment block.\n" \
      "\n" \
      "Example-One: 1\n" \
      "Example-Two: 2\n"
    end

    it "answers body from file" do
      expect(commit.body).to eq(body)
    end

    it "answers empty string when raw body is a single line" do
      allow(commit).to receive(:raw_body).and_return("A test body.")
      expect(commit.body).to eq("")
    end

    it "answers body when raw body has multiple lines" do
      allow(commit).to receive(:raw_body).and_return("A test subject.\nA test body.\n")
      expect(commit.body).to eq("A test body.\n")
    end

    it "answers empty string when raw body is empty" do
      allow(commit).to receive(:raw_body).and_return("")
      expect(commit.body).to eq("")
    end

    context "with scissor content" do
      let(:path) { "#{Bundler.root}/spec/support/fixtures/commit-scissors.txt" }

      it "answers body, ignoring scissor content" do
        expect(commit.body).to eq(
          "\n" \
          "A fixture for commits made via `git commit --verbose` which include\n" \
          "scissor-related content.\n\n" \
          "# A test comment.\n"
        )
      end
    end
  end

  describe "#body_lines" do
    it "answers body lines with comments ignored" do
      expect(commit.body_lines).to contain_exactly(
        "",
        "An example paragraph.",
        "",
        "A bullet list:",
        "  - One."
      )
    end

    it "answers body line with no leading line after subject" do
      allow(commit).to receive(:raw_body).and_return("A test subject.\nA test body.\n")
      expect(commit.body_lines).to contain_exactly("A test body.")
    end

    it "answers empty array when raw body is a single line" do
      allow(commit).to receive(:raw_body).and_return("A test body.")
      expect(commit.body_lines).to eq([])
    end

    it "answers empty array when raw body is empty" do
      allow(commit).to receive(:raw_body).and_return("")
      expect(commit.body_lines).to eq([])
    end
  end

  describe "#body_paragraphs" do
    it "answers paragraphs with comments ignored" do
      expect(commit.body_paragraphs).to contain_exactly(
        "An example paragraph.",
        "A bullet list:\n  - One."
      )
    end

    it "answers empty array when raw body is single line" do
      allow(commit).to receive(:raw_body).and_return("A test body.")
      expect(commit.body_paragraphs).to eq([])
    end

    it "answers empty array when raw body is empty" do
      allow(commit).to receive(:raw_body).and_return("")
      expect(commit.body_paragraphs).to eq([])
    end
  end

  describe "#trailers" do
    it "answers trailers" do
      expect(commit.trailers).to eq("Example-One: 1\nExample-Two: 2\n")
    end

    context "without trailers" do
      let(:path) { "#{Bundler.root}/spec/support/fixtures/commit-scissors.txt" }

      it "answers empty string" do
        expect(commit.trailers).to eq("")
      end
    end
  end

  describe "#trailer_lines" do
    it "answers trailer lines" do
      expect(commit.trailer_lines).to contain_exactly(
        "Example-One: 1",
        "Example-Two: 2"
      )
    end

    context "without trailers" do
      let(:path) { "#{Bundler.root}/spec/support/fixtures/commit-scissors.txt" }

      it "answers empty array" do
        expect(commit.trailer_lines).to eq([])
      end
    end
  end

  describe "#trailer_index" do
    it "answers index for default commit" do
      expect(commit.trailer_index).to eq(8)
    end

    context "with scissors commit" do
      let(:path) { "#{Bundler.root}/spec/support/fixtures/commit-scissors.txt" }

      it "answers nil" do
        expect(commit.trailer_index).to eq(nil)
      end
    end

    context "with invalid commit" do
      let(:path) { "#{Bundler.root}/spec/support/fixtures/commit-invalid.txt" }

      it "answers nil" do
        expect(commit.trailer_index).to eq(nil)
      end
    end
  end

  describe "#fixup?" do
    it_behaves_like "a fixup commit"
  end

  describe "#squash?" do
    it_behaves_like "a squash commit"
  end

  describe "commits with invalid encoding" do
    it "doesn't fail with argument error" do
      path = "#{temp_dir}/invalid_commit.txt"
      File.open(path, "w") { |file| file.write "Added \210\221\332\332\337\341\341." }
      commit = -> { described_class.new(path: path).subject }

      expect(&commit).not_to raise_error
    end
  end
end
