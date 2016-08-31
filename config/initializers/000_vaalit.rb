module Vaalit

  module Public
    SITE_ADDRESS        = "https://vaalit.hyy.fi"
    SECRETARY_LOGIN_URL = "#{SITE_ADDRESS}/admin"
    EMAIL_FROM_ADDRESS  = "vaalit@hyy.fi"
    EMAIL_FROM_NAME     = "Silva Loikkanen"
  end

  module Voting
    PROPORTIONAL_PRECISION = 5   # Decimals used in proportional numbers (eg. 87.12345 is 5 decimals)
    ELECTED_CANDIDATE_COUNT = 60 # How many candidates are elected

    if (ENV['VOTING_CALCULATION_BEGINS_AT'])
      CALCULATION_BEGINS_AT = Time.parse(ENV['VOTING_CALCULATION_BEGINS_AT'])
    else
      raise "Set ENV['VOTING_CALCULATION_BEGINS_AT'] in .env"
    end

  end

  module Results
    S3_BUCKET_NAME  = ENV['S3_BUCKET_NAME'] || "hyy-koe"
    S3_BASE_URL     = ENV['S3_BASE_URL'] || "s3.amazonaws.com"

    RESULT_ADDRESS  = ENV['RESULT_ADDRESS'] || "http://hyy-koe.s3-website-us-east-1.amazonaws.com"
    DIRECTORY       = Time.now.year
    PUBLIC_RESULT_URL = "#{RESULT_ADDRESS}/#{DIRECTORY}"

  end

  module VotingApi
    JWT_APIKEY         = ENV.fetch 'VOTING_API_JWT_APIKEY'
    VOTES_URI          = URI ENV.fetch('VOTING_API_VOTES_ENDPOINT')
    SUMMARY_URI        = URI ENV.fetch('VOTING_API_SUMMARY_ENDPOINT')
  end

  module AWS
    def self.connect?
      Rails.env.production?
    end

    if connect?
      ::AWS::S3::Base.establish_connection!(
        :access_key_id     => ENV['S3_ACCESS_KEY_ID'],
        :secret_access_key => ENV['S3_ACCESS_KEY_SECRET']
      )
    end
  end

end
