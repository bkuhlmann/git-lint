# frozen_string_literal: true

RSpec::Matchers.define :match_gem_version do
  match do |actual|
    actual.match?(
      /
        \A           # Start of string.
        [a-zA-Z\s]+  # Gem label.
        \s           # Space delimiter.
        \d+          # Major version.
        \.           # Version delimiter.
        \d+          # Minor version.
        \.           # Version delimiter.
        \d+          # Patch version.
        \z           # End of string.
      /x
    )
  end
end
