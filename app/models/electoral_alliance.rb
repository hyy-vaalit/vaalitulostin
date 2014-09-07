class ElectoralAlliance < ActiveRecord::Base
  include RankedModel

  has_many :votes, :through => :candidates do
    def preliminary_sum
      countable.sum("amount")
    end

    def countable_sum
      countable.sum("COALESCE(votes.fixed_amount, votes.amount)").to_i  # result is a string otherwise
    end
  end

  has_many :candidates, :dependent => :nullify

  has_many :candidate_results,
           :through => :candidates,
           :select => "candidate_results.result_id"

  has_many :alliance_results
  has_many :results, :through => :alliance_results

  belongs_to :advocate_user, :foreign_key => :primary_advocate_id

  belongs_to :electoral_coalition
  ranks :numbering_order, :with_same => :electoral_coalition_id

  scope :without_advocate_user, where(:primary_advocate_id => nil)
  scope :without_coalition, where(:electoral_coalition_id => nil)
  scope :not_real, joins(:candidates).where('candidates.candidate_name = electoral_alliances.name')
  scope :ready, where(:secretarial_freeze => true)
  scope :for_dashboard, order("primary_advocate_id ASC")
  scope :by_numbering_order, order("#{table_name}.numbering_order")

  validates_presence_of :name, :shorten
  validates_uniqueness_of :shorten, :name

  validates_length_of :shorten, :in => 2..6
  validates_presence_of :expected_candidate_count, :allow_nil => true


  def vote_sum_caches
    candidate_results.select(
      'candidate_results.result_id, sum(candidate_results.vote_sum_cache) as alliance_vote_sum_cache').group('candidate_results.result_id')
  end

  def freeze!
    if expected_candidate_count && candidates.count == expected_candidate_count
      return self.update_attribute :secretarial_freeze, true
    else
      return false
    end
  end

  def has_all_candidates?
    candidates.count == expected_candidate_count
  end

  def self.are_all_ready?
    self.count == self.ready.count
  end

end
