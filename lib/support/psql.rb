module Support
  class Psql
    def self.import_csv!(db_name:, filename:, table_name:, delimiter: ',')
      system <<-EOCMD.squish
        psql #{db_name} -v ON_ERROR_STOP=1 -c
          "\\COPY #{table_name} FROM '#{filename}'
          DELIMITER '#{delimiter}'
          CSV header;"
      EOCMD

      raise RuntimeError 'Psql command failed' if $?.exitstatus.nonzero?

      true
    end
  end
end
