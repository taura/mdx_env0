Idirs := $(sort $(wildcard I??*))
Idirs_OK := $(addsuffix /OK,$(Idirs))

cur_dir := $(shell pwd)
top_dir := $(realpath $(cur_dir)/..)
bin_dir := $(top_dir)/bin

all : $(Idirs_OK)

$(Idirs_OK) : I%/OK : 
	LC_ALL=C $(MAKE) --warn-undefined-variables -C I$* -f $(notdir $(wildcard I$*/*.mk))
