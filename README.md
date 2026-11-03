# companion-modules

An optional offline bundle of Nige's Bitfocus Companion modules. Each module lives, builds and downloads on its
own; this repo only builds them together, for installing everything on a rig in one go.

| Module | Repo |
| --- | --- |
| Intech Studio Grid surface | [companion-surface-intech-grid](https://github.com/nisted/companion-surface-intech-grid) |
| Logitech MX Creative Dialpad surface | [companion-surface-logitech-mx-dialpad](https://github.com/nisted/companion-surface-logitech-mx-dialpad) |
| Allen & Heath SQ with Grid fader additions | [companion-module-allenheath-sq, `grid` branch](https://github.com/nisted/companion-module-allenheath-sq/tree/grid) |

## Downloads

The Build workflow publishes two artifacts on every push (and attaches them to a release for `v*` tags):

- **companion-nige-modules**: each module as its own `.tgz`. In Companion: Modules → **Import module package**,
  one at a time.
- **companion-nige-modules-bundle**: one `.tgz` with every module. In Companion: Modules → **Import offline module
  bundle**. Companion installs each module version it doesn't already have and skips ones it does.

Use the bundle with **Import offline module bundle** only. Given to **Import module package**, Companion rejects it
with "Doesn't look like a valid module, missing manifest", because that option expects a single module.

## Adding a module

Add its public repo and branch as a line in `bundle-modules.txt`.

## Rebel Watch 🍹

Some of the crew are **rebels**: tweaked versions of someone else's module (listed in `rebels.json`). Every morning, Rebel Watch (`.github/workflows/rebel-watch.yml`) checks each original module for a new release. When one turns up, it merges the new version into the rebel on a fresh `rebel-watch/<version>` branch in the rebel's repo, and:

- **merges cleanly:** opens a pull request there, so the build runs and you get an email
- **clashes:** opens an issue listing the clashing files, so it can be ported by hand

It remembers what it has already seen in `rebel-state.json`. Run it any time from **Actions → Rebel Watch → Run workflow**.

### The one-off token

Rebel Watch needs a GitHub token that can write to the rebel repos:

1. GitHub → **Settings → Developer settings → Personal access tokens → Fine-grained tokens → Generate new token**.
2. Name it `rebel-watch`, and pick an expiry.
3. **Repository access:** *Only select repositories* → every repo named in `rebels.json`.
4. **Permissions:** *Contents*, *Pull requests* and *Issues*, all **Read and write**.
5. Copy the token, then in this repo: **Settings → Secrets and variables → Actions → New repository secret**, named `REBEL_WATCH_TOKEN`.

To add a rebel, add it to `rebels.json` (and its repo to the token).
