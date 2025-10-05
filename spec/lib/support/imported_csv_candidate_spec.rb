require './lib/support/imported_csv_candidate'

module Support
  RSpec.describe ImportedCsvCandidate, type: :model do
    describe "Creation" do
      before(:all) do
        sep = ","
        data  = '291,Kaakkuri,Lanttu Aappa,"Kaakkuri, Lanttu",123456-1234,"09-1234567",etunimi.sukunimi@example.com,Testiosoite 1,10000,Helsinki,29,Akateemiset nallekarhut,H,"eipä kummempia"'
        @rows = []

        CSV.parse(data, col_sep: sep) do |row|
          @rows << row
        end
      end

      it "builds from csv" do
        imported_candidate = ImportedCsvCandidate.build_from(@rows.first)

        expect(imported_candidate.candidate_number).to eq("291")
        expect(imported_candidate.candidate_name).to eq("Kaakkuri, Lanttu")
        expect(imported_candidate.firstname).to eq("Lanttu Aappa")
        expect(imported_candidate.lastname).to eq("Kaakkuri")
        expect(imported_candidate.alliance_name).to eq("Akateemiset nallekarhut")
      end

      it "creates from csv" do
        coalition = FactoryBot.create :electoral_coalition
        FactoryBot.create :electoral_alliance,
                          electoral_coalition: coalition,
                          name: "Akateemiset nallekarhut"

        candidate = ImportedCsvCandidate.create_from!(@rows.first)

        expect(candidate.class).to eq Candidate
        expect(candidate.candidate_name).to eq("Kaakkuri, Lanttu")
        expect(candidate.firstname).to eq("Lanttu Aappa")
        expect(candidate.lastname).to eq("Kaakkuri")
        expect(candidate.candidate_number).to eq(291)
        expect(candidate.electoral_alliance.name).to eq("Akateemiset nallekarhut")
      end
    end
  end
end
