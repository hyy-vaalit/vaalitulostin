namespace :db do
  namespace :seed do

    desc 'election with voters, coalitions, alliances and candidates'
    task :edari => :environment do

      ActiveRecord::Base.transaction do
        begin

          Rake::Task['db:seed:edari:coalitions'].invoke()
          Rake::Task['db:seed:edari:alliances'].invoke()
          Rake::Task['db:seed:edari:candidates'].invoke()

        rescue Exception => e
          puts "Error: #{e}"
          puts ""
          puts "Rolling back everything"
          raise ActiveRecord::Rollback
        end

        Rails.logger.info "SEED COMPLETED SUCCESFULLY"
        Rails.logger.info "Database has now:"
        Rails.logger.info "- #{ElectoralCoalition.count} coalitions"
        Rails.logger.info "- #{ElectoralAlliance.count} alliances"
        Rails.logger.info "- #{Candidate.count} candidates"
      end
    end


  end
end
