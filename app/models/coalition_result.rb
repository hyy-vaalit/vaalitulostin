# CoalitionResult caches the current calculated amount of votes for each Coalition.
# This is needed when there are multiple VotingAreas and not all votes are
# calculated at once.
class CoalitionResult < ApplicationRecord
  belongs_to :result
  belongs_to :electoral_coalition

  scope :by_vote_sum, -> { order("vote_sum_cache desc") }

  def self.create_or_update!(electoral_coalition:, result:, vote_sum_cache:)
    existing =
      where(electoral_coalition_id: electoral_coalition.id)
      .find_by(result_id: result.id)

    if existing.present?
      existing.update_attributes! vote_sum_cache: vote_sum_cache
    else
      self.create!(
        electoral_coalition: electoral_coalition,
        result: result,
        vote_sum_cache: vote_sum_cache
      )
    end
  end
end
