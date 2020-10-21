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
rspec
rake db:seed:demo
```

Käynnistä vaalitulostin:
```bash
foreman run worker
rails s
tail -f log/development.log
```

Käynnistä voting-apin web ja worker (ks. ohjeet voting-api/README).

Avaa http://127.0.0.1:3001/
* admin@example.com / pass123
* "Failed to open TCP connection to localhost:3000" tarkoittaa ettei voting-api ole käynnissä.

Hae äänet Voting API:lta ja laske vaalitulos:
```ruby
Delayed::Job::enqueue(ImportVotesJob.new(VotingArea.first))
```

`ImportVotesJob` käynnistää myös tuloksen laskennan.


Kun lähetät sisäänkirjautumislinkin, voting-apin workerin pitää olla käynnissä
saadaksesi siitä sähköpostin. Voit tarkistaa sisäänkirjautumislinkin tiedot
ajamalla seuraavan komennon voting-api:n hakemistossa:
```bash
 rake jwt:voter:verify jwt=EMAIL_LINKISSÄ_OLEVA_TOKEN
```

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

# Heroku-ympäristön pystyttäminen

Pystytä ensin voting-api.

Nollaa aiempi tietokanta poistamalla Heroku Postgres addon ja lisäämällä se uudelleen.
* Testailussa voi käyttää ilmaista Postgres addonia, mutta se menee lukkoon jos tietokantaan syöttää
  yli 10 000 riviä (kokonaisen testiajon kaikki äänet).
* Tuotantoa varten valitse maksullinen Postgres Hobby $9/kk.

Alusta tietokanta:
* `rake db:schema:load`

Luo äänestysalue ja tiedekunnat:
* `rake db:seed:production`

Lataa Seed-data Ehdokasjärjestelmän tiedoilla:
* Valitse Ehdokasjärjestelmän admin-käyttöliittymästä csv-export kullekin resurssille.
* Kun sinulla on candidates.csv, alliances.csv ja coalitions.csv, suorita:
  - `rake db:seed:edari`

* Luo admin-käyttäjä vaalityöntekijälle:
AdminUser.create!(:email => 'admin@example.com', :password => 'pass123', :password_confirmation => 'pass123')

Admin-käyttäjiä voi lisätä järjestelmään äänioikeutettuja, kun äänestys on käynnissä.
* Äänestyksen aikana lisätty äänioikeutettu voi kirjautua yliopiston käyttäjätunnuksella.
* Jos äänioikeutetulla ei vielä ole yliopiston käyttäjätunnusta, Admin-käyttöliittymästä voi
  lähettää hänelle sähköpostitse sisäänkirjautumislinkin.
* Linkin käyttäjää ei vahvisteta muuten kuin tarkistamalla, että linkki on yhä voimassa.
* Linkin voimassaolo määritetään voting-api:n `EMAIL_LINK_JWT_EXPIRY_MINUTES` asetuksessa.


## AWS S3

Vaalitulostin kirjoittaa lasketun vaalituloksen AWS S3:een.

AWS IAM -käyttöoikeudet antavat kirjoitusoikeuden vuosiluvun mukaiseen hakemistoon:
  * `vaalitulostin-YMPÄRISTÖ/vuosiluku`
  * esimerkiksi `vaalitulostin-qa/2020`

Päivitä jokaisen ympäristön (prod, qa, test) IAM-rooliin oikean vuosiluvun hakemisto.
  * Avaa IAM > Users > Permissions

Luo jokaisen ympäristön S3 Buckettiin vuosiluvun mukainen hakemisto AWS web-käyttöliittymästä.
  * IAM-käyttäjällä ei ole oikeutta luoda uusia hakemistoja.

Testaa S3-kirjoitusoikeus:
  * `S3Publisher.new.test_list_objects`
  * `S3Publisher.new.test_write`
  * Jos S3-kirjoitus onnistuu, aikaleima päivittyy tiedostoon (esim qa-bucketissa)
  https://s3.amazonaws.com/vaalitulostin-qa/VUOSILUKU/lulz.txt
