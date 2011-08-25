class Candidate < ActiveRecord::Base
  include RankedModel

  state_machine :initial => :not_selected do
    event :select_me do
      transition [:not_selected] => :selected
    end
    event :spare_me do
      transition [:not_selected] => :spared
    end
    event :unselect_me do
      transition any => :not_selected
    end
  end

  has_many :candidate_drawings
  has_many :candidate_draws, :through => :candidate_drawings

  belongs_to :electoral_alliance
  ranks :sign_up_order, :with_same => :electoral_alliance_id

  belongs_to :faculty

  has_many :data_fixes

  has_many :votes

  scope :cancelled, where(:cancelled => true)

  scope :valid, where(:cancelled => false, :marked_invalid => false)

  scope :without_electoral_alliance, joins(:electoral_alliance).where('candidates.candidate_name = electoral_alliances.name')

  scope :has_fixes, lambda { joins(:data_fixes) & DataFix.unapplied }

  scope :selection_order, order('coalition_proportional desc, alliance_proportional desc')

  scope :selected, where(:state => :selected)

  validates_presence_of :lastname, :electoral_alliance

  before_save :clear_lines!

  attr_accessor :has_fixes

  def invalid!
    self.update_attribute :marked_invalid, true
  end

  def cancel!
    self.update_attribute :cancelled, true
  end

  def total_votes
    self.votes.ready.sum(:vote_count)
  end

  def fixed_total_votes
    self.votes.fixed.sum(:vote_count)
  end

  def has_fixes
    self.data_fixes.count > 0
  end

  def vote_count_from_area(voting_area_id)
    voting_area = VotingArea.find_by_id voting_area_id
    vote = voting_area.votes.find_by_candidate_id self.id
    vote ? vote.vote_count : 0
  end

  def fix_vote_count_from_area(voting_area_id)
    voting_area = VotingArea.find_by_id voting_area_id
    vote = voting_area.votes.find_by_candidate_id self.id
    vote ? vote.fix_count : ''
  end

  def self.give_numbers!
    raise 'not ready' unless ElectoralAlliance.are_all_ready? and ElectoralCoalition.are_all_ordered?
    Candidate.transaction do
      Candidate.update_all :candidate_number => 0
      candidates_in_order = Candidate.select('candidates.*').joins(:electoral_alliance).joins(:electoral_alliance => :electoral_coalition).order(:number_order).order(:signing_order).order(:sign_up_order).valid.all
      candidates_in_order.each_with_index do |candidate, i|
        candidate.update_attribute :candidate_number, i+2
      end
    end
  end

  def clear_lines!
    self.notes.gsub!(/(\r\n|\n|\r)/, ', ') if self.notes
  end

end
