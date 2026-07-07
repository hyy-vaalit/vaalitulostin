#
# TODO: Read configuration from environment vars
#
class GlobalConfiguration < ApplicationRecord
  def self.mail_from_address
    Vaalit::Public::EMAIL_FROM_ADDRESS
  end

  def self.mail_from_name
    Vaalit::Public::EMAIL_FROM_NAME
  end

  # Raises on unexpected summary JSON (missing keys or null values)
  # instead of writing nils, which would later break result rendering
  # (sprintf "%6d", nil).
  def self.update_summary!(data)
    values = %w[votes_given votes_accepted voter_count voting_percentage]
             .to_h { |key| [key, data.fetch(key)] }

    if values.values.any?(&:nil?)
      raise "Voting API summary has null values: #{values.inspect}"
    end

    c = first!

    c.votes_given            = values.fetch("votes_given")
    c.votes_accepted         = values.fetch("votes_accepted")
    c.potential_voters_count = values.fetch("voter_count")
    c.voting_percentage      = values.fetch("voting_percentage")

    c.save!
  end

  def self.votes_given
    first!.votes_given
  end

  def self.votes_accepted
    first!.votes_accepted
  end

  def self.potential_voters_count
    first!.potential_voters_count
  end

  def self.voting_percentage
    first!.voting_percentage
  end
end
