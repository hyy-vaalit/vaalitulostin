RSpec.describe ImportedCsvVote, type: :model do
  describe "Creation" do
    before(:all) do
      sep = ","
      data  = <<-EOCSV
ehdokasnumero,ehdokasnimi,ääniä,vaaliliitto,vaaliliiton id
32,"Hanski, Anna",59,Akateemiset nallekarhut,2
4,"Savinen, Mäki",32,Akateemiset nallekarhut,2
EOCSV
      @rows = []

      CSV.parse(data, headers: true, col_sep: sep) do |row|
        @rows << row
      end
    end

    it "builds from csv" do
      first = ImportedCsvVote.build_from(@rows.first)
      expect(first.candidate_number).to eq(32)
      expect(first.vote_count).to eq(59)

      second = ImportedCsvVote.build_from(@rows.second)
      expect(second.candidate_number).to eq(4)
      expect(second.vote_count).to eq(32)
    end

    it "creates from csv" do
      coalition = FactoryGirl.create :electoral_coalition
      alliance = FactoryGirl.create :electoral_alliance,
                                    electoral_coalition: coalition,
                                    name: "Akateemiset nallekarhut"

      voting_area = FactoryGirl.create :voting_area
      candidate32 = FactoryGirl.create :candidate,
                                       electoral_alliance: alliance,
                                       candidate_number: 32
      candidate4 = FactoryGirl.create :candidate,
                                      electoral_alliance: alliance,
                                      candidate_number: 4

      first = ImportedCsvVote.create_from! @rows.first,
                                           voting_area_id: voting_area.id
      expect(Vote.count).to eq 1
      expect(first.amount).to eq 59
      expect(Vote.countable_sum).to eq 59
      expect(candidate32.votes.preliminary_sum).to eq 59

      second = ImportedCsvVote.create_from! @rows.second,
                                            voting_area_id: voting_area.id
      expect(Vote.count).to eq 2
      expect(second.amount).to eq 32
      expect(Vote.countable_sum).to eq 59 + 32
      expect(candidate4.votes.preliminary_sum).to eq 32
    end
  end
end
