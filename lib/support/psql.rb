module Support
  class Psql
    def self.import_csv!(db_name:, filename:, table_name:, delimiter: ',')
      system psql(db_name, table_name, filename, delimiter), :out => File::NULL

      raise RuntimeError 'Psql command failed' if $?.exitstatus.nonzero?

      true
    end

    private_class_method def self.psql(db_name, table_name, filename, delimiter)
      <<-EOCMD.squish
        psql #{db_name} -v ON_ERROR_STOP=1 -c
          "\\COPY #{table_name} FROM '#{filename}'
          DELIMITER '#{delimiter}'
          CSV header;"
      EOCMD
    end
  end
end
