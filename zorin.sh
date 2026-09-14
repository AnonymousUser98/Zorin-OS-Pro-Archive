#!/usr/bin/env bash

set -o pipefail

# Make sure the temp directory gets removed on script exit.
trap 'exit 1' HUP INT PIPE QUIT TERM
trap '
if [ -n "$TEMPD" ]; then
    case "$TEMPD" in
        /tmp/*)
            if command rm -rf "$TEMPD"; then
                echo "Cleaned up temporary directory \"$TEMPD\" successfully!"
            else
                echo "Temp Directory \"$TEMPD\" was not deleted correctly; you need to manually remove it!"
            fi
        ;;
        *)
            echo "Warning: TEMPD=\"$TEMPD\" is outside /tmp/, refusing to delete for safety."
        ;;
    esac
fi
' EXIT

# Check if running on Zorin OS
if ! grep -q "Zorin OS" /etc/os-release; then
	echo "Error: This script only supports Zorin OS."
	exit 1
fi

echo "███████╗ ██████╗ ██████╗ ██╗███╗   ██╗     ██████╗ ███████╗    ██████╗ ██████╗  ██████╗ "
echo "╚══███╔╝██╔═══██╗██╔══██╗██║████╗  ██║    ██╔═══██╗██╔════╝    ██╔══██╗██╔══██╗██╔═══██╗"
echo "  ███╔╝ ██║   ██║██████╔╝██║██╔██╗ ██║    ██║   ██║███████╗    ██████╔╝██████╔╝██║   ██║"
echo " ███╔╝  ██║   ██║██╔══██╗██║██║╚██╗██║    ██║   ██║╚════██║    ██╔═══╝ ██╔══██╗██║   ██║"
echo "███████╗╚██████╔╝██║  ██║██║██║ ╚████║    ╚██████╔╝███████║    ██║     ██║  ██║╚██████╔╝"
echo "╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝     ╚═════╝ ╚══════╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝ "
echo "|ZORIN-OS-PRO| |Script v10.0.1.1| |Overhauled & Maintained By NamelessNanashi/NanashiTheNameless| |original idea by kauancvlcnt|"
echo ""
echo "(Please note this tool ONLY works on ZorinOS 18 Core, ZorinOS 17 Core, and ZorinOS 16 Core)"
echo ""
echo "To use this script on:"
echo "ZorinOS 16 Core use the -6 flag"
echo "ZorinOS 17 Core use the -7 flag"
echo "ZorinOS 18 Core use the -8 flag"
echo ""
echo "If a version flag is not specified the script will try to guess"
echo ""
echo "(add -X for a lot of extra content, Recommended)"
echo "(add -U for unattended mode, Not recommended)"
echo ""
echo "THIS CODE AND THE ACCOMPANYING DOCUMENTATION WERE SIGNIFICANTLY OVERHAULED BY NamelessNanashi/NanashiTheNameless."
echo "https://github.com/NanashiTheNameless/Zorin-OS-Pro IS THE OFFICIAL SOURCE FOR THIS TOOL."
echo "IF YOU GOT THIS CODE ELSEWHERE KNOW THAT THE CODE SHOULD NOT BE FULLY TRUSTED."
echo ""

sleep 8

function fail() {
	echo ""
	echo "You are not running this script correctly, read the GitHub https://github.com/NanashiTheNameless/Zorin-OS-Pro/ for more info"
	echo ""
	exit 1
}

# Parse command line arguments for flag
no_confirm=""
extra="false"
auto_version="false"
while getopts "678XU" opt; do
	case $opt in
		6) version="16" ;;
		7) version="17" ;;
		8) version="18" ;;
		X) extra="true" ;;
		U) no_confirm="-y" ;;
		*) fail ;;
	esac
done

# Automatic version detection if no flag provided
if [ -z ${version+x} ]; then
	if grep -q "Zorin OS" /etc/os-release; then
		version_id=$(grep VERSION_ID /etc/os-release | cut -d '"' -f2 | cut -d '.' -f1)
		case "$version_id" in
			16) version="16" ;;
			17) version="17" ;;
			18) version="18" ;;
			*) fail ;;
		esac
	else
		fail
	fi
	auto_version="true"
fi

if [ "$auto_version" = "true" ]; then
	echo ""
	echo "ZorinOS $version automatically selected. if this is not correct please stop the script with \"CTRL+C\" and re-run the script with the correct version flag."
	echo ""
	sleep 5
fi

echo ""
echo "Preparing to install dependencies..."
echo ""

# Install ca-certificates and curl (not strictly necessary but safe)
if ! sudo apt-get update; then
	echo "Non-Blocking Error: Failed to update apt repositories."
	# This should be non-blocking
fi
if ! sudo apt-get install ${no_confirm} ca-certificates curl equivs; then
	echo "Non-Blocking Error: Failed to install dependencies."
	# This should be non-blocking
fi

echo ""
echo "Done installing dependencies..."
echo ""

echo ""
echo "Updating the default sources.list for Zorin's custom resources..."
echo ""

function AddSources16() {
sudo cp -f /etc/apt/sources.list.d/zorin.list /etc/apt/sources.list.d/zorin.list.bak 2>/dev/null || true
sudo rm -f /etc/apt/sources.list.d/zorin.list
sudo touch /etc/apt/sources.list.d/zorin.list
sudo tee /etc/apt/sources.list.d/zorin.list > /dev/null << 'EOF'
deb https://packages.zorinos.com/stable focal main
deb-src https://packages.zorinos.com/stable focal main

deb https://packages.zorinos.com/patches focal main
deb-src https://packages.zorinos.com/patches focal main

deb https://packages.zorinos.com/apps focal main
deb-src https://packages.zorinos.com/apps focal main

deb https://packages.zorinos.com/drivers focal main restricted
deb-src https://packages.zorinos.com/drivers focal main restricted

deb https://packages.zorinos.com/premium focal main
deb-src https://packages.zorinos.com/premium focal main

EOF
}

function AddSources17() {
sudo cp -f /etc/apt/sources.list.d/zorin.list /etc/apt/sources.list.d/zorin.list.bak 2>/dev/null || true
sudo rm -f /etc/apt/sources.list.d/zorin.list
sudo touch /etc/apt/sources.list.d/zorin.list
sudo tee /etc/apt/sources.list.d/zorin.list > /dev/null << 'EOF'
deb https://packages.zorinos.com/stable jammy main
deb-src https://packages.zorinos.com/stable jammy main

deb https://packages.zorinos.com/patches jammy main
deb-src https://packages.zorinos.com/patches jammy main

deb https://packages.zorinos.com/apps jammy main
deb-src https://packages.zorinos.com/apps jammy main

deb https://packages.zorinos.com/drivers jammy main restricted
deb-src https://packages.zorinos.com/drivers jammy main restricted

deb https://packages.zorinos.com/premium jammy main
deb-src https://packages.zorinos.com/premium jammy main

EOF
}

function AddSources18() {
sudo cp -f /etc/apt/sources.list.d/zorin.list /etc/apt/sources.list.d/zorin.list.bak 2>/dev/null || true
sudo rm -f /etc/apt/sources.list.d/zorin.list
sudo touch /etc/apt/sources.list.d/zorin.list
sudo tee /etc/apt/sources.list.d/zorin.list > /dev/null << 'EOF'
deb https://packages.zorinos.com/stable noble main
deb-src https://packages.zorinos.com/stable noble main

deb https://packages.zorinos.com/patches noble main
deb-src https://packages.zorinos.com/patches noble main

deb https://packages.zorinos.com/apps noble main
deb-src https://packages.zorinos.com/apps noble main

deb https://packages.zorinos.com/drivers noble main restricted
deb-src https://packages.zorinos.com/drivers noble main restricted

deb https://packages.zorinos.com/premium noble main
deb-src https://packages.zorinos.com/premium noble main

EOF
}

if [ "$version" = "16" ]; then
	AddSources16
elif [ "$version" = "17" ]; then
	AddSources17
elif [ "$version" = "18" ]; then
	AddSources18
else
	fail
fi

echo ""
echo "Done updating the default sources.list for Zorin's custom resources..."
echo ""

sleep 2

# Create a temporary directory and store its name in a variable.
TEMPD=$(mktemp -d)

# Exit if the temp directory wasn't created successfully.
if [ ! -e "$TEMPD" ]; then
	>&2 echo "Failed to create temp directory"
	exit 1
fi

# Set permissions of temp directory
# 755 = rwxr-xr-x
# See: https://chmod-calculator.com/
if [ -e "$TEMPD" ]; then
	sudo chmod 755 "$TEMPD"
fi

echo ""
echo "Adding Zorin's Package public gpg keys..."
echo ""

# Helper function to retry apt-get update with backoff
function apt_update_with_retry() {
	local max_attempts=3
	local attempt=1
	local delay=5

	while [ $attempt -le $max_attempts ]; do
		echo "Attempting apt-get update (attempt $attempt/$max_attempts)..."
		if sudo apt-get update ${no_confirm}; then
			return 0
		else
			if [ $attempt -lt $max_attempts ]; then
				echo "apt-get update failed, waiting ${delay}s before retry..."
				sleep $delay
				delay=$((delay * 2))
			fi
			attempt=$((attempt + 1))
		fi
	done
	echo "Warning: apt-get update failed after $max_attempts attempts. Continuing anyway..."
	return 1
}

# Manually add the public gpg keys
if ! curl -L -H 'DNT: 1' -H 'Sec-GPC: 1' https://github.com/NanashiTheNameless/Zorin-OS-Pro/raw/refs/heads/main/raw/zorin-os.gpg --output "$TEMPD/zorin-os.gpg"; then
	echo "Error: Failed to download Zorin OS public gpg key."
	exit 1
fi
if [ ! -s "$TEMPD/zorin-os.gpg" ]; then
	echo "Error: Downloaded Zorin OS public gpg key file is empty or missing."
	exit 1
fi

if [ "$version" = "18" ]; then
	if ! curl -L -H 'DNT: 1' -H 'Sec-GPC: 1' https://github.com/NanashiTheNameless/Zorin-OS-Pro/raw/refs/heads/main/raw/zorin-os-premium-18.gpg --output "$TEMPD/zorin-os-premium-18.gpg"; then
		echo "Error: Failed to download premium public gpg key."
		exit 1
	fi
	if [ ! -s "$TEMPD/zorin-os-premium-18.gpg" ]; then
		echo "Error: Downloaded premium public gpg key file is empty or missing."
		exit 1
	fi

else
	if ! curl -L -H 'DNT: 1' -H 'Sec-GPC: 1' https://github.com/NanashiTheNameless/Zorin-OS-Pro/raw/refs/heads/main/raw/zorin-os-premium.gpg --output "$TEMPD/zorin-os-premium.gpg"; then
		echo "Error: Failed to download premium public gpg key."
		exit 1
	fi
	if [ ! -s "$TEMPD/zorin-os-premium.gpg" ]; then
		echo "Error: Downloaded premium public gpg key file is empty or missing."
		exit 1
	fi
fi

# Fix permissions of manually downloaded public gpg keys
# 644 = -rw-r--r--
# See: https://chmod-calculator.com/
sudo chmod 644 "$TEMPD/zorin-os.gpg"
if [ "$version" = "18" ]; then
	sudo chmod 644 "$TEMPD/zorin-os-premium-18.gpg"
else
	sudo chmod 644 "$TEMPD/zorin-os-premium.gpg"
fi

# Move public gpg keys to trusted.gpg.d
sudo cp --no-clobber "$TEMPD/zorin-os.gpg" "/etc/apt/trusted.gpg.d/zorin-os.gpg" # --no-clobber to avoid overwriting existing keys
if [ "$version" = "18" ]; then
	sudo cp --no-clobber "$TEMPD/zorin-os-premium-18.gpg" "/etc/apt/trusted.gpg.d/zorin-os-premium-18.gpg" # --no-clobber to avoid overwriting existing keys
else
	sudo cp --no-clobber "$TEMPD/zorin-os-premium.gpg" "/etc/apt/trusted.gpg.d/zorin-os-premium.gpg" # --no-clobber to avoid overwriting existing keys
fi

# Fix ownership of public gpg keys
sudo chown root:root /etc/apt/trusted.gpg.d/zorin-os.gpg
if [ "$version" = "18" ]; then
	sudo chown root:root /etc/apt/trusted.gpg.d/zorin-os-premium-18.gpg
else
	sudo chown root:root /etc/apt/trusted.gpg.d/zorin-os-premium.gpg
fi

echo ""
echo "Done adding ZorinOS's Public gpg keys..."
echo ""

echo ""
echo "Adding premium flag..."
echo ""

# Introduce premium user agent
sudo rm -f /etc/apt/apt.conf.d/99zorin-os-premium-user-agent
sudo touch /etc/apt/apt.conf.d/99zorin-os-premium-user-agent
sudo tee /etc/apt/apt.conf.d/99zorin-os-premium-user-agent > /dev/null << 'EOF'
Acquire
{
  http::User-Agent "Zorin OS Premium";
};

EOF

echo ""
echo "Done adding premium flag..."
echo ""

# Update packages with retry logic
if ! apt_update_with_retry; then
	echo "Error: Failed to update apt repositories after adding sources."
	echo "Waiting 10 seconds and trying once more..."
	sleep 10
	if ! apt_update_with_retry; then
		echo "Warning: apt-get update failed. Some packages may not be available."
	fi
fi

# Refresh apt cache to recognize the new keys
echo ""
echo "Refreshing apt cache with new GPG keys..."
echo ""

if ! apt_update_with_retry; then
	echo "Warning: Failed to refresh apt cache after adding keys. Continuing anyway..."
fi

echo ""
echo "Now making and creating & installing dummy debs to satisfy dependencies for zorin-os-premium-keyring (if needed)..."
echo ""

if dpkg -s "zorin-os-premium-keyring" >/dev/null 2>&1; then
	echo ""
	echo "zorin-os-premium-keyring is already installed, skipping dummy deb creation/installation."
	echo ""
else
	if [ "$version" = "18" ]; then
		if ! bash <(curl -H 'DNT: 1' -H 'Sec-GPC: 1' -fsSL https://github.com/NanashiTheNameless/Zorin-OS-Pro/raw/refs/heads/main/make_dummy_deb.sh) -w "$TEMPD/Dummy/" -n zorin-os-premium-keyring -v 1.1 -o "$TEMPD/zorin-os-premium-keyring.deb"; then
			echo "Warning: Failed to create dummy deb for zorin-os-premium-keyring (1.1). Continuing anyway..."
		fi
	else
		if ! bash <(curl -H 'DNT: 1' -H 'Sec-GPC: 1' -fsSL https://github.com/NanashiTheNameless/Zorin-OS-Pro/raw/refs/heads/main/make_dummy_deb.sh) -w "$TEMPD/Dummy/" -n zorin-os-premium-keyring -v 1.0 -o "$TEMPD/zorin-os-premium-keyring.deb"; then
			echo "Warning: Failed to create dummy deb for zorin-os-premium-keyring (1.0). Continuing anyway..."
		fi
	fi
fi

if dpkg -s "zorin-os-keyring" >/dev/null 2>&1; then
	echo ""
	echo "zorin-os-keyring is already installed, skipping dummy deb creation/installation."
	echo ""
else
	if ! bash <(curl -H 'DNT: 1' -H 'Sec-GPC: 1' -fsSL https://github.com/NanashiTheNameless/Zorin-OS-Pro/raw/refs/heads/main/make_dummy_deb.sh) -w "$TEMPD/Dummy/" -n zorin-os-keyring -v 1.1 -o "$TEMPD/zorin-os-keyring.deb"; then
		echo "Warning: Failed to create dummy deb for zorin-os-keyring. Continuing anyway..."
	fi
fi

# Fix permissions of dummy debs if they exist
# 755 = rwxr-xr-x
# See: https://chmod-calculator.com/
if [ -e "$TEMPD/zorin-os-premium-keyring.deb" ]; then
	sudo chmod 755 "$TEMPD/zorin-os-premium-keyring.deb"
fi
if [ -e "$TEMPD/zorin-os-keyring.deb" ]; then
	sudo chmod 755 "$TEMPD/zorin-os-keyring.deb"
fi

# Install dummy debs if they exist
if [ -e "$TEMPD/zorin-os-premium-keyring.deb" ]; then
	if ! sudo dpkg -i "$TEMPD/zorin-os-premium-keyring.deb"; then
		echo "Warning: Failed to install dummy zorin-os-premium-keyring package."
	fi
fi
if [ -e "$TEMPD/zorin-os-keyring.deb" ]; then
	if ! sudo dpkg -i "$TEMPD/zorin-os-keyring.deb"; then
		echo "Warning: Failed to install dummy zorin-os-keyring package."
	fi
fi

echo ""
echo "Done installing dummy debs if needed..."
echo ""

echo ""
echo "Adding premium content from the official apt repo..."
echo ""

if [ "$version" = "16" ]; then
	# Install 16 pro content
	if [ "$extra" = "true" ]; then
		if ! sudo apt-get install ${no_confirm} zorin-additional-drivers-checker zorin-appearance zorin-appearance-layouts-shell-core zorin-appearance-layouts-shell-premium zorin-appearance-layouts-support zorin-auto-theme zorin-connect zorin-desktop-session zorin-desktop-themes zorin-exec-guard zorin-exec-guard-app-db zorin-gnome-tour-autostart zorin-icon-themes zorin-os-artwork zorin-os-default-settings zorin-os-docs zorin-os-file-templates zorin-os-keyring zorin-os-minimal zorin-os-overlay zorin-os-premium-keyring zorin-os-printer-test-page zorin-os-pro zorin-os-pro-creative-suite zorin-os-pro-productivity-apps zorin-os-pro-wallpapers zorin-os-pro-wallpapers-16 zorin-os-restricted-addons zorin-os-standard zorin-os-tour-video zorin-os-upgrader zorin-os-wallpapers zorin-os-wallpapers-12 zorin-os-wallpapers-15 zorin-os-wallpapers-16 zorin-sound-theme zorin-windows-app-support-installation-shortcut; then
			echo "Error: Failed to install APT packages. (16 Extra)"
			exit 1
		fi
		# Install flatpak packages individually to allow user to choose which to install
		flatpak_packages_16="org.nickvision.money com.usebottles.bottles io.github.seadve.Kooha com.rafaelmardojai.Blanket nl.hjdskes.gcolor3 org.ardour.Ardour org.darktable.Darktable org.audacityteam.Audacity org.kde.krita org.gnome.BreakTimer org.gabmus.gfeeds fr.handbrake.ghb com.github.johnfactotum.Foliate org.inkscape.Inkscape com.obsproject.Studio org.mixxx.Mixxx io.github.OpenToonz org.pitivi.Pitivi org.videolan.VLC com.github.xournalpp.xournalpp net.scribus.Scribus org.blender.Blender"
		for package in $flatpak_packages_16; do
			if ! flatpak install flathub ${no_confirm} "$package"; then
				echo "Warning: Failed to install Flatpak package $package. Continuing with remaining packages..."
			fi
		done
	else
		if ! sudo apt-get --no-install-recommends install ${no_confirm} zorin-appearance zorin-appearance-layouts-shell-core zorin-appearance-layouts-shell-premium zorin-appearance-layouts-support zorin-auto-theme zorin-icon-themes zorin-os-artwork zorin-os-keyring zorin-os-premium-keyring zorin-os-pro zorin-os-pro-wallpapers zorin-os-pro-wallpapers-16 zorin-os-wallpapers zorin-os-wallpapers-16; then
			echo "Error: Failed to install APT packages. (16)"
			exit 1
		fi
	fi
elif [ "$version" = "17" ]; then
	# Install 17 pro content
	if [ "$extra" = "true" ]; then
		if ! sudo apt-get install ${no_confirm} zorin-additional-drivers-checker zorin-appearance zorin-appearance-layouts-shell-core zorin-appearance-layouts-shell-premium zorin-appearance-layouts-support zorin-auto-theme zorin-connect zorin-desktop-session zorin-desktop-themes zorin-exec-guard zorin-exec-guard-app-db zorin-gnome-tour-autostart zorin-icon-themes zorin-os-artwork zorin-os-default-settings zorin-os-docs zorin-os-file-templates zorin-os-keyring zorin-os-minimal zorin-os-overlay zorin-os-premium-keyring zorin-os-printer-test-page zorin-os-pro zorin-os-pro-creative-suite zorin-os-pro-productivity-apps zorin-os-pro-wallpapers zorin-os-pro-wallpapers-16 zorin-os-pro-wallpapers-17 zorin-os-restricted-addons zorin-os-standard zorin-os-tour-video zorin-os-upgrader zorin-os-wallpapers zorin-os-wallpapers-12 zorin-os-wallpapers-15 zorin-os-wallpapers-16 zorin-os-wallpapers-17 zorin-sound-theme zorin-windows-app-support-installation-shortcut; then
			echo "Error: Failed to install APT packages. (17 extra)"
			exit 1
		fi
		# Install flatpak packages individually to allow user to choose which to install
		flatpak_packages_17="org.nickvision.money com.usebottles.bottles io.github.seadve.Kooha com.rafaelmardojai.Blanket nl.hjdskes.gcolor3 org.ardour.Ardour org.darktable.Darktable org.audacityteam.Audacity org.kde.krita org.gnome.BreakTimer org.gabmus.gfeeds fr.handbrake.ghb com.github.johnfactotum.Foliate org.inkscape.Inkscape com.obsproject.Studio org.mixxx.Mixxx io.github.OpenToonz org.kde.kdenlive org.videolan.VLC com.github.xournalpp.xournalpp net.scribus.Scribus org.blender.Blender"
		for package in $flatpak_packages_17; do
			if ! flatpak install flathub ${no_confirm} "$package"; then
				echo "Warning: Failed to install Flatpak package $package. Continuing with remaining packages..."
			fi
		done
	else
		if ! sudo apt-get --no-install-recommends install ${no_confirm} zorin-appearance zorin-appearance-layouts-shell-core zorin-appearance-layouts-shell-premium zorin-appearance-layouts-support zorin-auto-theme zorin-icon-themes zorin-os-artwork zorin-os-keyring zorin-os-premium-keyring zorin-os-pro zorin-os-pro-wallpapers zorin-os-pro-wallpapers-17 zorin-os-wallpapers zorin-os-wallpapers-17; then
			echo "Error: Failed to install packages. (17)"
			exit 1
		fi
	fi
elif [ "$version" = "18" ]; then
	# Install 18 pro content
	if [ "$extra" = "true" ]; then
		if ! sudo apt-get install ${no_confirm} zorin-additional-drivers-checker zorin-appearance zorin-appearance-layouts-shell-core zorin-appearance-layouts-shell-premium zorin-appearance-layouts-support zorin-auto-theme zorin-connect zorin-desktop-session zorin-desktop-themes zorin-exec-guard zorin-exec-guard-app-db zorin-gnome-tour-autostart zorin-icon-themes zorin-os-artwork zorin-os-default-settings zorin-os-docs zorin-os-file-templates zorin-os-keyring zorin-os-minimal zorin-os-overlay zorin-os-premium-keyring zorin-os-printer-test-page zorin-os-pro zorin-os-pro-creative-suite zorin-os-pro-productivity-apps zorin-os-pro-wallpapers zorin-os-pro-wallpapers-16 zorin-os-pro-wallpapers-17 zorin-os-restricted-addons zorin-os-standard zorin-os-tour-video zorin-os-upgrader zorin-os-wallpapers zorin-os-wallpapers-12 zorin-os-wallpapers-15 zorin-os-wallpapers-16 zorin-os-wallpapers-17 zorin-os-wallpapers-18 zorin-sound-theme zorin-windows-app-support-installation-shortcut; then
			echo "Error: Failed to install packages. (18 extra)"
			exit 1
		fi
		# Install flatpak packages individually to allow user to choose which to install
		flatpak_packages_18="org.nickvision.money com.usebottles.bottles io.github.seadve.Kooha com.rafaelmardojai.Blanket nl.hjdskes.gcolor3 org.ardour.Ardour org.darktable.Darktable org.audacityteam.Audacity org.kde.krita org.gnome.BreakTimer org.gabmus.gfeeds fr.handbrake.ghb com.github.johnfactotum.Foliate org.inkscape.Inkscape com.obsproject.Studio org.mixxx.Mixxx io.github.OpenToonz org.kde.kdenlive org.videolan.VLC com.github.xournalpp.xournalpp net.scribus.Scribus org.blender.Blender"
		for package in $flatpak_packages_18; do
			if ! flatpak install flathub ${no_confirm} "$package"; then
				echo "Warning: Failed to install Flatpak package $package. Continuing with remaining packages..."
			fi
		done
	else
		if ! sudo apt-get --no-install-recommends install ${no_confirm} zorin-appearance zorin-appearance-layouts-shell-core zorin-appearance-layouts-shell-premium zorin-appearance-layouts-support zorin-auto-theme zorin-icon-themes zorin-os-artwork zorin-os-keyring zorin-os-premium-keyring zorin-os-pro zorin-os-pro-wallpapers zorin-os-wallpapers zorin-os-wallpapers-18; then
			echo "Error: Failed to install packages. (18)"
			exit 1
		fi
	fi
else
	fail
fi

echo ""
echo "Removing you from the ZorinOS Census system (if enrolled)..."
echo ""

if dpkg -s zorin-os-census >/dev/null 2>&1; then
	if ! sudo apt purge -y zorin-os-census; then
		echo "Non-Blocking Error: APT failed to uninstall zorin-os-census"
	fi
else
	echo "zorin-os-census is not installed; skipping removal."
fi

if [ -e "/etc/cron.daily/zorin-os-census" ]; then
	if ! sudo rm -f "/etc/cron.daily/zorin-os-census"; then
		echo "Non-Blocking Error: Failed to delete ZorinOS Census cron task \"/etc/cron.daily/zorin-os-census\""
	fi
else
	echo "ZorinOS Census daily cron task not found; skipping removal."
fi

if [ -e "/etc/cron.hourly/zorin-os-census" ]; then
	if ! sudo rm -f "/etc/cron.hourly/zorin-os-census"; then
		echo "Non-Blocking Error: Failed to delete ZorinOS Census cron task \"/etc/cron.hourly/zorin-os-census\""
	fi
else
	echo "ZorinOS Census hourly cron task not found; skipping removal."
fi

echo ""
echo ""
echo "All done!"
echo "If you have any questions or comments please see https://github.com/NanashiTheNameless/Zorin-OS-Pro/discussions/29 for more information on how to deal with them."
echo ""
echo "If you are using this tool and have issues please file a bug report about said issues on GitHub https://github.com/NanashiTheNameless/Zorin-OS-Pro/issues/new?template=bug_report.yml"
echo ""
echo 'Please Reboot your Zorin Instance... You can do so with "sudo reboot" or by pressing "reboot" in the Zorin menu in the bottom left.'
echo ""
echo ""
