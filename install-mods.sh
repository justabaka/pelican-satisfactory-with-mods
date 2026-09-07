#!/bin/bash
set -euo pipefail

ENABLE_MODS=${ENABLE_MODS:-0}
echo -e "Mod manager script is now running. Mods are set to be\033[1m $([[ ${ENABLE_MODS} -eq 1 ]] && echo -e "\033[38;5;10m*ENABLED*" || echo -e "\033[38;5;196m*DISABLED*") \033[0mby the ENABLE_MODS server variable."

GAME_DIR="/home/container"
FICSIT_DIR="${GAME_DIR}/Ficsit"
FICSIT_FLAGS="--local-dir ${GAME_DIR}/Ficsit --cache-dir $GAME_DIR/Ficsit/cache"
FICSIT_LOCK_FILE="${GAME_DIR}/FactoryGame/Mods/default-lock.json"

echo -e "\nDownloading ficsit-cli..."
mkdir -p ${FICSIT_DIR}
wget -q --show-progress -O ${FICSIT_DIR}/ficsit https://github.com/satisfactorymodding/ficsit-cli/releases/latest/download/ficsit_linux_amd64
chmod 0755 ${FICSIT_DIR}/ficsit

echo -e "\nAdding Satisfactory installation to ficsit-cli..."
if [[ ! -f "${FICSIT_DIR}/installations.json" ]]; then
	${FICSIT_DIR}/ficsit installation add ${GAME_DIR} ${FICSIT_FLAGS}
else
	echo "Installation file 'Ficsit/installations.json' has been detected, skipping..."
	echo "If you are sure it's a mistake, please manually delete the aforementioned file via the 'Files' panel or SFTP."
fi

if [[ "${ENABLE_MODS}" -eq 1 ]]; then
	if [[ -f "${FICSIT_LOCK_FILE}" ]]; then
		echo -e "\nRemoving old ficsit lock file '${FICSIT_LOCK_FILE}' if present..."
		rm "${FICSIT_LOCK_FILE}"
	fi
	
	if [[ -f "${FICSIT_DIR}/smm.json" ]]; then
		echo -e "\n'${FICSIT_DIR}/smm.json' detected, converting SMM mods profile into ficsit-cli format..."
		jq '{
  profiles: {
    Default: {
      mods: .profile.mods,
      name: "Default",
      required_targets: null
    }
  },
  selected_profile: "Default",
  version: 0
}' ${FICSIT_DIR}/smm.json > ${FICSIT_DIR}/profiles.json

		echo "Mod profile has been successfully imported from '${FICSIT_DIR}/smm.json', attempting to dele the source file..."
		rm -f ${FICSIT_DIR}/smm.json
		echo "Only reupload '${FICSIT_DIR}/smm.json' if you actually changed something (e.g. added/removed a mod)."
	else
		echo "[OPTIONAL] SMM profile '${FICSIT_DIR}/smm.json' is not present."
		echo "[OPTIONAL] If you need to import the profile from SMM, please export your profile as 'smm.json' then upload it to the 'Ficsit' directory via the 'Files' panel or SFTP."
		echo -e "\n[OPTIONAL] In case you already have a 'profiles.json' file, you may copy it to the '${FICSIT_DIR}' directory and restart the game server. Make sure that the profile is named 'Default' in 'profiles.json'."
		echo "[OPTIONAL] Copying lock files is not required. Lock files will be deleted at every server launch during the mod update attempt."

		echo -e "\nEnabling mods..."
		${FICSIT_DIR}/ficsit installation set-vanilla ${GAME_DIR} --off ${FICSIT_FLAGS}
		${FICSIT_DIR}/ficsit installation set-profile ${GAME_DIR} Default ${FICSIT_FLAGS}
	fi
else
	echo -e "\nDisabling mods..."
	${FICSIT_DIR}/ficsit installation set-vanilla ${GAME_DIR} ${FICSIT_FLAGS}
fi

echo -e "\nApplying mod changes..."
${FICSIT_DIR}/ficsit apply ${GAME_DIR} ${FICSIT_FLAGS}

echo -e "\nficsit-cli has been successfully installed and ran!\n"

