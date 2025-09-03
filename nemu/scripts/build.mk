.DEFAULT_GOAL = app

# Add necessary options if the target is a shared library
ifeq ($(SHARE),1)
SO = -so
CFLAGS  += -fPIC -fvisibility=hidden
LDFLAGS += -shared -fPIC
endif

WORK_DIR  = $(shell pwd)
BUILD_DIR = $(WORK_DIR)/build

INC_PATH += $(NEMU_HOME)/tools/ftrace
INC_PATH += $(WORK_DIR)/include 
OBJ_DIR  = $(BUILD_DIR)/obj-$(NAME)$(SO)
BINARY   = $(BUILD_DIR)/$(NAME)$(SO)

# Compilation flags
ifeq ($(CC),clang)
CXX := clang++
else
CXX := g++
endif
LD := $(CXX)
INCLUDES = $(addprefix -I, $(INC_PATH))
CFLAGS  := -O2 -MMD -Wall -Werror $(INCLUDES) $(CFLAGS)
LDFLAGS := -O2 $(LDFLAGS)

PREPROCESS_OBJS = $(SRCS:%.c=$(OBJ_DIR)/%.i) $(CXXSRC:%.cc=$(OBJ_DIR)/%.i)
PREPROCESS_CFLAGS = -E $(if $(CONFIG_CC_E_P), -P,) $(if $(CONFIG_CC_E_dD), -dD,) $(if $(CONFIG_CC_E_dM), -dM,) 
OBJS = $(SRCS:%.c=$(OBJ_DIR)/%.o) $(CXXSRC:%.cc=$(OBJ_DIR)/%.o)

# Compilation patterns
$(OBJ_DIR)/%.i: %.c
	@mkdir -p $(dir $@)
	$(CC) $(PREPROCESS_CFLAGS) $(INCLUDES) $< -o $@

$(OBJ_DIR)/%.i: %.cc
	@mkdir -p $(dir $@)
	$(CC) $(PREPROCESS_CFLAGS) $(INCLUDES) $< -o $@

$(OBJ_DIR)/%.o: %.c
	@echo + CC $<
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c -o $@ $<
	$(call call_fixdep, $(@:.o=.d), $@)

$(OBJ_DIR)/%.o: %.cc
	@echo + CXX $<
	@mkdir -p $(dir $@)
	@$(CXX) $(CFLAGS) $(CXXFLAGS) -c -o $@ $<
	$(call call_fixdep, $(@:.o=.d), $@)

# Depencies
-include $(OBJS:.o=.d)

# Some convenient rules

.PHONY: app clean preonly

app: $(BINARY)

$(BINARY):: $(OBJS) $(ARCHIVES)
	@echo + LD $@ $(OBJS)
	@$(LD) -o $@ $(OBJS) $(LDFLAGS) $(ARCHIVES) $(LIBS)

clean:
	-rm -rf $(BUILD_DIR)

preonly: $(PREPROCESS_OBJS)
