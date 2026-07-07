class AllianceProportional < ApplicationRecord
  include ProportionCalculations

  belongs_to :result
  belongs_to :candidate

  validates :result_id, :candidate_id, :number, :numerator, :denominator, presence: true

  # For each coalition C,
  # iterate through all its alliances
  # ordered by their total vote sum.
  #
  # For each alliance A of coalition C,
  # give the sum S of all A's votes
  # to the A's candidate with most votes.
  # Give S divided by 2 to the candidate with second most votes
  # and S divided by N to the candidate with Nth most votes.
  #
  # The number in question is the alliance proportional.
  # rubocop:disable Rails/FindEach
  def self.calculate!(result)
    # An alliance without a coalition would silently get no
    # proportionals and its candidates could never be elected. The
    # import bypasses model validations, so check here (P0.8).
    orphans = ElectoralAlliance.without_coalition
    if orphans.exists?
      raise "Electoral alliances without a coalition: #{orphans.pluck(:shorten).join(', ')}"
    end

    ElectoralCoalition.all.each do |coalition|
      coalition.electoral_alliances.each do |alliance|
        alliance_votes = alliance.votes.countable_sum
        AllianceResult.create_or_update!(
          result: result,
          electoral_alliance: alliance,
          vote_sum_cache: alliance_votes
        )

        alliance
          .candidates.with_vote_sums_for(result)
          .each_with_index do |candidate, array_index|
          fraction = proportional_fraction(alliance_votes, array_index)
          self.create_or_update!(
            result_id: result.id,
            candidate_id: candidate.id,
            number: calculate_proportional(alliance_votes, array_index),
            numerator: fraction.numerator,
            denominator: fraction.denominator
          )
        end
      end
    end
  end
  # rubocop:enable Rails/FindEach

  # Ties are groups with the same exact fraction (reduced numerator and
  # denominator), never the rounded display number (P0.7).
  def self.find_duplicate_numbers(result_id)
    select("electoral_alliances.electoral_coalition_id,
            alliance_proportionals.numerator, alliance_proportionals.denominator")
      .joins('INNER JOIN candidates ON alliance_proportionals.candidate_id = candidates.id')
      .joins('INNER JOIN electoral_alliances ON  candidates.electoral_alliance_id = electoral_alliances.id')
      .where("alliance_proportionals.result_id = ?", result_id)
      .group("electoral_alliances.electoral_coalition_id,
              alliance_proportionals.numerator, alliance_proportionals.denominator having count(*) > 1")
      .order(Arel.sql("(alliance_proportionals.numerator::float8 / alliance_proportionals.denominator) desc,
              electoral_alliances.electoral_coalition_id asc"))
  end

  def self.find_draw_candidate_ids_of(draw_proportional, result_id)
    select('candidate_id')
      .joins('INNER JOIN candidates ON alliance_proportionals.candidate_id = candidates.id')
      .joins('INNER JOIN electoral_alliances ON candidates.electoral_alliance_id = electoral_alliances.id')
      .where(
        "numerator = ? AND denominator = ? AND result_id = ? AND electoral_coalition_id = ?",
        draw_proportional.numerator,
        draw_proportional.denominator,
        result_id,
        draw_proportional.electoral_coalition_id
      ).map(&:candidate_id)
  end
end
