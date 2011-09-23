FactoryGirl.define do

  factory :admin_user do
    email 'user@example.com'
  end

  factory :faculty do
    sequence(:name) {|n| "Faculty #{n}"}
    sequence(:code) {|n| "F#{n}"}
  end

  factory :electoral_coalition do
    sequence(:name) {|n| "Coalition #{n}"}
    sequence(:shorten) {|n| "c #{n}"}
    sequence(:number_order) {|n| n+1}
  end

  factory :electoral_alliance do
    sequence(:name) {|n| "Alliance #{n}"}
    sequence(:shorten) {|n| "a #{n}"}
    delivered_candidate_form_amount 2
    secretarial_freeze true
    electoral_coalition
    primary_advocate_lastname 'First last'
    primary_advocate_firstname 'First first'
    primary_advocate_social_security_number 'First ssn'
    primary_advocate_address 'First address'
    primary_advocate_postal_information 'First postal'
    primary_advocate_phone 'First phone'
    primary_advocate_email 'First email'
    secondary_advocate_lastname 'Second last'
    secondary_advocate_firstname 'Second first'
    secondary_advocate_social_security_number 'Second ssn'
    secondary_advocate_address 'Second address'
    secondary_advocate_postal_information 'Second postal'
    secondary_advocate_phone 'Second phone'
    secondary_advocate_email 'Second email'
  end

  factory :candidate do
    sequence(:email) {|n| "foo#{n}@example.com"}
    lastname 'Meikalainen'
    firstname 'Matti Sakari'
    candidate_name 'Meikalainen, Matti Sakari'
    social_security_number 'sec id'
    faculty
    electoral_alliance
  end

  factory :voting_area do
    sequence(:code) {|n| "VA#{n}"}
    sequence(:name) {|n| "Voting area #{n}"}
    ready true
    taken true
    password 'foobar123'
  end

  factory :vote do
    voting_area
    candidate
    amount { rand(200) }
  end

  factory :ready_voting_area, :parent => :voting_area do |area|
    area.ready { true }
  end

  factory :ready_voting_area_with_votes_for, :parent => :ready_voting_area do |area|
    area.after_create { |a| Factory(:vote, :candidate => candidate, :amount => amount)}
  end

  factory :unready_voting_area, :parent => :voting_area do |area|
    area.ready { false }
  end

  factory :voted_candidate, :parent => :candidate do |candidate|
    candidate.after_create { |c| Factory(:vote, :candidate => c, :amount => 1234) }
  end

  factory :electoral_alliance_with_candidates, :parent => :electoral_alliance do |alliance|
    alliance.after_create { |a| 3.times { a.candidates << Factory(:candidate, :electoral_alliance => a) } }
  end

  factory :electoral_coalition_with_alliances, :parent => :electoral_coalition do |coalition|
    coalition.after_create { |c| 3.times { c.electoral_alliances << Factory(:electoral_alliance_with_candidates, :electoral_coalition => c) } }
  end
end
