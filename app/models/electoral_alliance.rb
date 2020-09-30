class ElectoralAlliance < ApplicationRecord
  include RankedModel

  has_many :candidates, dependent: :nullify

  has_many :votes, through: :candidates do
    def preliminary_sum
      countable.sum("amount")
    end

    def countable_sum
      countable.sum("COALESCE(votes.fixed_amount, votes.amount)").to_i
    end
  end

  has_many :candidate_results,
           -> { select "candidate_results.result_id" },
           through: :candidates

  has_many :alliance_results
  has_many :results, through: :alliance_results

  belongs_to :electoral_coalition
  ranks :numbering_order, with_same: :electoral_coalition_id

  scope :without_coalition, -> { where(electoral_coalition_id: nil) }
  scope :ready, -> { where(secretarial_freeze: true) }
  scope :by_numbering_order, -> { order("#{table_name}.numbering_order") }

  validates :name, :shorten, presence: true
  validates :shorten, :name, uniqueness: true

  validates :shorten, length: { in: 2..6 }
  validates :expected_candidate_count, presence: { allow_nil: true }

  def vote_sum_caches
    candidate_results
      .select(
        'candidate_results.result_id, sum(candidate_results.vote_sum_cache) as alliance_vote_sum_cache'
      )
      .group('candidate_results.result_id')
  end
end
