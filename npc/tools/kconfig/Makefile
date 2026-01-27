NAME = conf
obj := build
SRCS += confdata.c expr.c preprocess.c symbol.c util.c
SRCS += $(obj)/lexer.lex.c $(obj)/parser.tab.c
CC = gcc
CFLAGS += -DYYDEBUG
INC_PATH += .
DISTRO = $(shell cat /etc/os-release | grep PRETTY_NAME | sed 's/PRETTY_NAME=//')
GEN_VH_PY := $(NPC_HOME)/scripts/gen_vh.py
AUTOCONF_H := $(NPC_HOME)/include/generated/autoconf.h
SOC_CONF_VH := $(NPC_HOME)/include/generated/soc_conf.vh

define sync_vh
	@echo "+ SYNC VH [$(AUTOCONF_H) -> $(SOC_CONFIG_VH)]"
	@python3 $(GEN_VH_PY) $(AUTOCONF_H) $(SOC_CONFIG_VH)
endef

ifeq ($(DISTRO),"Gentoo Linux")
LIBS += -ltinfo
endif

ifeq ($(NAME),conf)
SRCS += conf.c
else ifeq ($(NAME),mconf)
SRCS += mconf.c $(shell find lxdialog/ -name "*.c")
LIBS += -lncurses
else
$(error bad target=$(NAME))
endif

include $(NEMU_HOME)/scripts/build.mk

$(obj)/lexer.lex.o: $(obj)/parser.tab.h
$(obj)/lexer.lex.c: lexer.l $(obj)/parser.tab.h
	@echo + LEX $@
	@flex -o $@ $<

$(obj)/parser.tab.c $(obj)/parser.tab.h: parser.y
	@echo + YACC $@
	@bison -v $< --defines=$(obj)/parser.tab.h -o $(obj)/parser.tab.c

conf:
	$(MAKE) -s
	$(call sync_vh)

mconf:
	$(MAKE) -s NAME=mconf
	$(call sync_vh)


#增加一个独立的目标，方便手动更新
vh:
	$(call sync_vh)
.PHONY: conf mconf
