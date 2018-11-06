# rubocop:disable RSpec/DescribeClass
describe 'votable behaviour' do
  before do
    stub_result_class!
    @ready_voting_areas = []
    @unready_voting_areas = []
    3.times { @ready_voting_areas << FactoryGirl.create(:ready_voting_area) }
    3.times { @unready_voting_areas << FactoryGirl.create(:unready_voting_area) }
  end

  def stub_result_class!
    allow(Result).to receive(:calculate_votes!)
    allow(Result).to receive(:alliance_proportionals!)
    allow(Result).to receive(:coalition_proportionals!)
  end

  describe 'votable candidates' do
    it 'gives a list of all candidates ordered by their alliance proportional' do
      allow(AllianceProportional).to receive(:calculate!)
      allow(CoalitionProportional).to receive(:calculate!)
      result = FactoryGirl.create(:result_with_alliance_proportionals_and_candidates)

      ordered_candidates = Candidate.with_alliance_proportionals_for(result)

      ordered_candidates.should_not be_empty
      ordered_candidates.each_with_index do |candidate, index|
        next_candidate = ordered_candidates[index + 1]
        next if next_candidate.nil?

        expect(candidate.alliance_proportionals.last.number)
          .to be > next_candidate.alliance_proportionals.last.number
      end
    end

    it 'gives a list of all candidates ordered by their coalition proportional' do
      result = FactoryGirl.create(:result_with_coalition_proportionals_and_candidates)

      ordered_candidates = result.candidate_results_in_election_order
      ordered_candidates.should_not be_empty

      ordered_candidates.each_with_index do |candidate, index|
        next_candidate = ordered_candidates[index + 1]

        next unless next_candidate

        if candidate.coalition_proportional.zero?
          next_candidate.coalition_proportional.should be_zero
        else
          candidate.coalition_proportional.to_f.should > next_candidate.coalition_proportional.to_f
        end
      end
    end

    it 'allows chaining with_votes_sum with other scopes' do
      alliance = FactoryGirl.create(:electoral_alliance_with_candidates)
      other_alliance = FactoryGirl.create(:electoral_alliance_with_candidates)
      VotableSupport.create_votes_for(alliance.candidates, @ready_voting_areas, :ascending => true)
      VotableSupport.create_votes_for(other_alliance.candidates, @ready_voting_areas, :ascending => true)

      expect(Candidate.count).to be > alliance.candidates.count

      expect(alliance.candidates.with_vote_sums.map(&:id))
        .to eq alliance.candidates.reverse.map(&:id)
    end

    it 'allows chaining with_alliance_proportionals_for with other scopes' do
      result = FactoryGirl.create(:result_with_alliance_proportionals_and_candidates)
      alliance = result.alliance_proportionals.first.candidate.electoral_alliance

      expect(Candidate.count).to be > alliance.candidates.count

      expect(alliance.candidates.with_alliance_proportionals_for(result).map(&:id))
        .to eq alliance.candidates.map(&:id)
    end

    it 'gives a list of all candidates ordered by their vote sum' do
      candidates = []
      10.times { candidates << FactoryGirl.create(:candidate) }
      VotableSupport.create_votes_for(candidates, @ready_voting_areas, :ascending => true)

      expect(Candidate.with_vote_sums.map(&:id))
        .to eq candidates.reverse.map(&:id)
    end

    it 'gives a list of all candidates ordered by their vote sum and excludes unready voting areas' do
      candidates = []
      10.times { candidates << FactoryGirl.create(:candidate) }
      VotableSupport.create_votes_for(candidates, @ready_voting_areas, :ascending => true)
      VotableSupport.create_votes_for(
        candidates, @unready_voting_areas, :ascending => false, :base_vote_count => 10000
      )

      expect(Candidate.with_vote_sums.map(&:id)).to eq candidates.reverse.map(&:id)
    end

    describe 'preliminary votes' do
      before do
        @candidate = FactoryGirl.create(:candidate)
      end

      it 'has preliminary votes from voting areas which have been fully counted' do
        amount = 10
        @ready_voting_areas.each do |area|
          FactoryGirl.create(
            :vote, :candidate => @candidate,
            :voting_area => area,
            :amount => amount
          )
        end

        expect(@candidate.votes.preliminary_sum).to eq amount * @ready_voting_areas.count
      end

      it 'does not add votes from unfinished voting areas to preliminary votes' do
        amount = 10
        [@ready_voting_areas, @unready_voting_areas].each do |area_group|
          area_group.each do |area|
            FactoryGirl.create(
              :vote,
              :candidate => @candidate,
              :voting_area => area,
              :amount => amount
            )
          end
        end

        expect(@candidate.votes.preliminary_sum).to eq amount * @ready_voting_areas.count
      end
    end
  end

  describe 'votable alliance behaviour' do
    describe 'preliminary votes' do
      before do
        @alliance = FactoryGirl.create(:electoral_alliance_with_candidates)
      end

      it 'has preliminary votes from voting areas which have been fully counted' do
        amount = 10
        @alliance.candidates.each do |c|
          VotableSupport.create_votes_for_candidate(c, amount, @ready_voting_areas)
        end

        expect(@alliance.votes.preliminary_sum)
          .to eq amount * @ready_voting_areas.count * @alliance.candidates.count
      end

      it 'does not count votes from unfinished voting areas to preliminary votes' do
        amount = 10
        @alliance.candidates.each do |candidate|
          VotableSupport.create_votes_for_candidate(candidate, amount, @ready_voting_areas)
          VotableSupport.create_votes_for_candidate(candidate, amount, @unready_voting_areas)
        end

        expect(@alliance.votes.preliminary_sum)
          .to eq amount * @ready_voting_areas.count * @alliance.candidates.count
      end
    end
  end

  describe 'votable coalition behaviour' do
    describe 'preliminary votes' do
      before do
        @coalition = FactoryGirl.create(:electoral_coalition_with_alliances_and_candidates)
      end

      it 'has preliminary votes as a sum of alliance votes' do
        amount = 10
        @coalition.electoral_alliances.each do |alliance|
          VotableSupport.create_votes_for_alliance(alliance, amount, @ready_voting_areas)
        end

        expect(@coalition.preliminary_vote_sum)
          .to eq amount * @ready_voting_areas.count * @coalition.candidates.count
      end

      it 'does not count votes from unfinished voting areas to preliminary votes' do
        amount = 10
        @coalition.electoral_alliances.each do |alliance|
          VotableSupport.create_votes_for_alliance(alliance, amount, @ready_voting_areas)
          VotableSupport.create_votes_for_alliance(alliance, amount, @unready_voting_areas)
        end

        expect(@coalition.preliminary_vote_sum)
          .to eq amount * @ready_voting_areas.count * @coalition.candidates.count
      end
    end
  end
end
# rubocop:enable RSpec/DescribeClass
