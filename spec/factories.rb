FactoryGirl.define do
  factory :admin_user do
    email { 'user@example.com' }
  end

  factory :faculty do
    sequence(:name) {|n| "Faculty #{n}"}
    sequence(:code) {|n| "F#{n}"}
  end

  factory :electoral_coalition do
    sequence(:name) {|n| "Coalition #{n}"}
    sequence(:shorten) {|n| "c #{n}"}
    sequence(:numbering_order) {|n| n + 1}
  end

  factory :electoral_alliance do
    sequence(:name) {|n| "Alliance #{n}"}
    sequence(:shorten) {|n| "a #{n}"}
    expected_candidate_count { 2 }
    secretarial_freeze { true }
    electoral_coalition
  end

  factory :candidate do
    sequence(:email) {|n| "matti.meikalainen.#{n}@example.com"}
    sequence(:lastname) {|n| "Meikalainen #{n}"}
    sequence(:firstname) {|n| "Matti #{n} Sakari"}
    sequence(:candidate_name) {|n| "Meikalainen, Matti Sakari #{n}"}
    social_security_number { 'sec id' }
    faculty
    electoral_alliance
  end

  factory :voting_area do
    sequence(:code) {|n| "VA#{n}"}
    sequence(:name) {|n| "Voting area #{n}"}
    ready { true }
    submitted { true }
  end

  factory :vote do
    voting_area
    candidate
    sequence(:amount) { |n| n + 10 }
  end

  factory :result do
  end

  factory :coalition_result do
    result
    electoral_coalition
    sequence(:vote_sum_cache) { |n| n + 100 }
  end

  factory :alliance_result do
    result
    electoral_alliance
    sequence(:vote_sum_cache) { |n| n + 10 }
  end

  factory :candidate_result do
    result
    candidate
    sequence(:vote_sum_cache) { |n| n + 10 }

    trait :with_alliance_proportional do
      after(:create) do |candidate_result, _evaluator|
        create :ordered_alliance_proportional,
               :result => candidate_result.result,
               :candidate => candidate_result.candidate
      end
    end

    trait :with_coalition_proportional do
      after(:create) do |candidate_result, _evaluator|
        create :ordered_coalition_proportional,
               :result => candidate_result.result,
               :candidate => candidate_result.candidate
      end
    end
  end

  factory :draw_candidate_result, :class => CandidateResult do
    electoral_alliance_id { '1' }
    vote_sum_cache { '10' }
  end

  factory :coalition_proportional do
    number { (rand * rand(100)).to_f }
    result
    candidate
  end

  factory :alliance_proportional do
    number { (rand * rand(100)).to_f }
    result
    candidate
  end

  factory :ordered_alliance_proportional, :class => AllianceProportional do
    sequence(:number) { |n| (n * 10).to_f }
    result
    candidate
  end

  factory :ordered_coalition_proportional, :class => CoalitionProportional do
    sequence(:number) { |n| (n * 10).to_f }
    result
    candidate
  end

  factory :ready_voting_area, :parent => :voting_area do |area|
    area.ready { true }
  end

  factory :ready_voting_area_with_votes_for, :parent => :ready_voting_area do |area|
    area.after(:create) { create(:vote, :candidate => candidate, :amount => amount) }
  end

  factory :unready_voting_area, :parent => :voting_area do |area|
    area.ready { false }
  end

  factory :voted_candidate, :parent => :candidate do |candidate|
    candidate.after(:create) { |c| create(:vote, :candidate => c, :amount => 1234) }
  end

  factory :result_with_alliance_proportionals_and_candidates, :parent => :result do |result|
    result.after(:create) do |r|
      create_list(:candidate_result, 10, :with_alliance_proportional, :result => r)
    end
  end

  factory :result_with_coalition_proportionals_and_candidates, :parent => :result do |result|
    result.after(:create) do |r|
      create_list :candidate_result, 10, :with_alliance_proportional, :with_coalition_proportional, :result => r
    end
  end

  factory :electoral_alliance_with_candidates, :parent => :electoral_alliance do |alliance|
    alliance.after(:create) do |a|
      10.times do
        a.candidates << create(:candidate, :electoral_alliance => a)
      end
    end
  end

  factory :electoral_coalition_with_alliances_and_candidates, :parent => :electoral_coalition do |coalition|
    coalition.after(:create) do |c|
      10.times do
        c.electoral_alliances << create(:electoral_alliance_with_candidates, :electoral_coalition => c)
      end
    end
  end
end
