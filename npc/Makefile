ROOT_DIR = $(shell pwd)
SUB_DIR += $(ROOT_DIR)/../test_our

all:
	@echo "Write this Makefile by your self."
	$(SUB_DIR)

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "Write this Makefile by your self."
	make -C $(SUB_DIR) htl
include ../Makefile
