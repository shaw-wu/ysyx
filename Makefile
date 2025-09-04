STUID = ysyx_25010009
STUNAME = 吴孝洲

edits = $(wildcard edit*)
objects = $(patsubst %.c,%.o,$(wildcard *.c))
#CFLAGS=-Wall -g

.PHONY: all,clean
all: edit1 edit3 edit4 edit8 edit9 edit10 edit11 edit12 edit13 edit14 edit16-1 edit16-2 edit17-1 edit17-2 edit18 edit32-1

edit1:ex1.o
	gcc -o edit1 ex1.o
edit3:ex3.o
	gcc -o edit3 ex3.o
edit4:ex4.o
	gcc -o edit4 ex4.o
edit8:ex8.o
	gcc -o edit8 ex8.o
edit9:ex9.o
	gcc -o edit9 ex9.o
edit10:ex10.o
	gcc -o edit10 ex10.o
edit11:ex11.o
	gcc -o edit11 ex11.o
edit12:ex12.o
	gcc -o edit12 ex12.o
edit13:ex13.o
	gcc -o edit13 ex13.o
edit14:ex14.o
	gcc -o edit14 ex14.o
edit16-1:ex16-1.o
	gcc -o edit16-1 ex16-1.o
edit16-2:ex16-2.o
	gcc -o edit16-2 ex16-2.o
edit17-1:ex17-1.o
	gcc -o edit17-1 ex17-1.o
edit17-2:ex17-2.o
	gcc -o edit17-2 ex17-2.o
edit18:ex18.o
	gcc -o edit18 ex18.o
edit32-1:ex32-1.o
	gcc -o edit32-1 ex32-1.o

$(objects) : %.o: %.c
	$(CC) -c -g $< -o $@

clean :
	-rm $(edits) $(objects)
# DO NOT modify the following code!!!

TRACER = tracer-ysyx
GITFLAGS = -q --author='$(TRACER) <tracer@ysyx.org>' --no-verify --allow-empty

YSYX_HOME = $(NEMU_HOME)/..
WORK_BRANCH = $(shell git rev-parse --abbrev-ref HEAD)
WORK_INDEX = $(YSYX_HOME)/.git/index.$(WORK_BRANCH)
TRACER_BRANCH = $(TRACER)

LOCK_DIR = $(YSYX_HOME)/.git/

# prototype: git_soft_checkout(branch)
define git_soft_checkout
	git checkout --detach -q && git reset --soft $(1) -q -- && git checkout $(1) -q --
endef

# prototype: git_commit(msg)
define git_commit
	-@flock $(LOCK_DIR) $(MAKE) -C $(YSYX_HOME) .git_commit MSG='$(1)'
	-@sync $(LOCK_DIR)
endef

.git_commit:
	-@while (test -e .git/index.lock); do sleep 0.1; done;               `# wait for other git instances`
	-@git branch $(TRACER_BRANCH) -q 2>/dev/null || true                 `# create tracer branch if not existent`
	-@cp -a .git/index $(WORK_INDEX)                                     `# backup git index`
	-@$(call git_soft_checkout, $(TRACER_BRANCH))                        `# switch to tracer branch`
	-@git add . -A --ignore-errors                                       `# add files to commit`
	-@(echo "> $(MSG)" && echo $(STUID) $(STUNAME) && uname -a && uptime `# generate commit msg`) \
	                | git commit -F - $(GITFLAGS)                        `# commit changes in tracer branch`
	-@$(call git_soft_checkout, $(WORK_BRANCH))                          `# switch to work branch`
	-@mv $(WORK_INDEX) .git/index                                        `# restore git index`

.clean_index:
	rm -f $(WORK_INDEX)

_default:
	@echo "Please run 'make' under subprojects."

.PHONY: .git_commit .clean_index _default
