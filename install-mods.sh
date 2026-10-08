#!/bin/bash
set -euo pipefail

MOD_MANAGEMENT=${MOD_MANAGEMENT:-0}
VANILLA_MODE=${VANILLA_MODE:-0}
FICSIT_PROFILE_NAME=${FICSIT_PROFILE_NAME:-Default}

echo -e "Mod manager script is now running. Mod management is \033[1m $([[ ${MOD_MANAGEMENT} -eq 1 ]] && echo -e "\033[38;5;10m*ENABLED*" || echo -e "\033[38;5;196m*DISABLED*") \033[0mby the MOD_MANAGEMENT server variable."
echo -e "Vanilla mode is \033[1m $([[ ${VANILLA_MODE} -eq 1 ]] && echo -e "\033[38;5;10m*ENABLED*" || echo -e "\033[38;5;196m*DISABLED*") \033[0mby the VANILLA_MODE server variable."

if [[ "${MOD_MANAGEMENT}" -eq 0 ]]; then
	echo -e "\nMOD_MANAGEMENT server variable is set to '0' (false), the mod installer will exit and the server will be started as is."
	echo "If you really meant to force the server to launch without mods, you should set **both** MOD_MANAGEMENT and VANILLA_MODE to '1' (true)."
	exit 0
fi

GAME_DIR="/home/container"
FICSIT_DIR="${GAME_DIR}/Ficsit"
FICSIT_FLAGS="--local-dir ${GAME_DIR}/Ficsit --cache-dir $GAME_DIR/Ficsit/cache"
FICSIT_LOCK_FILE="${GAME_DIR}/FactoryGame/Mods/*-lock.json"

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

if [[ "${MOD_MANAGEMENT}" -eq 1 ]]; then
	if [[ -f "${FICSIT_LOCK_FILE}" ]]; then
		echo -e "\nRemoving old ficsit lock file '${FICSIT_LOCK_FILE}' if present..."
		rm "${FICSIT_LOCK_FILE}"
	fi
	
	if [[ -f "${FICSIT_DIR}/smm.json" ]]; then
		echo -e "\n'${FICSIT_DIR}/smm.json' detected, converting SMM mods profile into ficsit-cli format..."
		jq --arg profile_name "$FICSIT_PROFILE_NAME" '{
  profiles: {
    ($profile_name): {
      mods: .profile.mods,
      name: $profile_name,
      required_targets: null
    }
  },
  selected_profile: $profile_name,
  version: 0
}' ${FICSIT_DIR}/smm.json > ${FICSIT_DIR}/profiles.json

		echo "Mod profile has been successfully imported from '${FICSIT_DIR}/smm.json', attempting to dele the source file..."
		rm -f ${FICSIT_DIR}/smm.json
		echo "Only reupload '${FICSIT_DIR}/smm.json' if you actually changed something (e.g. added/removed a mod)."
	else
		echo -e "\n[OPTIONAL] SMM profile '${FICSIT_DIR}/smm.json' is not present."
		echo "[OPTIONAL] If you need to import the profile from SMM, please export your profile as 'smm.json' then upload it to the 'Ficsit' directory via the 'Files' panel or SFTP."
		echo -e "\n[OPTIONAL] In case you already have a 'profiles.json' file, you may upload it to the '${FICSIT_DIR}' directory and restart the game server. Make sure that the profile name in 'profiles.json' matches the value of the FICSIT_PROFILE_NAME server variable."
		echo "[OPTIONAL] Copying lock files is not required. Lock files will be deleted at every server launch during the mod update attempt."

		if [[ "${VANILLA_MODE}" -eq 1 ]]; then
			echo -e "\nSetting vanilla mode..."
			${FICSIT_DIR}/ficsit installation set-vanilla ${GAME_DIR} ${FICSIT_FLAGS}
		else
			echo -e "\nEnabling mods..."
			${FICSIT_DIR}/ficsit installation set-vanilla ${GAME_DIR} --off ${FICSIT_FLAGS}
			${FICSIT_DIR}/ficsit installation set-profile ${GAME_DIR} ${FICSIT_PROFILE_NAME} ${FICSIT_FLAGS}
		fi
	fi
else
	exit 0
fi

echo -e "\nApplying mod changes..."
${FICSIT_DIR}/ficsit apply ${GAME_DIR} ${FICSIT_FLAGS}

echo -e "\nficsit-cli has been successfully installed and ran!\n"

