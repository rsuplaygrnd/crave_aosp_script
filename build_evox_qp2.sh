# cleanup
remove_lists=(
    .repo/local_manifests
    device/asus/X01BD
    device/lineage/sepolicy
    device/qcom/sepolicy
    device/qcom/sepolicy-legacy-um
    device/qcom/sepolicy_vndr/legacy-um
    external/chromium-webview
    hardware/lineage/interfaces
    hardware/qcom-caf/sdm660/audio
    kernel/asus
    out/target/product/X01BD
    prebuilts/clang/host/linux-x86
    packages/modules/Nfc
    packages/apps/Nfc
    system/nfc
    vendor/extras
    vendor/addons
    vendor/asus
    vendor/lineage-priv/keys
    vendor/evolution-priv/keys
    vendor/rsuntk-priv/keys
)

do_reclone() {
    rm -rf $3
    echo "-- Recloning $3 ..."
    git clone --depth=1 $1 -b $2 $3
}

echo "-- Cleaning up: ${remove_lists[@]}"
rm -rf "${remove_lists[@]}"

# init repo
echo "-- Initializing repo directory"
repo init --depth=1 --no-repo-verify --git-lfs -u https://github.com/Evolution-X/manifest.git -b bq2 -g default,-mips,-darwin,-notdefault

# clone local manifests
git clone https://github.com/rsuntk-asus-sdm660/local_manifests.git --depth 1 -b lineage-23.2 .repo/local_manifests

# repo sync
[ -f /usr/bin/resync ] && /usr/bin/resync || /opt/crave/resync.sh

# Symlink libncurses
sudo ln -sf /usr/lib/x86_64-linux-gnu/libncurses.so.6 /usr/lib/x86_64-linux-gnu/libncurses.so.5
sudo ln -sf /usr/lib/x86_64-linux-gnu/libtinfo.so.6 /usr/lib/x86_64-linux-gnu/libtinfo.so.5

# Setup extra flags
do_reclone https://github.com/rsuntk-asus-sdm660/android_device_asus_X01BD-extra.git evolution-gapps device/asus/X01BD-extra

# Set up build environment
export BUILD_USERNAME=rsuntk
export BUILD_HOSTNAME=nobody
export TZ="Asia/Jakarta"
source build/envsetup.sh

# Build the ROM
lunch lineage_X01BD-bp4a-userdebug
make installclean
m evolution

[ -d out ] && ls out/target/product/X01BD
