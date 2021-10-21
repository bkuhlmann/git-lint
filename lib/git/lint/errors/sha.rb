# frozen_string_literal: true

module Git
  module Lint
    module Errors
      # Categorizes commit SHA errors.
      class SHA < Base
        def initialize sha
          super %(Invalid commit SHA: "#{sha}". Unable to obtain commit details.)
        end
      end
    end
  end
end
