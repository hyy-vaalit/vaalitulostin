namespace :db do
  namespace :seed do
    namespace :production do

      def create_voting_area!(opts)
        code = opts[:code]
        name = opts[:name]

        area = VotingArea.create! :code => code, :name => name
      end

      #TODO: move these into csv
      desc 'Seed data for faculties'
      task :faculties => :environment do
        puts 'Seeding faculties ...'
        # Faculty.create! code: "1", name: 'Tuntematon'

        Faculty.create! code: "H10", name: 'Teologinen'
        Faculty.create! code: "H20", name: 'Oikeustieteellinen'
        Faculty.create! code: "H30", name: 'Lääketieteellinen'
        Faculty.create! code: "H40", name: 'Humanistinen'
        Faculty.create! code: "H50", name: 'Matemaattis-luonnontieteellinen'
        Faculty.create! code: "H55", name: 'Farmasia'
        Faculty.create! code: "H57", name: 'Bio- ja ympäristötieteellinen'
        Faculty.create! code: "H60", name: 'Kasvatustieteellinen'
        Faculty.create! code: "H70", name: 'Valtiotieteellinen'
        Faculty.create! code: "H80", name: 'Maatalous-metsätieteellinen'
        Faculty.create! code: "H90", name: 'Eläinlääketieteellinen'

        Faculty.create! code: "H74", name: 'Svenska social- och kommunalhögskolan'
      end

      desc 'Create internet voting area'
      task :internet_voting_area => :environment do
        create_voting_area! code: 'internet', name: 'Internet-äänestys'
      end

      # TODO: Remove GlobalConfiguration and read from ENV
      desc 'Setup production configuration defaults'
      task :configuration => :environment do
        GlobalConfiguration.create!
      end
    end

    desc 'Seed initial production data (required for deployment!)'
    task :production do
      Rake::Task['db:seed:production:faculties'].invoke
      Rake::Task['db:seed:production:internet_voting_area'].invoke
      Rake::Task['db:seed:production:configuration'].invoke
    end

  end
end
