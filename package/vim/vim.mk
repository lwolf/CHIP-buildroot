################################################################################
#
# vim
#
################################################################################

VIM_SITE = https://vim.googlecode.com/hg
VIM_SITE_METHOD = hg
# 7.4 release patchlevel 333
VIM_VERSION = 8ae50e3ef8bf
# Win over busybox vi since vim is more feature-rich
VIM_DEPENDENCIES = \
	ncurses $(if $(BR2_NEEDS_GETTEXT_IF_LOCALE),gettext) \
	$(if $(BR2_PACKAGE_BUSYBOX),busybox)
VIM_SUBDIR = src
VIM_CONF_ENV = \
	vim_cv_toupper_broken=no \
	vim_cv_terminfo=yes \
	vim_cv_tty_group=world \
	vim_cv_tty_mode=0620 \
	vim_cv_getcwd_broken=no \
	vim_cv_stat_ignores_slash=yes \
	vim_cv_memmove_handles_overlap=yes \
	ac_cv_sizeof_int=4 \
	ac_cv_small_wchar_t=no
# GUI/X11 headers leak from the host so forcibly disable them
VIM_CONF_OPTS = --with-tlib=ncurses --enable-gui=no --without-x
VIM_LICENSE = Charityware
VIM_LICENSE_FILES = README.txt

ifeq ($(BR2_PACKAGE_LIBSELINUX),y)
VIM_CONF_OPTS += --enable-selinux
VIM_DEPENDENCIES += libselinux
else
VIM_CONF_OPTS += --disable-selinux
endif

define VIM_INSTALL_TARGET_CMDS
	cd $(@D)/src; \
		$(MAKE) DESTDIR=$(TARGET_DIR) installvimbin; \
		$(MAKE) DESTDIR=$(TARGET_DIR) installtools; \
		$(MAKE) DESTDIR=$(TARGET_DIR) installlinks
endef

define VIM_INSTALL_RUNTIME_CMDS
	cd $(@D)/src; \
		$(MAKE) DESTDIR=$(TARGET_DIR) installrtbase; \
		$(MAKE) DESTDIR=$(TARGET_DIR) installmacros
endef

define VIM_REMOVE_DOCS
	find $(TARGET_DIR)/usr/share/vim -type f -name "*.txt" -delete
endef

# Avoid oopses with vipw/vigr, lack of $EDITOR and 'vi' command expectation
define VIM_INSTALL_VI_SYMLINK
	ln -sf /usr/bin/vim $(TARGET_DIR)/bin/vi
endef
VIM_POST_INSTALL_TARGET_HOOKS += VIM_INSTALL_VI_SYMLINK

ifeq ($(BR2_PACKAGE_VIM_RUNTIME),y)
VIM_POST_INSTALL_TARGET_HOOKS += VIM_INSTALL_RUNTIME_CMDS
VIM_POST_INSTALL_TARGET_HOOKS += VIM_REMOVE_DOCS
endif

$(eval $(autotools-package))
