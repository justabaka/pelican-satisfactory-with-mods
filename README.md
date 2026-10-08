# Satisfactory with Mods for Pelican/Pterodactyl
The changes are minimal: it's still a standard `steamcmd` yolk that also uses the well-known [ficsit-cli](https://github.com/satisfactorymodding/ficsit-cli) tool to manage mods.


## Installation

### Manual installation
1. Replace the docker image in the Egg specification with `ghcr.io/justabaka/pelican-satisfactory-with-mods:latest`.
   Note: you still need to make changes to existing servers.
2. Add the following egg/server variables:
   1. `MOD_MANAGEMENT`:
      Type ("rules"): `boolean`.
      Default value: totally up to you. `1` means "enabled", and `0` means "disabled, leave the game as is". Both modes are fully reversible unless you manually delete `profiles.json` that stores your lists of mods.
      If not set, the mod installer defaults to `0` and makes no changes even if `VANILLA_MODE` is enabled.
   2. `VANILLA_MODE`:
      Type: `boolean`.
      Default value: `0`.
      If not set, the mod installer defaults to `0` and does not enforce the vanilla game mode. Does not work when `MOD_MANAGEMENT` is disabled. This is also a reversible action unless you manually delete `profiles.json`.
   2. `FICSIT_PROFILE_NAME`
      Type: `string`.
      Default value: `Default`.
      The only time this variable's value does really matter is when you are reusing `profiles.json` with a non-default profile name. `smm.json` profile name is ignored and rewritten using this value during import.
3. Restart the server. A `Ficsit` directory will be created in the server files and ficsit-cli will be installed inside of it.
   If you already have a `profiles.json` file, you may copy it to the `Ficsit` directory, just make sure that the profile name inside the file matches the `FICSIT_PROFILE_NAME`.
4. [OPTIONAL] Upload your SMM profile to the `Ficsit` directory as file named `smm.json` in order for the script to be able to convert it to ficsit-cli's format. `smm.json` will be deleted automatically after conversion.
5. You're done! On next server (re)start mods will be installed automatically.

### Custom egg
Available [here](egg/). Tested on [Pelican](https://pelican.dev/) only. May or may not require slight modification in order to work with [Pterodactyl](https://pterodactyl.io/).

