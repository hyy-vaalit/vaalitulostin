# Sähköisen äänestämisen tuloslaskentapalvelu

Palvelu on irroitettu [ehdokastietojärjestelmästä](https://github.com/hyy-vaalit/ehdokastiedot)
itsenäiseksi osaksi palvelemaan sähköistä äänestämistä.


# Käyttäjätyypit

Järjestelmässä on ainoastaan yksi käyttäjätyyppi: AdminUser.
Pääsyoikeustasot on määritetty tiedostossa `app/models/ability.rb`.

* Pääkäyttäjä AdminUser
  - `app/models/admin_user.rb`
  - Täysi oikeus kaikkeen.


# Testiajo

```bash
rake db:runts
rake db:seed:dev
rake jobs:work
tail -f log/development.log
```

Hae äänet Voting API:lta ja laske vaalitulos:
```ruby
Delayed::Job::enqueue(ImportVotesJob.new(VotingArea.first))
```

`ImportVotesJob` käynnistää myös tuloksen laskennan.


## Vuoden 2009 äänillä
Syötä äänet seed-datasta käyttäen vain yhtä äänestysaluetta:
```bash
rake db:seed:development:internet_votes_2009
```

Syötä äänet seed-datasta vuoden 2009 äänestysalueille:
```bash
rake db:seed:development:voting_areas_2009
rake db:seed:development:votes_2009
```

Laita jonoon tuloksen laskentatyö:
```ruby
VotingArea.all.each { |a| a.ready!; a.submitted! }
Delayed::Job.enqueue(CreateResultJob.new)
```

Tulosta konsoliin:
```ruby
puts ResultDecorator.decorate(Result.last).to_html
```

Merkitse tulos valmiiksi arvontoja varten:
```ruby
Result.freeze_for_draws!
```

## Seed-data Ehdokasjärjestelmän tiedoilla

See also README of voting-api.

- `rake db:seed:production`
- `rake db:seed:edari`

* Testaa S3-kirjoitusoikeus:
`S3Publisher.new.test_connection`

* Luo admin-käyttäjä vaalityöntekijälle:
AdminUser.create!(:email => 'admin@example.com', :password => 'pass123', :password_confirmation => 'pass123')
