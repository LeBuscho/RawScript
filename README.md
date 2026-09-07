# CoolStudios Script Host

Statische Website für GitHub Pages. Du kannst Lua-Scripts anlegen, bearbeiten und löschen. Jedes Script wird als echte Datei unter `/scripts/name.lua` in dieses Repository geschrieben.

Dadurch funktionieren direkte Links wie:

`https://DEIN-USERNAME.github.io/DEIN-REPO/scripts/bodensee-v3-by-coolstudios.lua`

Zusätzlich gibt es immer den Raw-Link von GitHub, der den reinen Lua-Text zurückgibt.

## Inhalt

- `index.html` – Oberfläche
- `css/style.css` – Design
- `js/app.js` – Editor und Verwaltung
- `js/github.js` – Speichern über die GitHub-API
- `scripts/` – hier landen die fertigen `.lua`-Dateien

## 1. Neues GitHub-Repository anlegen

1. Auf [github.com/new](https://github.com/new) gehen.
2. Repository-Name wählen, z. B. `script-host`.
3. Öffentlich lassen, wenn die Scripts öffentlich erreichbar sein sollen.
4. **Nicht** „Add a README“ aktivieren, wenn du die Dateien aus diesem Ordner als ersten Commit hochladen willst. Ein leeres Repo ist am einfachsten.

## 2. Dateien hochladen

Variante A – GitHub-Weboberfläche:

1. Im neuen Repo auf **uploading an existing file** klicken.
2. Alle Dateien und Ordner aus diesem Projekt hochladen (`index.html`, `css`, `js`, `scripts`, `.nojekyll`, `README.md`).
3. Committen auf den Branch `main`.

Variante B – Git:

```bash
git init
git add .
git commit -m "Initial script host"
git branch -M main
git remote add origin https://github.com/DEIN-USERNAME/script-host.git
git push -u origin main
```

## 3. GitHub Pages einschalten

1. Im Repository: **Settings → Pages**.
2. Source: **Deploy from a branch**.
3. Branch: `main`, Ordner: `/ (root)`.
4. Speichern.
5. Nach 1–2 Minuten ist die Seite erreichbar unter:

`https://DEIN-USERNAME.github.io/script-host/`

Falls das Repository genau so heißt wie dein Benutzername (`username.github.io`), lautet die URL nur `https://username.github.io/`.

## 4. Personal Access Token erzeugen

Die Website braucht einen Token, um Dateien in `/scripts` anzulegen oder zu ändern.

1. GitHub → Profilbild → **Settings**.
2. Ganz unten **Developer settings**.
3. **Personal access tokens → Fine-grained tokens → Generate new token**.
4. Name z. B. `script-host`.
5. Repository access: **Only select repositories** → genau dieses Repo wählen.
6. Permissions:
   - **Contents**: Read and write
   - Rest auf No access lassen
7. Token erzeugen und sicher kopieren. Er wird nur einmal vollständig angezeigt.

Wichtig: Der Token bleibt nur in deinem Browser (localStorage). Teile ihn mit niemandem.

## 5. Website mit dem Repository verbinden

1. Die GitHub-Pages-URL öffnen.
2. Auf **Einstellungen** klicken.
3. Eintragen:
   - GitHub-Benutzername
   - Repository-Name
   - Branch (meist `main`)
   - Personal Access Token
   - Pages-Basis-URL, z. B. `https://DEIN-USERNAME.github.io/script-host`
4. Speichern.

## 6. Script erstellen

1. Titel eingeben, z. B. `BodenSee V3 by CoolStudios`.
2. Lua-Code in den Editor einfügen.
3. **Script erstellen / speichern** klicken.
4. Die Website schreibt `scripts/bodensee-v3-by-coolstudios.lua` ins Repository.
5. Danach siehst du:
   - Pages-URL
   - Raw-Link
   - fertige Ladezeile

Beispiel-Ladezeile:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/DEIN-USERNAME/script-host/main/scripts/bodensee-v3-by-coolstudios.lua"))()
```

Der Raw-Link liefert den Lua-Code als Klartext. Die Pages-URL tut das ebenfalls, sobald Pages das File ausliefert.

## 7. Bearbeiten und löschen

- Links in der Script-Verwaltung ein Script anklicken.
- Titel oder Code ändern und speichern.
- **Löschen** entfernt die Datei aus dem Repository.

Wenn du den Titel so änderst, dass ein neuer Slug entsteht, wird eine neue Datei erzeugt. Die alte Datei kannst du danach manuell löschen.

## Hinweise

- GitHub Pages ist kostenlos für öffentliche Repositories.
- Nach dem Speichern kann es ein paar Sekunden dauern, bis der Raw-Link den neuen Inhalt zeigt.
- Der Token gilt nur für das ausgewählte Repository.
- Nutze den Host nur für Scripts, die du selbst geschrieben hast und die du teilen darfst.
