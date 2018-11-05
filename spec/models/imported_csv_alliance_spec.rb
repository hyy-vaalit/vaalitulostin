require './lib/support/imported_csv_alliance'

RSpec.describe ImportedCsvAlliance, type: :model do
  describe "Creation" do
    before(:all) do
      sep = ","
      data  = 'Iso Vaaliliitto,1,isohko,50,Akateemiset nallekarhut'
      @rows = []

      CSV.parse(data, col_sep: sep) do |row|
        @rows << row
      end
    end

    it "builds from csv" do
      imported_alliance = ImportedCsvAlliance.build_from(@rows.first)

      expect(imported_alliance.name).to eq("Iso Vaaliliitto")
      expect(imported_alliance.numbering_order).to eq("1")
      expect(imported_alliance.short_name).to eq("isohko")
      expect(imported_alliance.candidate_count).to eq("50")
      expect(imported_alliance.coalition_name).to eq("Akateemiset nallekarhut")
    end

    it "creates from csv" do
      FactoryGirl.create :electoral_coalition,
                          name: "Akateemiset nallekarhut"

      alliance = ImportedCsvAlliance.create_from!(@rows.first)

      expect(alliance.class).to eq ElectoralAlliance
      expect(alliance.name).to eq("Iso Vaaliliitto")
      expect(alliance.numbering_order).to eq(1)
      expect(alliance.shorten).to eq("isohko")
      expect(alliance.electoral_coalition_id).to eq ElectoralCoalition.find_by_name("Akateemiset nallekarhut").id
      #TODO: expect(alliance.expected_candidate_count).to eq(50)
    end
  end
end
