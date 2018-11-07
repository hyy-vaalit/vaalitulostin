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

  def self.final
    select('COALESCE(votes.fixed_amount, votes.amount) as final_vote_amount,
           votes.id, votes.candidate_id, votes.voting_area_id')
  end

  def self.create_or_update_from(voting_area_id, candidate_id, vote_amount, fixed_amount)
    amount_attribute = fixed_amount ? :fixed_amount : :amount
    existing_vote = self.where("voting_area_id = ? AND candidate_id = ?", voting_area_id, candidate_id).first

    if existing_vote
      return existing_vote.update_attributes(amount_attribute.to_sym => vote_amount)
    else
      return self.create(:candidate_id => candidate_id, amount_attribute.to_sym => vote_amount, :voting_area_id => voting_area_id)
    end
  end

  protected

  def must_have_positive_amount
    errors.add :base, "Must have positive vote amount" if (amount and amount < 0) or (fixed_amount and fixed_amount < 0)
  end
end
