RSpec.describe VoteImporter, type: :model do
  describe "Creation" do
    let(:votes1) { 59 }
    let(:votes2) { 123 }
    let(:alliance_name) { "Akateemiset nallekarhut" }
    let(:alliance) { FactoryGirl.create :electoral_alliance, name: alliance_name }
    let(:candidates) do
      [
        FactoryGirl.create(
          :candidate,
          electoral_alliance: alliance,
          candidate_name: "Hanski, Anna",
          candidate_number: 12
        ),
        FactoryGirl.create(
          :candidate,
          electoral_alliance: alliance,
          candidate_name: "Savinen, Mäki",
          candidate_number: 345
        )
      ]
    end

    before do
      @data = <<~EOCSV
        ehdokasnumero,ehdokasnimi,ääniä,vaaliliitto,vaaliliiton id
        #{candidates[0].candidate_number},"#{candidates[0].candidate_name}",#{votes1},#{alliance.name},#{alliance.id}
        #{candidates[1].candidate_number},"#{candidates[1].candidate_name}",#{votes2},#{alliance.name},#{alliance.id}
      EOCSV

      @voting_area = FactoryGirl.create :voting_area
      @vote_impoter = VoteImporter.new @voting_area
    end

    it "creates votes" do
      expect(@vote_impoter.create_votes!(@data)).to eq true
      expect(Vote.first.amount).to eq votes1
      expect(Vote.first.candidate_id).to eq candidates[0].id
      expect(Vote.second.amount).to eq votes2
      expect(Vote.second.candidate_id).to eq candidates[1].id
    end
  end
end
