# Maintainer: Samuel (kwankiu) <info@1us.ca>

_pkgbase=rtl88x1bu
_pkgver=0.2
pkgname=$_pkgbase-dkms-git
pkgver=$_pkgver.r23.ebb8dee
pkgrel=1
pkgdesc="Kernel module for USB WiFi Adapters based on Realtek RTL8831BU and RTL8851BU Chipsets"
arch=('x86_64' 'aarch64')
url="https://github.com/heesn/rtl8831"
license=('GPL2')
depends=('dkms' 'bc')
makedepends=('git')
source=("git+https://github.com/heesn/rtl8831.git"
        "0001-Compile-for-ARM64.patch")
sha256sums=('SKIP'
            'SKIP')

prepare() {
    cd "$srcdir/rtl8831"
    if [[ $CARCH == "aarch64" ]]; then
        echo "Patching for ARM64"
        patch -p1 -N -i $srcdir/0001-Compile-for-ARM64.patch
    fi
}

pkgver() {
    cd "$srcdir/rtl8831"
    printf '%s.r%s.%s' "${_pkgver}" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

package() {
    cd "$srcdir/rtl8831"
    mkdir -p "${pkgdir}/usr/src/${_pkgbase}-${pkgver}"
    cp -pr * "${pkgdir}/usr/src/${_pkgbase}-${pkgver}"
    install -Dm644 dkms.conf "${pkgdir}/usr/src/${_pkgbase}-${pkgver}/dkms.conf"
}