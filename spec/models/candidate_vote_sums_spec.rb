RSpec.describe Candidate, type: :model do
  describe ".with_vote_sums" do
    it "keeps a candidate whose votes are all in a non-ready area, with sum 0" do
      alliance = FactoryBot.create :electoral_alliance
      counted = FactoryBot.create :candidate, electoral_alliance: alliance
      uncounted = FactoryBot.create :candidate, electoral_alliance: alliance

      ready_area = FactoryBot.create :voting_area, ready: true
      pending_area = FactoryBot.create :voting_area, ready: false

      FactoryBot.create :vote, candidate: counted, voting_area: ready_area, amount: 7
      FactoryBot.create :vote, candidate: uncounted, voting_area: pending_area, amount: 5

      sums = Candidate.with_vote_sums.to_a.index_by(&:id)

      expect(sums.fetch(counted.id).vote_sum).to eq 7
      expect(sums.fetch(uncounted.id).vote_sum).to eq 0
    end
  end

  describe "AllianceProportional.calculate!" do
    it "raises when an alliance has no coalition" do
      result = FactoryBot.create :result
      alliance = FactoryBot.create :electoral_alliance
      alliance.update_column(:electoral_coalition_id, nil)

      expect { AllianceProportional.calculate!(result) }
        .to raise_error(/without a coalition/)
    end
  end
end
