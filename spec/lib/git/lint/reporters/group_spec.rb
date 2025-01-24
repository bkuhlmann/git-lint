# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Reporters::Group do
  subject(:reporter) { described_class.new analyzer }

  let :analyzer do
    instance_spy Git::Lint::Analyzers::CommitAuthorEmail,
                 class: class_spy(
                   Git::Lint::Analyzers::CommitAuthorEmail,
                   label: "Commit Author Email"
                 ),
                 severity:,
                 issue:
  end

  let(:severity) { "error" }
  let(:issue) { {hint: "A test hint.", references: ["aaa One", "bbb Two"]} }

  describe "#to_s" do
    context "with warning" do
      let(:severity) { "warn" }

      it "answers yellow label, hint, and references" do
        expect(reporter.to_s).to eq(<<~CONTENT.chomp)
          \e[33mCommit Author Email Warning. A test hint.
            aaa One
            bbb Two\e[0m
        CONTENT
      end
    end

    context "with error" do
      let(:severity) { "error" }

      it "answers red label, hint, and references" do
        expect(reporter.to_s).to eq(<<~CONTENT.chomp)
          \e[31mCommit Author Email Error. A test hint.
            aaa One
            bbb Two\e[0m
        CONTENT
      end
    end

    context "with unknown severity" do
      let(:severity) { :bogus }

      it "answers white label, hint, and references" do
        expect(reporter.to_s).to eq(<<~CONTENT.chomp)
          \e[37mCommit Author Email. A test hint.
            aaa One
            bbb Two\e[0m
        CONTENT
      end
    end

    it "answers empty string with no issue" do
      issue.clear
      expect(reporter.to_s).to eq("")
    end
  end

  describe "#to_str" do
    it "answers implicit text" do
      expect(reporter.to_str).to eq(<<~CONTENT.chomp)
        \e[31mCommit Author Email Error. A test hint.
          aaa One
          bbb Two\e[0m
      CONTENT
    end
  end
end
