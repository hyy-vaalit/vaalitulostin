class Vote < ApplicationRecord
  belongs_to :voting_area
  belongs_to :candidate

  validates_presence_of :voting_area, :candidate, :amount
  validate :must_have_positive_amount

  scope :countable, -> { joins(:voting_area).where('voting_areas.ready = ?', true) }

  scope :with_fixes, -> { where('fixed_amount is not null') }

  default_scope { includes(:candidate).order('candidates.candidate_number') }

  def self.countable_sum
    countable.sum('COALESCE(votes.fixed_amount, votes.amount)')
  end

  protected

  def must_have_positive_amount
    errors.add :base, "Must have positive vote amount" if (amount and amount < 0) or (fixed_amount and fixed_amount < 0)
  end
end
