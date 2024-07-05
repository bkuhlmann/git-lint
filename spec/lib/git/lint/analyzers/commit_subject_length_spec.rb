# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitSubjectLength do
  using Refinements::Struct

  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq("commit_subject_length")
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Subject Length")
    end
  end

  describe "#valid?" do
    context "when valid" do
      let(:commit) { Gitt::Models::Commit[subject: "Added specs"] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with fixup prefix and max subject length" do
      let :commit do
        Gitt::Models::Commit[
          subject: "fixup! Added Curabitur eleifend wisi iaculis ipsum iaculis inia wazlouth tik mx"
        ]
      end

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with squash prefix and max subject length" do
      let :commit do
        Gitt::Models::Commit[
          subject: "squash! Added Curabitur eleifend wisi iaculis ipsum iaculis inia wazlouth " \
                   "tik mx"
        ]
      end

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    it "answers false with invalid length" do
      analyzer = described_class.new(
        Gitt::Models::Commit[subject: "Added specs"],
        settings: settings.merge(commits_subject_length_maximum: 10)
      )

      expect(analyzer.valid?).to be(false)
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { Gitt::Models::Commit[subject: "Added specs"] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      subject :analyzer do
        described_class.new(
          Gitt::Models::Commit[subject: "Added specs"],
          settings: settings.merge(commits_subject_length_maximum: 10)
        )
      end

      it "answers issue hint" do
        expect(issue[:hint]).to eq("Use 10 characters or less.")
      end
    end
  end
end
