module Comparison
  class Year2009
    def proportionals
      @proportionals ||= parse_proportionals
    end

    def final_votes
      @final_votes ||= parse_final_votes
    end

    private

    # Parse comparison votes which were calculated by the previous
    # vaalit.exe program.
    def parse_final_votes
      csv_read 'HYY09_vaalit.exe_final_votes.csv'
    end

    def parse_proportionals
      csv_read 'proportionals.csv'
    end

    def csv_read(filename)
      CSV.read csv_file(filename), headers: true
    end

    def csv_file(name)
      File.join(__dir__, "2009/#{name}")
    end
  end
end
