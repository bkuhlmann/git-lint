# frozen_string_literal: true

require "dry/monads"

RSpec.shared_context "with host dependencies" do
  include_context "with application dependencies"

  let :git do
    instance_spy Gitt::Repository,
                 call: Success(),
                 branch_default: Success("main"),
                 branch_name: Success("test")
  end
end
