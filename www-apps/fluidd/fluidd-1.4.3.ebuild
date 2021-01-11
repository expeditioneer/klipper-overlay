# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

#inherit webapp

HOMEPAGE="https://github.com/cadriel/fluidd"
DESCRIPTION="A free and open-source Klipper web interface for managing your 3d printer."
SRC_URI="https://github.com/cadriel/fluidd/releases/download/v${PV}/${PN}.zip -> ${P}.zip"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

LICENSE="GPL-3"
SLOT="0"
IUSE=""

BDEPEND=""
DEPEND="
	app-arch/unzip
	app-misc/moonraker
	www-servers/nginx"

S=${WORKDIR}

src_install() {
	dodir "/var/www/${PN}"
	insinto "/var/www/${PN}"
	doins "${S}/favicon.ico" "${S}/index.html" "${S}/manifest.json" "${S}"/precache-manifest.* "${S}/robots.txt" "${S}/service-worker.js"

	insinto /etc/klipper
	doins "${FILESDIR}/config.json"
	dosym ../../../etc/klipper/config.json /var/www/${PN}/config.json

	insinto /etc/nginx/conf.d
	doins "${FILESDIR}"/fluidd.conf "${FILESDIR}"/upstreams.conf "${FILESDIR}"/common_vars.conf

}

pkg_postinst() {
	echo
	elog "Adapt /etc/klipper/config.json to your needs"
}