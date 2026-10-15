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
