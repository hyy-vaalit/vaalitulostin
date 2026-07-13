require 'csv'

module Support
  class Psql
    def self.import_csv!(db_name:, filename:, table_name:, delimiter: ',')
      system psql(db_name, table_name, filename, delimiter), :out => File::NULL

      if $?.exitstatus.nonzero?
        raise "Psql command failed (exit #{$?.exitstatus}) importing #{filename} into #{table_name}"
      end

      true
    end

    private_class_method def self.psql(db_name, table_name, filename, delimiter)
      # COPY without a column list matches CSV columns to table columns by
      # position, and Rails 8.1 dumps schema.rb columns alphabetically, so the
      # test db column order no longer matches the fixture CSVs.
      columns = CSV.open(filename, col_sep: delimiter, &:shift).join(',')

      <<-EOCMD.squish
        psql #{db_name} -v ON_ERROR_STOP=1 -c
          "\\COPY #{table_name} (#{columns}) FROM '#{filename}'
          DELIMITER '#{delimiter}'
          CSV header;"
      EOCMD
    end
  end
end
