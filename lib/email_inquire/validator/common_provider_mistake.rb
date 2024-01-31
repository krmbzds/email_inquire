# frozen_string_literal: true

require "email_inquire/validator/base"
require "email_inquire/validator/common_provider"
require "email_inquire/validator/damerau_levenstein"

module EmailInquire
  module Validator
    class CommonProviderMistake < Base
      def validate
        return if CommonProvider::DOMAINS.include?(domain)

        replacement_domain =
          CommonProvider::DOMAINS.find do |reference|
            distance = DamerauLevenshtein.distance(domain, reference)

            distance.equal?(1)
          end

        response.hint!(domain: replacement_domain) if replacement_domain
      end
    end
  end
end
