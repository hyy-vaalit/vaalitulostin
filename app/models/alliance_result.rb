# AllianceResult caches the current calculated amount of votes for each Alliance.
# See CoalitionResult for further details.
class AllianceResult < ApplicationRecord
  belongs_to :result
  belongs_to :electoral_alliance

  scope :by_vote_sum, -> { order("vote_sum_cache desc") }

  def self.for_alliances(alliance_ids)
    where(["electoral_alliance_id IN (?)", alliance_ids])
  end

  def self.create_or_update!(electoral_alliance:, result:, vote_sum_cache:)
    existing =
      where(electoral_alliance_id: electoral_alliance.id)
      .find_by(result_id: result.id)

    if existing.present?
      existing.update! vote_sum_cache: vote_sum_cache
    else
      create!(
        electoral_alliance: electoral_alliance,
        result: result,
        vote_sum_cache: vote_sum_cache
      )
    end
  end
end
