require 'support/psql'

module Seed
  class BaseData
    def self.create!
      %w[
        electoral_coalitions
        electoral_alliances
        candidates
        global_configurations
        voting_areas
        votes
      ].each do |name|
        import! csv(name)
      end
    end

    def self.import!(filename:, table_name:)
      Support::Psql.import_csv!(
        db_name: ActiveRecord::Base.configurations["test"]["database"],
        filename: filename,
        table_name: table_name
      )
    end

    private_class_method def self.csv(name)
      {
        table_name: name,
        filename: File.join(__dir__, "2009/#{name}.csv")
      }
    end
  end
end
