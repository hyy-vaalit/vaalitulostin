module Support
  class ImportedCsvAlliance

    attr_accessor :name,
                  :numbering_order,
                  :short_name,
                  :candidate_count,
                  :coalition_name

    def self.create_from!(source)
      imported = build_from source

      ElectoralAlliance.create!(
        name:            imported.name,
        numbering_order: imported.numbering_order,
        shorten:         imported.short_name,
        electoral_coalition: ElectoralCoalition.find_by_name!(imported.coalition_name)
      )
    end

    def self.build_from(source)
      new.tap { |imported| imported.convert(source) }
    end

    # Assumes no header
    # Data:
    # name,numbering_order,short_name,candidate_count,coalition_name
    #  0     1                2              3         4
    def convert(data)
      @name            = data[0]
      @numbering_order = data[1]
      @short_name      = data[2]
      @candidate_count = data[3]
      @coalition_name  = data[4]
    end

  end
end
