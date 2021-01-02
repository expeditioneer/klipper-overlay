# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{8,9} )

inherit git-r3 python-single-r1 systemd

DESCRIPTION="Klipper is a 3d-Printer firmware"
HOMEPAGE="https://www.klipper3d.org/"
EGIT_REPO_URI="https://github.com/KevinOConnor/klipper.git"
EGIT_BRANCH="work-python3-20200612"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="doc examples"

DEPEND="
	acct-group/klipper
	acct-user/klipper"

RDEPEND="${DEPEND}
	${PYTHON_DEPS}
	sys-libs/ncurses:0=
	virtual/libusb:1
	$(python_gen_cond_dep '
		>=dev-python/jinja-2.10.1[${PYTHON_USEDEP}]
		>=dev-python/pyserial-3.4[${PYTHON_USEDEP}]
		dev-python/virtualenv[${PYTHON_USEDEP}]
		virtual/python-cffi[${PYTHON_USEDEP}]
		virtual/python-greenlet[${PYTHON_USEDEP}]')"

DOCS=( COPYING )

src_compile() {
	:
}

src_install() {

	if use doc; then
		dodoc -r ${DOCS[@]} docs/*.md docs/img docs/prints
	fi

	if use examples; then
		insinto "/usr/share/${PN}/examples"
		doins -r config/*
	fi

	# currently only these are python3 compatible or have missing dependencies
	local required_scripts=( scripts/buildcommands.py \
		scripts/check-gcc.sh \
		scripts/flash-*.sh
	)

	insinto "/opt/${PN}"
	doins -r Makefile klippy lib src

	insinto "/opt/${PN}/scripts"
	insopts -m0755
	doins -r ${required_scripts[@]}
	python_fix_shebang "${D}/opt/${PN}/scripts/"

	# UPSTREAM-ISSUE https://github.com/KevinOConnor/klipper/issues/3689
	chmod 0755 "${D}/opt/${PN}/klippy/klippy.py"
	python_fix_shebang "${D}/opt/klipper/klippy/klippy.py"

	systemd_newunit "${FILESDIR}/klipper.service" "klipper.service"

	dodir /etc/klipper
	keepdir /etc/klipper

	dodir /var/spool/klipper/virtual_sdcard
	keepdir /var/spool/klipper/virtual_sdcard

	dodir /var/log/klipper
	keepdir /var/log/klipper

	fowners -R klipper:klipper /opt/klipper /var/spool/klipper/ /etc/klipper /var/log/klipper

	doenvd "${FILESDIR}/99klipper"
}

pkg_postinst() {
	echo
	elog "Next steps:"
	elog "  create a cross-compiler for your printer board, see the Gentoo wiki for instructions"
	elog "  configure your printer board and create the firmware according to official klipper documentation"
	echo
	elog "  Provide a valid printer.cfg in /etc/klipper, which should be writeable by the user 'klipper'"
	elog "  Afterwards enable the klipper service with:"
	elog "    systemctl enable klipper.service"
	echo
	elog "  To use the virtual_sdcard feature of klipper the path"
	elog "  /var/spool/klipper/virtual_sdcard/"
	elog "  should be used in printer.cfg."
	echo
}
