#
# Copyright 2011-2017 Branimir Karadzic. All rights reserved.
# License: https://github.com/bkaradzic/bgfx#license-bsd-2-clause
#

THISDIR:=$(dir $(lastword $(MAKEFILE_LIST)))
include $(THISDIR)/tools.mk

#SHADERS_DIR:=/home.net/mk16dam/workspace/librenderoo/src/shaders/
TEMP:=.

VS_FLAGS+=-i $(THISDIR)../src/ --type vertex
FS_FLAGS+=-i $(THISDIR)../src/ --type fragment

VS_SOURCES=$(wildcard vs_*.sc)
FS_SOURCES=$(wildcard fs_*.sc)

VS_BIN = $(addsuffix .bin.h, $(basename $(VS_SOURCES)))
FS_BIN = $(addsuffix .bin.h, $(basename $(FS_SOURCES)))

BIN = $(VS_BIN) $(FS_BIN)

SHADER_TMP = $(TEMP)/tmp

vs_%.bin.h : vs_%.sc
	@echo [$(<)]
	 $(SILENT) $(SHADERC) $(VS_FLAGS) --platform linux   -p 140         -f $(<) -o $(SHADER_TMP) --bin2c $(basename $(<))_gl
	@cat $(SHADER_TMP) > $(@)
	-$(SILENT) $(SHADERC) $(VS_FLAGS) --platform android      -f $(<) -o $(SHADER_TMP) --bin2c $(basename $(<))_gles
	-@cat $(SHADER_TMP) >> $(@)
	-$(SILENT) $(SHADERC) $(VS_FLAGS) --platform ios     -p metal  -O 3 -f $(<) -o $(SHADER_TMP) --bin2c $(basename $(<))_mtl
	-@cat $(SHADER_TMP) >> $(@)
	-@echo extern const uint8_t* $(basename $(<))_pssl;>> $(@)
	-@echo extern const uint32_t $(basename $(<))_pssl_size;>> $(@)

fs_%.bin.h : fs_%.sc
	@echo [$(<)]
	 $(SILENT) $(SHADERC) $(FS_FLAGS) --platform linux  -p 140                -f $(<) -o $(SHADER_TMP) --bin2c $(basename $(<))_gl
	@cat $(SHADER_TMP) > $(@)
	-$(SILENT) $(SHADERC) $(FS_FLAGS) --platform android               -f $(<) -o $(SHADER_TMP) --bin2c $(basename $(<))_gles
	-@cat $(SHADER_TMP) >> $(@)
	-$(SILENT) $(SHADERC) $(FS_FLAGS) --platform ios     -p metal  -O 3 -f $(<) -o $(SHADER_TMP) --bin2c $(basename $(<))_mtl
	-@cat $(SHADER_TMP) >> $(@)
	-@echo extern const uint8_t* $(basename $(<))_pssl;>> $(@)
	-@echo extern const uint32_t $(basename $(<))_pssl_size;>> $(@)

.PHONY: all
all: $(BIN)

.PHONY: clean
clean:
	@echo Cleaning...
	@-rm -vf $(BIN)

.PHONY: rebuild
rebuild: clean all
