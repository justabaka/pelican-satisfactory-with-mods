# Satisfactory for Pelican/Pterodactyl that supports mods
The changes are minimal: it's still a standard `steamcmd` yolk that also uses the well-known [ficsit-cli](https://github.com/satisfactorymodding/ficsit-cli) tool to manage mods.
Mods are installed/updated/disabled/removed automatically based on the environment variable settings and ficsit-cli's profile file.
It is possible to import mods from [Satisfactory Mod Manager](https://docs.ficsit.app/satisfactory-modding/latest/ForUsers/SatisfactoryModManager.html).

## Installation

### Manual installation
1. Replace the docker image in the Egg specification with `ghcr.io/justabaka/pelican-satisfactory-with-mods:latest`.
   Note: you still need to make changes to existing servers.
2. Add a `ENABLE_MODS` boolean and set it to 1 (mods enabled). If it is set to 0, it will switch the game to vanilla state. Both actions are fully reversible.
3. Restart the server. A `Ficsit` directory will be created in the server files.
4. Upload your SMM profile to the `Ficsit` directory as file named `smm.json` in order for the script to be able to convert it to ficsit-cli's format. `smm.json` will be deleted automatically after conversion.
5. You're done! On next reboot mods will be installed automatically.

### Custom egg
TBD
