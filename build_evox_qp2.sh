# cleanup
remove_lists=(
    .repo/local_manifests
    device/asus/sdm660-common
    device/asus/X01BD
    device/lineage/sepolicy
    device/qcom/sepolicy
    device/qcom/sepolicy-legacy-um
    device/qcom/sepolicy_vndr/legacy-um
    external/chromium-webview
    kernel/asus/sdm660
    out/target/product/X01BD
    prebuilts/clang/host/linux-x86
    packages/modules/Nfc
    packages/apps/Nfc
    system/nfc
    vendor/extras
    vendor/addons
    vendor/asus/sdm660-common
    vendor/asus/X01BD
    vendor/lineage-priv/keys
    vendor/evolution-priv/keys
)

do_reclone() {
    rm -rf $3
    echo "-- Recloning $3 ..."
    git clone --depth=1 $1 -b $2 $3
}

echo "-- Removing ${remove_lists[@]}"
rm -rf "${remove_lists[@]}"

# init repo
echo "-- Initializing repo directory"
repo init --depth=1 --no-repo-verify --git-lfs -u https://github.com/Evolution-X/manifest.git -b bq2 -g default,-mips,-darwin,-notdefault

# clone local manifests
git clone https://github.com/rsuplaygrnd/local_manifest.git --depth 1 -b lineage-23.2 .repo/local_manifests

# repo sync
echo "-- Starting to sync"
[ -f /usr/bin/resync ] && /usr/bin/resync || /opt/crave/resync.sh

# setup KernelSU
if [ -d kernel/asus/sdm660 ]; then
    cd kernel/asus/sdm660
    curl -LSs "https://raw.githubusercontent.com/rsuntk/KernelSU/main/kernel/setup.sh" | bash -s main
    cd ../../..
fi

# Setup our device/lineage/sepolicy fork
do_reclone https://github.com/rsuplaygrnd/device_evolution_sepolicy.git bq2 device/lineage/sepolicy

# Setup our signing key, overriding existing signing key (yukiprjkt)
rm -rf vendor/lineage-priv/keys
git clone https://gitlab.com/rsuntk-asus-sdm660/signing_template.git vendor/lineage-priv/keys
cd vendor/lineage-priv/keys && bash $(pwd)/keys.sh
cd ../../..

# Set up build environment
export BUILD_USERNAME=rsuntk
export BUILD_HOSTNAME=nobody
export TZ="Asia/Jakarta"
source build/envsetup.sh

# Build the ROM
lunch lineage_X01BD-bp4a-user
make installclean
m evolution

[ -d out ] && ls out/target/product/X01BD
