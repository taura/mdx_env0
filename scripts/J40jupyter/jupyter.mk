#
# jupyter.mk --- install various jupyter modules
#
include ../common.mk

# vpython 
subdirs := jupyter c ocaml bash nbgrader sos
targets := $(addsuffix /OK,$(subdirs))

OK : $(targets)

$(targets) : %/OK :
	cd $* && $(MAKE) -f $*.mk
