module Support
  class ImportedCsvCandidate

    attr_accessor :candidate_number,
                  :candidate_name,
                  :lastname,
                  :firstname,
                  :alliance_name


    def self.create_from!(source)
      imported = build_from source

      Candidate.create!(
        candidate_number: imported.candidate_number,
        firstname:        imported.firstname,
        lastname:         imported.lastname,
        candidate_name:   imported.candidate_name,
        electoral_alliance: ElectoralAlliance.find_by_name!(imported.alliance_name)
      )
    end

    def self.build_from(source)
      new.tap { |imported| imported.convert(source) }
    end

    # Data is:
    # Ehdokasnumero,Sukunimi,Etunimi,Ehdokasnimi,Hetu,Puhelin,Email,Postiosoite,Postitoimipaikka,Kaupunki,Vaaliliiton ID,Vaaliliitto,Tiedekuntakoodi,Huomioita
    #         0       1        2        3         4     5      6     7           8                   9        10          11                12          13
    def convert(data)
      @candidate_number = data[0]
      @lastname         = data[1]
      @firstname        = data[2]
      @candidate_name   = data[3]
      @alliance_name    = data[11]
    end

  end
end
