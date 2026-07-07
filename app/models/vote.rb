class Vote < ApplicationRecord
  belongs_to :voting_area
  belongs_to :candidate

  validates :voting_area, :candidate, :amount, presence: true
  validate :must_have_positive_amount

  scope :countable, -> { joins(:voting_area).where('voting_areas.ready = ?', true) }

  scope :with_fixes, -> { where('fixed_amount is not null') }

  default_scope { includes(:candidate).order('candidates.candidate_number') }

  # A frozen result freezes vote_sum_cache but later stages still read the
  # live votes table (proportional recalculation). Votes must therefore be
  # immutable from freeze onwards or the final result would mix old and new
  # sums.
  before_save :forbid_mutation_when_result_frozen!
  before_destroy :forbid_mutation_when_result_frozen!

  def self.countable_sum
    countable.sum('COALESCE(votes.fixed_amount, votes.amount)')
  end

  protected

  def must_have_positive_amount
    errors.add :base, "Must have positive vote amount" if amount&.negative? || fixed_amount&.negative?
  end

  def forbid_mutation_when_result_frozen!
    return unless Result.freezed.any? || Result.final.any?

    raise "Votes cannot be created or changed while a frozen or final result exists"
  end
end
