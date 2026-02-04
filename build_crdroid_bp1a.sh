# cleanup
remove_lists=(
    .repo/local_manifests
    prebuilts/clang/host/linux-x86
    device/qcom/sepolicy
    device/qcom/sepolicy-legacy-um
    device/qcom/sepolicy_vndr/legacy-um
    device/asus/sdm660-common
    device/asus/X01BD
    kernel/asus/sdm660
    out/target/product/X01BD
    external/chromium-webview
)

rm -rf "${remove_lists[@]}"

# init repo
repo init --depth=1 --no-repo-verify --git-lfs -u https://github.com/crdroidandroid/android.git -b 15.0 -g default,-mips,-darwin,-notdefault

# clone local manifests
git clone https://github.com/rsuplaygrnd/local_manifest --depth 1 -b X01BD-bp1a .repo/local_manifests

# repo sync
[ -f /usr/bin/resync ] && /usr/bin/resync || /opt/crave/resync.sh

# setup KernelSU
if [ -d kernel/asus/sdm660 ]; then
    cd kernel/asus/sdm660
    curl -LSs "https://raw.githubusercontent.com/rsuntk/KernelSU/main/kernel/setup.sh" | bash -s main
    cd ../../..
fi

# Set up build environment
export BUILD_USERNAME=rsuntk
export BUILD_HOSTNAME=nobody
export TZ="Asia/Jakarta"
source build/envsetup.sh

# Build the ROM
lunch lineage_X01BD-bp1a-userdebug
make installclean
mka bacon

[ -d out ] && ls out/target/product/X01BD
