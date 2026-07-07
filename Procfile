web: bundle exec puma -C config/puma.rb
# NOTE: exactly ONE worker. Job ordering between import/publish/create-result
# jobs relies on a single delayed_job worker; scaling this up requires adding
# locking in many places.
worker:  bundle exec rake jobs:work
