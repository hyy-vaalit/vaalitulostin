namespace :seed do

  namespace :production do

    def create_voting_area!(opts)
      code = opts[:code]
      name = opts[:name]

      VotingArea.create! :code => code, :name => name
    end

    #TODO: move these into csv
    desc 'Seed data for faculties'
    task :faculties => :environment do
      puts 'Seeding faculties ...'
      Faculty.create! :code => 'B', :numeric_code => 57, :name => 'Biotieteellinen'
      Faculty.create! :code => 'E', :numeric_code => 90, :name => 'Eläinlääketieteellinen'
      Faculty.create! :code => 'F', :numeric_code => 55, :name => 'Farmasia'
      Faculty.create! :code => 'H', :numeric_code => 40, :name => 'Humanistinen'
      Faculty.create! :code => 'K', :numeric_code => 60, :name => 'Käyttäytymistieteellinen'
      Faculty.create! :code => 'L', :numeric_code => 30, :name => 'Lääketieteellinen'
      Faculty.create! :code => 'ML',:numeric_code => 50, :name => 'Matemaattis-luonnontieteellinen'
      Faculty.create! :code => 'MM',:numeric_code => 80, :name => 'Maa- ja metsätieteellinen'
      Faculty.create! :code => 'O', :numeric_code => 20, :name => 'Oikeustieteellinen'
      Faculty.create! :code => 'T', :numeric_code => 10, :name => 'Teologinen'
      Faculty.create! :code => 'V', :numeric_code => 70, :name => 'Valtiotieteellinen'
      Faculty.create! :code => 'S', :numeric_code => 74, :name => 'Svenska social- och kommunalhögskolan'
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
    Rake::Task['seed:production:faculties'].invoke
    Rake::Task['seed:production:internet_voting_area'].invoke
    Rake::Task['seed:production:configuration'].invoke
  end

end
