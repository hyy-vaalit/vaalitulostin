require './lib/support/imported_csv_alliance'

namespace :db do
  namespace :seed do
    namespace :edari do

      desc 'seed alliances from stdin in csv format'
      task :alliances => :environment do
        ActiveRecord::Base.transaction do
          begin

            if ElectoralAlliance.count != 0
              raise "Expected Alliance table to be empty (has #{ElectoralAlliance.count} alliances)."
            end

            separator = ","
            encoding = "UTF-8"
            count = 0

            Rails.logger.info "SEEDING ALLIANCES"
            puts ""
            puts "==================== ALLIANCES ======================="
            puts "Paste Alliances in CSV format, finally press ^D"
            puts "Expected format is (without header):"
            puts "name,numbering_order,short_name,alliance_count"
            puts ""

            lines = $stdin.readlines

            lines.each do |csv_row|
              count = count + 1

              CSV.parse(csv_row, col_sep: separator, encoding: encoding) do |csv_alliance|
                Support::ImportedCsvAlliance.create_from! csv_alliance
              end
            end

            Rails.logger.info "Imported #{count} alliances from STDIN."
            Rails.logger.info "Database has now #{ElectoralAlliance.count} alliances."

          end
        end

      end
    end
  end
end
