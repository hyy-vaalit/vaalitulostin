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

```ruby
Delayed::Job::enqueue(ImportVotesJob.new(VotingArea.first))
puts ResultDecorator.decorate(Result.last).to_html
```
