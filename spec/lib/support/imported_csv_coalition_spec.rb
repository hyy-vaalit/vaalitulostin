require './lib/support/imported_csv_coalition'

module Support
  RSpec.describe ImportedCsvCoalition, type: :model do
    describe "Creation" do
      before(:all) do
        sep = ","
        data  = 'Iso Vaalirengas,1,isohko,16'
        @rows = []

        CSV.parse(data, col_sep: sep) do |row|
          @rows << row
        end
      end

      it "builds from csv" do
        imported_coalition = ImportedCsvCoalition.build_from(@rows.first)

        expect(imported_coalition.name).to eq("Iso Vaalirengas")
        expect(imported_coalition.numbering_order).to eq("1")
        expect(imported_coalition.short_name).to eq("isohko")
        expect(imported_coalition.alliance_count).to eq("16")
      end

      it "creates from csv" do
        coalition = ImportedCsvCoalition.create_from!(@rows.first)

        expect(coalition.class).to eq ElectoralCoalition
        expect(coalition.name).to eq("Iso Vaalirengas")
        expect(coalition.numbering_order).to eq(1)
        expect(coalition.shorten).to eq("isohko")
      end
    end
  end
end
