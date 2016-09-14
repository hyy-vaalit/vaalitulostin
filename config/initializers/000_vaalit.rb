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
    S3_BUCKET_NAME  = ENV.fetch 'S3_BUCKET_NAME'
    S3_BASE_URL     = ENV.fetch 'S3_BASE_URL'

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

  module AWS
    def self.connect?
      Rails.env.production?
    end

    if connect?
      ::AWS::S3::Base.establish_connection!(
        access_key_id:     ENV.fetch('S3_ACCESS_KEY_ID'),
        secret_access_key: ENV.fetch('S3_ACCESS_KEY_SECRET')
      )
    end
  end

end
