# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake systemd

DESCRIPTION="MJPG-streamer takes JPGs from Linux-UVC compatible webcams"
HOMEPAGE="https://github.com/jacksonliam/mjpg-streamer"
SRC_URI="https://github.com/jacksonliam/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"

INPUT_PLUGINS=( input-file input-http input-opencv input-ptp2 +input-raspicam input-uvc )
OUTPUT_PLUGINS=( output-file +output-http output-rtsp output-udp output-viewer output-zmqserver )

IUSE="${INPUT_PLUGINS[*]}  ${OUTPUT_PLUGINS[*]} +www http-management wxp-compat"

REQUIRED_USE="
	|| ( ${INPUT_PLUGINS[*]//+} )
	|| ( ${OUTPUT_PLUGINS[*]//+} )"

RDEPEND="
	media-libs/libjpeg-turbo
	input-ptp2? ( media-libs/libgphoto2 )
	input-raspicam? (	|| ( media-libs/raspberrypi-userland media-libs/raspberrypi-userland-bin ) )
	input-uvc? ( media-libs/libv4l acct-group/video )
	output-zmqserver? (
		dev-libs/protobuf-c
		net-libs/zeromq
	)"

DEPEND="${RDEPEND}"

S="${WORKDIR}/${P}/${PN}-experimental"

PATCHES=(
	"${FILESDIR}/${P}-input_raspicam.patch"
)

DOCS=(README.md TODO)

src_prepare() {
	sed -i -e "s|.*RPATH.*||g" CMakeLists.txt || die

	local plugin input_output_plugins
	input_output_plugins="${INPUT_PLUGINS[*]//+} ${OUTPUT_PLUGINS[*]//+}"
	for plugin in ${input_output_plugins}; do
		if ! use ${plugin} ; then
			sed -i -e "/add_subdirectory(plugins\/${plugin//[-]/_}/d" CMakeLists.txt || die
		fi
	done
	unset plugin input_output_plugins

	cmake_src_prepare
}

src_configure() {
	CMAKE_BUILD_TYPE=Release

	local mycmakeargs=(
		-DENABLE_HTTP_MANAGEMENT=$(usex http-management)
		-DHAS_RASPI=$(usex input-raspicam)
		-DWXP_COMPAT=$(usex wxp-compat)
	)
	cmake_src_configure
}

src_install() {
	into /usr
	dobin ${PN//-/_}
	into "/usr/$(get_libdir)/${PN}"
	dolib.so *.so

	if use www ; then
		insinto /usr/share/${PN}
		doins -r www
	fi

	dodoc README.md TODO

	newinitd ${PN}.initd ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
	systemd_dounit mjpg_streamer@.service
}

pkg_postinst() {
	einfo
	elog "Remember to set an input and output plugin for mjpg-streamer."

	if use input-uvc ; then
		elog "To use the UVC plugin as a regular user, you must be a part of the video group"
	fi

	if use www ; then
		einfo
		elog "An example webinterface has been installed into"
		elog "/usr/share/mjpg-streamer/www for your usage."
	fi
	einfo
}
