RSpec.describe VoteImporter, type: :model do
  describe "Creation" do
    before do
      @data = <<~EOCSV
        ehdokasnumero,ehdokasnimi,ääniä,vaaliliitto,vaaliliiton id
        32,"Hanski, Anna",59,Akateemiset nallekarhut,2
        4,"Savinen, Mäki",32,Akateemiset nallekarhut,2
      EOCSV

      @voting_area = FactoryGirl.create :voting_area
      @vote_impoter = VoteImporter.new @voting_area
    end

    it "creates votes" do
      allow(ImportedCsvVote).to receive(:create_from!).twice
      allow(@voting_area).to receive(:submitted!).once
      allow(@voting_area).to receive(:ready!).once

      @vote_impoter.create_votes! @data
    end
  end
end
