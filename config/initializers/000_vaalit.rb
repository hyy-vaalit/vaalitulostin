module Vaalit

  module Public
    SITE_ADDRESS        = ENV.fetch 'SITE_ADDRESS'
    SECRETARY_LOGIN_URL = "#{SITE_ADDRESS}/admin"
    EMAIL_FROM_ADDRESS  = ENV.fetch 'EMAIL_FROM_ADDRESS'
    EMAIL_FROM_NAME     = ENV.fetch 'EMAIL_FROM_NAME'
  end

  module Voting
    PROPORTIONAL_PRECISION = 5   # Decimals used in proportional numbers (eg. 87.12345 is 5 decimals)
    ELECTED_CANDIDATE_COUNT = 60 # How many candidates are elected
  end

  module Results
    AWS_S3_BUCKET_NAME  = ENV.fetch 'AWS_S3_BUCKET_NAME'
    AWS_S3_BASE_URL     = ENV.fetch 'AWS_S3_BASE_URL'

    RESULT_ADDRESS  = ENV.fetch 'RESULT_ADDRESS'
    DIRECTORY       = Time.now.year
    PUBLIC_RESULT_URL = "#{RESULT_ADDRESS}/#{DIRECTORY}"

  end

  module VotingApi
    JWT_APIKEY         = ENV.fetch 'VOTING_API_JWT_APIKEY'

    BASE_URL           = ENV.fetch 'VOTING_API_BASE_URL'
    VOTES_URI          = URI(BASE_URL + ENV.fetch('VOTING_API_VOTES_ENDPOINT'))
    VOTERS_URI         = URI(BASE_URL + ENV.fetch('VOTING_API_VOTERS_ENDPOINT'))
    SUMMARY_URI        = URI(BASE_URL + ENV.fetch('VOTING_API_SUMMARY_ENDPOINT'))
    SESSION_LINK_URI   = URI(BASE_URL + ENV.fetch('VOTING_API_SESSION_LINK_ENDPOINT'))
  end

  module Aws
    # https://docs.aws.amazon.com/sdk-for-ruby/v2/api/index.html
    module S3
      REGION = ENV.fetch('AWS_S3_REGION', "us-east-1")
      ACCESS_KEY_ID = ENV.fetch('AWS_S3_ACCESS_KEY_ID')
      ACCESS_KEY_SECRET = ENV.fetch('AWS_SECRET_ACCESS_KEY')

      def self.connect?
        Rails.env.production?
      end

      def self.client
        ::Aws::S3::Client.new(
          access_key_id: ACCESS_KEY_ID,
          secret_access_key: ACCESS_KEY_SECRET,
          region: REGION
        )
      end
    end
  end
end
