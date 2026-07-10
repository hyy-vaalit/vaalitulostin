# Election-night sanity limits. The delayed_job defaults are
# max_attempts = 25 (exponential backoff spanning ~3 weeks) and
# max_run_time = 4 hours - a single misbehaving job would occupy the
# only worker and spam Rollbar for weeks. Jobs whose failures are
# permanent (violated preconditions) define max_attempts = 1 themselves.
Delayed::Worker.max_attempts = 5
Delayed::Worker.max_run_time = 30.minutes
