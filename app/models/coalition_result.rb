# CoalitionResult caches the current calculated amount of votes for each Coalition.
# This is needed when there are multiple VotingAreas and not all votes are
# calculated at once.
class CoalitionResult < ActiveRecord::Base
  belongs_to :result
  belongs_to :electoral_coalition

  scope :by_vote_sum, -> { order("vote_sum_cache desc") }

  # Params:
  #  :result => result,
  #  :electoral_coalition => coalition,
  #  :vote_sum_cache => coalition_votes
  def self.create_or_update!(opts = {})
    if existing = self.where(:electoral_coalition_id => opts[:electoral_coalition]).where(:result_id => opts[:result]).first
      existing.update_attributes!(:vote_sum_cache => opts[:vote_sum_cache])
    else
      self.create!(opts)
    end
  end
end
