# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Reporters::Style do
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

  let(:severity) { :error }
  let(:issue) { {hint: "A test hint."} }

  describe "#to_s" do
    context "with warning" do
      let(:severity) { :warn }

      it "answers analyzer label and issue hint" do
        expect(reporter.to_s).to eq("\e[33m  Commit Author Email Warning. A test hint.\n\e[0m")
      end
    end

    context "with error" do
      let(:severity) { :error }

      it "answers analyzer label and issue hint" do
        expect(reporter.to_s).to eq("\e[31m  Commit Author Email Error. A test hint.\n\e[0m")
      end
    end

    context "with unknown severity" do
      let(:severity) { :bogus }

      it "answers analyzer label and issue hint" do
        expect(reporter.to_s).to eq("\e[37m  Commit Author Email. A test hint.\n\e[0m")
      end
    end

    context "with issue lines" do
      let :issue do
        {
          hint: "A test hint.",
          lines: [
            {number: 1, content: "Curabitur eleifend wisi iaculis ipsum."},
            {number: 3, content: "Ipsum eleifend wisi iaculis curabitur."}
          ]
        }
      end

      it "answers analyzer label, issue label, issue hint, and issue lines" do
        expect(reporter.to_s).to eq(<<~BODY.chomp)
          \e[31m  Commit Author Email Error. A test hint.
              Line 1: "Curabitur eleifend wisi iaculis ipsum."
              Line 3: "Ipsum eleifend wisi iaculis curabitur."\n\e[0m
        BODY
      end
    end
  end

  describe "#to_str" do
    it "answers implicit string" do
      expect(reporter.to_str).to eq("\e[31m  Commit Author Email Error. A test hint.\n\e[0m")
    end
  end
end
