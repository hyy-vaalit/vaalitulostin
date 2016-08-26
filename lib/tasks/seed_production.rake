# coding: UTF-8

namespace :seed do

  namespace :production do

    def create_voting_area(opts)
      code = opts[:code]
      name = opts[:name]
      password = opts[:password]

      area =  VotingArea.create! :code => code,
                                 :name => name

    end

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

    desc 'Seed data for voting areas'
    task :voting_areas => :environment do
      puts 'Seeding voting areas ...'

      # 2014 Voting Areas
      #raise 'Add passwords and remove this line (production_seed.rake). PS. Plz commit them to github too, ok!'
      create_voting_area :code => 'I', :name => 'Unicafe Ylioppilasaukio', :password => 'salainensana'
      create_voting_area :code => 'II', :name => 'Yliopiston päärakennus', :password => 'salainensana'
      create_voting_area :code => 'III', :name => 'Porthania', :password => 'salainensana'
      create_voting_area :code => 'IV', :name => 'Metsätalo', :password => 'salainensana'
      create_voting_area :code => 'V', :name => 'Kaisa-talo', :password => 'salainensana'
      create_voting_area :code => 'VI', :name => 'Oppimiskeskus Minerva', :password => 'salainensana'
      create_voting_area :code => 'VII', :name => 'Terveystieteiden keskuskirjasto', :password => 'salainensana'
      create_voting_area :code => 'VIII', :name => 'Hammaslääketieteen laitos', :password => 'salainensana'
      create_voting_area :code => 'IX', :name => 'Physicum', :password => 'salainensana'
      create_voting_area :code => 'X', :name => 'Exactum', :password => 'salainensana'
      create_voting_area :code => 'XI', :name => 'Infokeskus', :password => 'salainensana'
      create_voting_area :code => 'XII', :name => 'EE-talo', :password => 'salainensana'
      create_voting_area :code => 'XIII', :name => 'Ympäristöekologian laitos', :password => 'salainensana'
      create_voting_area :code => 'XIV', :name => 'Vaasan yliopisto', :password => 'salainensana'

      create_voting_area :code => 'EI', :name => 'Keskustakampus, Porthania', :password => 'salainensana'
      create_voting_area :code => 'EII', :name => 'Viikin kampus, Infokeskus', :password => 'salainensana'
      create_voting_area :code => 'EIII', :name => 'Kumpulan kampus, Physicum', :password => 'salainensana'
      create_voting_area :code => 'EIV', :name => 'Meilahden kampus, Terveystieteiden keskuskirjasto', :password => 'salainensana'
      create_voting_area :code => 'EV', :name => 'Kaisa-talo', :password => 'salainensana'
    end

    desc 'Setup production configuration defaults'
    task :configuration => :environment do
      conf = GlobalConfiguration.new
      conf.candidate_nomination_ends_at = Time.new(2014, "sep", 29, 12, 00)  # 29.9.2014 klo 12.00 UTC+3
      conf.candidate_data_is_freezed_at = Time.new(2014, "oct", 8, 12, 00)   # KVL 8.10.2014 klo 12.00 UTC+3
      conf.save!

      # Sends password by mail
      AdminUser.create!(:email => 'petrus.repo+vaalit@enemy.fi', :password => 'salainensana', :password_confirmation => 'salainensana')
    end
  end

  desc 'Seed initial production data (required for deployment!)'
  task :production do
    Rake::Task['seed:production:faculties'].invoke
    Rake::Task['seed:production:voting_areas'].invoke
    Rake::Task['seed:production:configuration'].invoke
  end

end
