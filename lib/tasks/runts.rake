desc 'Reset development environment as in destroy and recreate everything.'
namespace :db do
  task :runts do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:schema:load'].invoke

    puts "Next:"
    puts "  rake db:seed:demo && rake db:seed:development:internet_votes_2009"
  end
end
