# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitAuthorEmail do
  subject(:analyzer) { described_class.new commit: commit }

  let(:email) { "test@example.com" }
  let(:status) { instance_double Process::Status, success?: true }
  let(:shell) { class_spy Open3, capture2e: ["", status] }

  let :commit do
    object_double Git::Lint::Commits::Saved.new(sha: "abc", shell: shell), author_email: email
  end

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_author_email)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Author Email")
    end
  end

  describe ".defaults" do
    it "answers defaults" do
      expect(described_class.defaults).to eq(
        enabled: true,
        severity: :error
      )
    end
  end

  describe "#valid?" do
    context "with valid email" do
      let(:email) { "test@example.com" }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    context "with invalid email" do
      let(:email) { "invalid" }

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let(:email) { "invalid" }

      it "answers issue hint" do
        expect(issue[:hint]).to eq(%(Use "<name>@<server>.<domain>" instead of "invalid".))
      end
    end
  end
end
