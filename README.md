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
