require 'support/psql'

module Seed
  class Year2009
    def self.import_base_data!
      %w[
        electoral_coalitions
        electoral_alliances
        candidates
        global_configurations
        voting_areas
        votes
      ].each do |name|
        import!(table_name: name, filename: csv_file('base_data', name))
      end
    end

    def self.import_candidate_draw_order!
      comparison_data.each do |row|
        candidate_draw_order = row["candidate_draw_order"].to_i

        next if candidate_draw_order.zero?

        Candidate
          .find_by!(candidate_number: row["candidate_number"])
          .candidate_results
          .first
          .update! candidate_draw_order: candidate_draw_order
      end
    end

    def self.import_alliance_draw_order!
      comparison_data.each do |row|
        alliance_draw_order = row["alliance_draw_order"].to_i

        next if alliance_draw_order.zero?

        Candidate
          .find_by!(candidate_number: row["candidate_number"])
          .candidate_results
          .first
          .update! alliance_draw_order: alliance_draw_order
      end
    end

    def self.import_coalition_draw_order!
      comparison_data.each do |row|
        coalition_draw_order = row["coalition_draw_order"].to_i

        next if coalition_draw_order.zero?

        Candidate
          .find_by!(candidate_number: row["candidate_number"])
          .candidate_results
          .first
          .update! coalition_draw_order: coalition_draw_order
      end
    end

    private_class_method def self.comparison_data
      csv_read csv_file('final', 'HYY09_vaalit.exe_final_votes')
    end

    private_class_method def self.import!(filename:, table_name:)
      Support::Psql.import_csv!(
        db_name: ActiveRecord::Base.connection_db_config.database,
        filename: filename,
        table_name: table_name
      )
    end

    private_class_method def self.csv_file(dir, name)
      File.join(__dir__, "2009/#{dir}/#{name}.csv")
    end

    private_class_method def self.csv_read(filename)
      CSV.read filename, headers: true
    end
  end
end
