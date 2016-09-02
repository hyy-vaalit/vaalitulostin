# Sähköisen äänestämisen tuloslaskentapalvelu

Palvelu on irroitettu [ehdokastietojärjestelmästä](https://github.com/hyy-vaalit/ehdokastiedot)
itsenäiseksi osaksi palvelemaan sähköistä äänestämistä.

## Päivitä koodimuutokset ehdokastietojärjestelmästä

```bash
git remote add ehdokastiedot git@github.com:hyy-vaalit/ehdokastiedot.git
git fetch ehdokastiedot
git diff ehdokastiedot/master..master
git merge --no-ff ehdokastiedot/master

# Resolve conflicts usually in favor of local changes
git mergetool
```

# Testiajo

```bash
rake db:runts
rake db:seed:dev
rake jobs:work
tail -f log/development.log
```bash

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
