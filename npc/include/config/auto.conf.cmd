deps_config := \
	csrc/device/Kconfig \
	csrc/memory/Kconfig \
	/home/shaw/ysyx/npc/csrc/Kconfig \
	/home/shaw/ysyx/npc/Kconfig

include/config/auto.conf: \
	$(deps_config)


$(deps_config): ;
