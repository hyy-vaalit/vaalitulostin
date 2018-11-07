# Calculates the Result of the Election
#
# Result calculation can have the following states:
# - unset
#   Result is preliminary and there might be voting areas uncalculated.
#
# - freezed (sic)
#   All voting areas have been included in the result.
#   Result is ready for draws (1. candidate, 2. alliance, 3. coalition)
#
# - final
#   Draws have completed and result is ready to be deemed immutable.
#
# N.B. Ruby defines a "frozen" method for Object, so be aware of the
#      mixup with "freezed".
#
# rubocop:disable Metrics/ClassLength
class Result < ApplicationRecord
  has_many :coalition_proportionals, :dependent => :destroy
  has_many :alliance_proportionals, :dependent => :destroy

  has_many :candidate_results, :dependent => :destroy
  has_many :candidates,
    lambda {
      select "candidates.id,
        candidates.candidate_name,
        candidates.candidate_number,
        candidates.electoral_alliance_id"
    },
    through: :candidate_results

  has_many :alliance_results, :dependent => :destroy
  has_many :electoral_alliances,
           :through => :alliance_results

  has_many :coalition_results, :dependent => :destroy
  has_many :electoral_coalitions,
    lambda {
      select "electoral_coalitions.id,
        electoral_coalitions.name,
        electoral_coalitions.shorten"
    },
    through: :coalition_results

  has_many :candidate_draws, :dependent => :destroy
  has_many :alliance_draws, :dependent => :destroy
  has_many :coalition_draws, :dependent => :destroy

  after_create :calculate!

  def self.for_listing
    order('created_at desc')
  end

  def self.final
    where(:final => true)
  end

  def self.freezed
    where(:freezed => true)
  end

  # A frozen result is used for draws.
  #
  # A freezed result is created after
  # a) internet votes have been imported from Voting API
  # b) ballot vote re-counting (tarkastuslaskenta) has been finished.
  #
  # Only one freezed result may be created at a time.
  def self.freeze_for_draws!
    if self.freezed.any? || self.final.any?
      raise "Unexpectedly a frozen or final result already exists!"
    end

    Rails.logger.info "Creating a Frozen Result"
    self.create! :freezed => true
  end

  def self.candidate_draws_ready!
    Rails.logger.info "Marking candidate draws ready and calculating new alliance draws!"
    Result.freezed.first.candidate_draws_ready!
  end

  def self.alliance_draws_ready!
    Rails.logger.info "Marking alliance draws ready and calculating new coalition draws!"
    Result.freezed.first.alliance_draws_ready!
  end

  def self.finalize!
    Rails.logger.info "Creating the Final Result"
    Result.freezed.first.finalize!
  end

  def processed!
    update_attributes!(:in_process => false)
  end

  def in_process!
    update_attributes!(:in_process => true)
  end

  def published!
    update_attributes!(:published => true)
  end

  def published_pending!
    update_attributes!(:published_pending => true)
  end

  def pending_candidate_draws?
    return false if not freezed?

    not candidate_draws_ready?
  end

  def pending_alliance_draws?
    return false if pending_candidate_draws?

    not alliance_draws_ready?
  end

  def pending_coalition_draws?
    return false if pending_alliance_draws? or pending_candidate_draws?

    not coalition_draws_ready?
  end

  # Result must be freezed before any draws can be marked ready.
  def candidate_draws_ready!
    return false if not self.freezed?

    Result.transaction do
      update_attributes!(:candidate_draws_ready => true)
      recalculate!
      create_alliance_draws!
      create_coalition_draws!
      processed!
    end

    self
  end

  # Candidate draws must be marked ready before alliance draws can be finalized.
  def alliance_draws_ready!
    return false if not self.candidate_draws_ready?

    Result.transaction do
      update_attributes!(:alliance_draws_ready => true)
      recalculate!
      create_coalition_draws!
      processed!
    end

    self
  end

  # Result is finalized after all drawings have been made.
  # Alliance draws must be marked ready result can be finalized.
  def finalize!
    return false if not self.alliance_draws_ready?

    Result.transaction do
      self.update_attributes!(:final => true, :coalition_draws_ready => true)
      recalculate!
      processed!
    end

    self
  end

  def filename(suffix = ".html", prefix = "result")
    final_text = self.final? ? "lopullinen" : "alustava"

    "#{prefix}-#{final_text}-#{created_at.localtime.to_s(:number)}#{suffix}"
  end

  def candidates_in_election_order
    candidates.select(
      'candidates.id, candidates.candidate_name, candidates.candidate_number,
       coalition_proportionals.number as coalition_proportional, coalition_proportionals.number').joins(
       'INNER JOIN coalition_proportionals    ON candidates.id = coalition_proportionals.candidate_id').where(
       'coalition_proportionals.result_id = ?', self.id).order(
       'coalition_proportionals.number desc, candidate_results.coalition_draw_order asc')
  end

  def candidate_results_in_election_order
    candidates_in_election_order.select(
        'alliance_proportionals.number     AS  alliance_proportional,
         electoral_alliances.shorten       AS  electoral_alliance_shorten,
         candidate_results.elected         AS  elected,

         candidate_draws.identifier         AS  candidate_draw_identifier,
         candidate_draws.affects_elected_candidates AS candidate_draw_affects_elected,
         alliance_draws.identifier         AS  alliance_draw_identifier,
         alliance_draws.affects_elected_candidates AS alliance_draw_affects_elected,
         coalition_draws.identifier         AS  coalition_draw_identifier,
         coalition_draws.affects_elected_candidates AS coalition_draw_affects_elected,

         candidate_results.vote_sum_cache  AS  vote_sum').joins(
        'INNER JOIN electoral_alliances    ON  candidates.electoral_alliance_id   = electoral_alliances.id').joins(
        'LEFT OUTER JOIN candidate_draws   ON  candidate_results.candidate_draw_id = candidate_draws.id').joins(
        'LEFT OUTER JOIN alliance_draws    ON  candidate_results.alliance_draw_id = alliance_draws.id').joins(
        'LEFT OUTER JOIN coalition_draws   ON  candidate_results.coalition_draw_id = coalition_draws.id').joins(
        'INNER JOIN alliance_proportionals ON  candidates.id = alliance_proportionals.candidate_id').where(
        ['alliance_proportionals.result_id = ? AND candidate_results.result_id = ?', self.id, self.id])
  end

  def alliance_results_of(coalition_result)
    alliance_results.for_alliances(coalition_result.electoral_coalition.electoral_alliance_ids)
  end

  def candidate_results_of(alliance_result)
    candidate_results_in_election_order
      .where('electoral_alliance_id = ? ', alliance_result.electoral_alliance_id)
      .reorder('alliance_proportionals.number desc')
  end

  def elected_candidates_in_alliance(alliance_result)
    CandidateResult.elected_in_alliance(alliance_result.electoral_alliance_id, alliance_result.result_id)
  end

  def elected_candidates_in_coalition(coalition_result)
    CandidateResult.elected_in_coalition(coalition_result.electoral_coalition_id, coalition_result.result_id)
  end

  protected

  def calculate!
    Result.transaction do
      calculate_votes!
      alliance_proportionals!
      coalition_proportionals!
      elect_candidates!
      create_candidate_draws!
      create_alliance_draws!
      create_coalition_draws!
    end
  end

  def recalculate!
    Result.transaction do
      alliance_proportionals!
      coalition_proportionals!
      elect_candidates!
    end
  end

  def alliance_proportionals!
    AllianceProportional.calculate!(self)
  end

  def coalition_proportionals!
    CoalitionProportional.calculate!(self)
  end

  def calculate_votes!
    Candidate.with_vote_sums.each do |candidate|
      CandidateResult.create!(
        result: self,
        vote_sum_cache: candidate.vote_sum,
        candidate_id: candidate.id
      )
    end

    self.update_attributes!(:vote_sum_cache => Vote.countable_sum)
  end

  def elect_candidates!
    candidate_ids = candidates_in_election_order.limit(Vaalit::Voting::ELECTED_CANDIDATE_COUNT).map(&:id)
    CandidateResult.elect!(candidate_ids, self.id)
  end

  def create_candidate_draws!
    CandidateDraw.where(:result_id => self.id).destroy_all
    CandidateResult.find_duplicate_vote_sums(self.id).each_with_index do |draw, index|
      candidate_ids = ElectoralAlliance.find(draw.electoral_alliance_id).candidate_ids
      draw_candidate_results =
        candidate_results
        .where(
          "candidate_id IN (?) AND vote_sum_cache = ?",
          candidate_ids,
          draw.vote_sum_cache
        )

      candidate_draw = CandidateDraw.create!(
        result_id: self.id,
        identifier_number: index,
        affects_elected_candidates: CandidateDraw.affects_elected?(draw_candidate_results)
      )
      candidate_draw.candidate_results << draw_candidate_results
    end
  end

  def create_alliance_draws!
    create_proportional_draws!(AllianceDraw, AllianceProportional)
  end

  def create_coalition_draws!
    create_proportional_draws!(CoalitionDraw, CoalitionProportional)
  end

  private

  def create_proportional_draws!(draw_class, proportional_class)
    draw_class.where(:result_id => self.id).destroy_all

    proportional_class.find_duplicate_numbers(self.id).each_with_index do |draw_proportional, index|
      draw_candidate_ids = proportional_class.find_draw_candidate_ids_of(draw_proportional, self.id)
      draw_candidate_results = find_candidate_results_for(draw_candidate_ids)

      draw = draw_class.create!(
        result_id: self.id,
        identifier_number: index,
        affects_elected_candidates: draw_class.affects_elected?(draw_candidate_results)
      )
      draw.candidate_results << draw_candidate_results
    end
  end

  def find_candidate_results_for(candidate_ids)
    candidate_results.where(["candidate_id IN (?)", candidate_ids])
  end
end
# rubocop:enable Metrics/ClassLength
