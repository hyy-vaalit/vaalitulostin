class CoalitionProportional < ApplicationRecord
  include ProportionCalculations

  belongs_to :result
  belongs_to :candidate

  validates :result_id, :candidate_id, :number, :numerator, :denominator, presence: true

  # Iterate through all candidates of a coalition
  # ordered by their alliance proportional number.
  #
  # Give the sum S of all coalition's votes
  # to the candidate with the highest alliance proportional number.
  # Give S divided by 2 to the candidate with second most votes
  # and S divided by N to the candidate with Nth most votes.,
  #
  # The number in question is the coalition proportional number.
  # rubocop:disable Rails/FindEach
  def self.calculate!(result)
    ElectoralCoalition.all.each do |coalition|
      coalition_votes = coalition.countable_vote_sum

      CoalitionResult.create_or_update!(
        result: result,
        electoral_coalition: coalition,
        vote_sum_cache: coalition_votes
      )

      coalition
        .candidates
        .with_alliance_proportionals_for(result)
        .each_with_index do |candidate, index|
        fraction = proportional_fraction(coalition_votes, index)
        create_or_update!(
          result_id: result.id,
          candidate_id: candidate.id,
          number: calculate_proportional(coalition_votes, index),
          numerator: fraction.numerator,
          denominator: fraction.denominator
        )
      end
    end
  end
  # rubocop:enable Rails/FindEach

  # Ties are groups with the same exact fraction (reduced numerator and
  # denominator), never the rounded display number (P0.7).
  def self.find_duplicate_numbers(result_id)
    select("coalition_proportionals.numerator, coalition_proportionals.denominator")
      .from(table_name)
      .where("coalition_proportionals.result_id = ?", result_id)
      .group("coalition_proportionals.numerator, coalition_proportionals.denominator having count(*) > 1")
      .order(Arel.sql("(coalition_proportionals.numerator::float8 / coalition_proportionals.denominator) desc"))
  end

  def self.find_draw_candidate_ids_of(draw_proportional, result_id)
    select('candidate_id')
      .where([
        "numerator = ? AND denominator = ? AND result_id = ?",
        draw_proportional.numerator, draw_proportional.denominator, result_id
      ])
      .map(&:candidate_id)
  end
end
