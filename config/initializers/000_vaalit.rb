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

    # Evaluated per use, not frozen at boot: web and worker restarted
    # across New Year would otherwise publish to different S3 year
    # directories. Set RESULTS_YEAR explicitly per election.
    def self.directory
      ENV.fetch('RESULTS_YEAR') { Time.now.year.to_s }
    end

    def self.public_result_url
      "#{RESULT_ADDRESS}/#{directory}"
    end
  end

  module VotingApi
    JWT_APIKEY         = ENV.fetch 'VOTING_API_JWT_APIKEY'

    BASE_URL           = ENV.fetch 'VOTING_API_BASE_URL'

    if Rails.env.production? && !BASE_URL.start_with?('https://')
      raise "VOTING_API_BASE_URL must use https in production (got: #{BASE_URL.inspect}); " \
            "the bearer token and voter data would otherwise be sent in cleartext"
    end

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

    # CloudFront distribution in front of the result bucket
    # (vaalitulos repo, plans/https-cloudfront.md). Blank id = feature off.
    module CloudFront
      DISTRIBUTION_ID = ENV.fetch('AWS_CLOUDFRONT_DISTRIBUTION_ID', '')

      # Like S3, AWS is contacted only in production mode.
      def self.connect?
        S3.connect? && DISTRIBUTION_ID.present?
      end

      def self.client
        ::Aws::CloudFront::Client.new(
          access_key_id: S3::ACCESS_KEY_ID,
          secret_access_key: S3::ACCESS_KEY_SECRET,
          region: S3::REGION
        )
      end
    end
  end
end
