#
# TODO: Read configuration from environment vars
#
class GlobalConfiguration < ActiveRecord::Base

  def self.mail_from_address
    Vaalit::Public::EMAIL_FROM_ADDRESS
  end

  def self.mail_from_name
    Vaalit::Public::EMAIL_FROM_NAME
  end

  def self.update_summary!(data)
    c = first

    c.votes_given            = data["votes_given"]
    c.votes_accepted         = data["votes_accepted"]
    c.potential_voters_count = data["voter_count"]
    c.voting_percentage      = data["voting_percentage"]

    c.save!
  end

  def self.votes_given
    first.votes_given
  end

  def self.votes_accepted
    first.votes_accepted
  end

  def self.potential_voters_count
    first.potential_voters_count
  end

  def self.voting_percentage
    first.voting_percentage
  end

end
