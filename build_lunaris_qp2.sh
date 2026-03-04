# cleanup
remove_lists=(
    .repo/local_manifests
    device/asus/X01BD
    device/asus/X01BD-ext
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
repo init --depth=1 --no-repo-verify --git-lfs -u https://github.com/Lunaris-AOSP/android.git -b 16.2 -g default,-mips,-darwin,-notdefault

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
#do_reclone https://github.com/rsuplaygrnd/device_evolution_sepolicy.git bq2 device/lineage/sepolicy

# Setup our signing key, overriding existing signing key (yukiprjkt)
do_reclone https://github.com/rsuntk/vendor_lineage-priv.git master vendor/lineage-priv/keys

# Setup extra value for current device tree
do_reclone https://gitlab.com/rsuntk-asus-sdm660/android_device_asus_X01BD-ext.git lunaris-vanilla device/asus/X01BD-ext

# Setup device maintainer
echo "ro.lunaris.maintainer=rsuntk" >> device/asus/X01BD/properties/system.prop

# Set up build environment
export BUILD_USERNAME=rsuntk
export BUILD_HOSTNAME=nobody
export TZ="Asia/Jakarta"
source build/envsetup.sh

# Build the ROM
lunch lineage_X01BD-bp4a-user
make installclean
m bacon

[ -d out ] && ls out/target/product/X01BD
