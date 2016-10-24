class ImportedCsvCoalition

  attr_accessor :name,
                :numbering_order,
                :short_name,
                :alliance_count


  def self.create_from!(source)
    imported = build_from source

    ElectoralCoalition.create!(
      name:             imported.name,
      numbering_order:  imported.numbering_order,
      shorten:          imported.short_name,
      #TODO: expected_alliance_count
    )
  end

  def self.build_from(source)
    new.tap { |imported| imported.convert(source) }
  end

  # Assumes no header
  # Data:
  # name,numbering_order,short_name,alliance_count
  #  0     1                2              3
  def convert(data)
    @name            = data[0]
    @numbering_order = data[1]
    @short_name      = data[2]
    @alliance_count  = data[3]
  end

end
