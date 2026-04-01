# Copyright © 2026 Barry Schwartz
# SPDX-License-Identifier: MIT

.DELETE_ON_ERROR:
.PHONY: clean

VERSION = 0.0.0

CHEZSCHEME_INSTALLDIR = ~/.local/lib/chezscheme
#CHEZ_SUDO = $(SUDO)
CHEZ_SUDO =

GAUCHE_INSTALLDIR = $(shell gauche-config --sitelibdir)
GAUCHE_SUDO = $(SUDO)
#GAUCHE_SUDO =

include silent-rules.mk
DEFAULT_VERBOSITY = 0

# GNU or OpenBSD m4.
GNULIKE_M4 = m4 -P -I $(PWD)

# OpenBSD doas is simpler than sudo, is easily made a static
# executable if you do not need it to use PAM, and doas will work
# here. Incidentally, there is also a shim to make doas your
# mostly-compatible ‘sudo’ command.
SUDO = doas

TAR = tar
XZ = xz

CHEZ = scheme
CHIBI = chibi-scheme
GSI = gsi
GAUCHE = gosh
LOKO = loko
SAGITTARIUS = sagittarius

.PHONY: check-all-scheme-implementations
check-all-scheme-implementations: \
	check-chez-r6rs \
	check-chibi-r7rs \
	check-gauche-r7rs \
	check-loko-r6rs \
	check-loko-r7rs \
	check-sagittarius-r6rs \
	check-sagittarius-r7rs \
	check-chicken-5-r7rs \
	check-chicken-6-r7rs

check-r6rs = $(call v,CHECK)$(foreach f,$(3),$(2)=$(PWD)/r6rs$${$(2)+:}$${$(2)} $(1) $(f);)
check-r7rs = $(call v,CHECK)$(foreach f,$(3),$(2)=$(PWD)/r7rs$${$(2)+:}$${$(2)} $(1) $(f);)

check-chez-r6rs = $(call check-r6rs,$(CHEZ) --program,CHEZSCHEMELIBDIRS,$(1))
check-chibi-r7rs = $(call check-r7rs,$(CHIBI),CHIBI_MODULE_PATH,$(1))
check-gauche-r7rs = $(call check-r7rs,$(GAUCHE) -r7 --,GAUCHE_LOAD_PATH,$(1))
check-loko-r6rs = $(call check-r6rs,$(LOKO) -std=r6rs --program,LOKO_LIBRARY_PATH,$(1))
check-loko-r7rs = $(call check-r7rs,$(LOKO) -std=r7rs --script,LOKO_LIBRARY_PATH,$(1))
check-sagittarius-r6rs = $(call check-r6rs,$(SAGITTARIUS) -d -r6 --,SAGITTARIUS_LOADPATH,$(1))
check-sagittarius-r7rs = $(call check-r7rs,$(SAGITTARIUS) -d -r7 --,SAGITTARIUS_LOADPATH,$(1))

TSTPVEC_R6RS = tests/test-pvec.sps
TSTPVEC_R7RS = tests/test-pvec.scm

R6RS_DEPS_M4 =
R6RS_DEPS_M4 += r6rs/pvec.sls.m4
R6RS_DEPS_M4 += r6rs/pvec/eager-comprehensions.sls.m4
R6RS_DEPS_M4 += r6rs/pvec/srfi-42-generator.sls.m4
R6RS_DEPS_M4 += r6rs/pvec/srfi-42.sls.m4

R6RS_DEPS =
R6RS_DEPS += $(R6RS_DEPS_M4:%.m4=%)
R6RS_DEPS += r6rs/pvec/define-record-factory.sls

R6RS_TESTS_M4 =
R6RS_TESTS_M4 += $(TSTPVEC_R6RS:%=%.m4)

R6RS_TESTS =
R6RS_TESTS += $(TSTPVEC_R6RS)

R7RS_DEPS_M4 =
R7RS_DEPS_M4 += r7rs/pvec.sld.m4
R7RS_DEPS_M4 += r7rs/pvec/eager-comprehensions.sld.m4
R7RS_DEPS_M4 += r7rs/pvec/srfi-42-generator.sld.m4
R7RS_DEPS_M4 += r7rs/pvec/srfi-42.sld.m4

R7RS_DEPS =
R7RS_DEPS += $(R7RS_DEPS_M4:%.m4=%)
R7RS_DEPS += r7rs/pvec/define-record-factory.sld

R7RS_TESTS_M4 =
R7RS_TESTS_M4 += $(TSTPVEC_R7RS:%=%.m4)

R7RS_TESTS =
R7RS_TESTS += $(TSTPVEC_R7RS)

r6rs/pvec.sls: r6rs/pvec.sls.m4
r7rs/pvec.sld: r7rs/pvec.sld.m4
r6rs/pvec.sls r7rs/pvec.sld: common/pvec/pvec-implementation.scm

r6rs/pvec/eager-comprehensions.sls: r6rs/pvec/eager-comprehensions.sls.m4
r7rs/pvec/eager-comprehensions.sld: r7rs/pvec/eager-comprehensions.sld.m4
r6rs/pvec/eager-comprehensions.sls r7rs/pvec/eager-comprehensions.sld: \
	common/pvec/eager-comprehensions-implementation.scm

r6rs/pvec/srfi-42-generator.sls: r6rs/pvec/srfi-42-generator.sls.m4
r7rs/pvec/srfi-42-generator.sld: r7rs/pvec/srfi-42-generator.sld.m4
r6rs/pvec/srfi-42-generator.sls r7rs/pvec/srfi-42-generator.sld: \
	common/pvec/srfi-42-generator-implementation.scm

r6rs/pvec/srfi-42.sls: r6rs/pvec/srfi-42.sls.m4
r7rs/pvec/srfi-42.sld: r7rs/pvec/srfi-42.sld.m4
r6rs/pvec/srfi-42.sls r7rs/pvec/srfi-42.sld: common/pvec/ec.scm

$(TSTPVEC_R6RS): $(TSTPVEC_R6RS:%=%.m4)
$(TSTPVEC_R7RS): $(TSTPVEC_R7RS:%=%.m4)
$(TSTPVEC_R6RS) $(TSTPVEC_R7RS): tests/test-pvec-implementation.scm
$(TSTPVEC_R6RS) $(TSTPVEC_R7RS): tests/tests-common.scm

clean::
	-rm -f $(R6RS_DEPS_M4:%.m4=%)
	-rm -f $(R7RS_DEPS_M4:%.m4=%)
	-rm -f $(TSTPVEC_R6RS)
	-rm -f $(TSTPVEC_R7RS)

%: %.m4
	$(call v,M4)$(GNULIKE_M4) $(<) > $(@)

# To test with Chez Scheme, one must install SRFI software, such as
# chez-srfi.
.PHONY: check-chez-r6rs
check-chez-r6rs: $(R6RS_DEPS) $(R6RS_TESTS)
	$(call check-chez-r6rs, $(TSTPVEC_R6RS))

chezscheme/%.sls: r6rs/%.sls
	$(call v,CP)mkdir -p $(@D) && \
	rm -f $(@) && \
	cp $(<) $(@)

%.so: %.sls
	$(call v,CHEZ)echo '(generate-wpo-files #t)(compile-file "$(<)")' \
	  | CHEZSCHEMELIBDIRS=$(PWD)/r6rs$${CHEZSCHEMELIBDIRS+:}$${CHEZSCHEMELIBDIRS} $(CHEZ) -q

# Precompiled Chez Scheme.
chezscheme/pvec/eager-comprehensions.so: \
		chezscheme/pvec/eager-comprehensions.sls \
		chezscheme/pvec.so \
		chezscheme/pvec/srfi-42-generator.so \
		chezscheme/pvec/srfi-42.so
chezscheme/pvec.so: \
		chezscheme/pvec.sls \
		chezscheme/pvec/define-record-factory.so \
		chezscheme/pvec/srfi-42-generator.so \
		chezscheme/pvec/srfi-42.so
chezscheme/pvec/define-record-factory.so: \
		chezscheme/pvec/define-record-factory.sls
chezscheme/pvec/srfi-42-generator.so: \
		chezscheme/pvec/srfi-42-generator.sls \
		chezscheme/pvec/srfi-42.so
chezscheme/pvec/srfi-42.so: \
		chezscheme/pvec/srfi-42.sls

.PHONY: install-chez uninstall-chez
install-chez:	$(R6RS_DEPS:r6rs/%.sls=chezscheme/%.sls) \
		$(R6RS_DEPS:r6rs/%.sls=chezscheme/%.so)
	$(CHEZ_SUDO) mkdir -p $(CHEZSCHEME_INSTALLDIR)/pvec && \
	for f in $(R6RS_DEPS:r6rs/%.sls=%.sls) \
		$(R6RS_DEPS:r6rs/%.sls=%.so) \
		$(R6RS_DEPS:r6rs/%.sls=%.wpo); do \
	  $(CHEZ_SUDO) rm -f $(CHEZSCHEME_INSTALLDIR)/"$${f}" && \
	  $(CHEZ_SUDO) cp chezscheme/"$${f}" $(CHEZSCHEME_INSTALLDIR)/"$${f}"; \
	done
uninstall-chez:
	-for f in $(R6RS_DEPS:r6rs/%.sls=%.sls); do $(CHEZ_SUDO) rm -f $(CHEZSCHEME_INSTALLDIR)/$${f}; done
	-for f in $(R6RS_DEPS:r6rs/%.sls=%.so); do $(CHEZ_SUDO) rm -f $(CHEZSCHEME_INSTALLDIR)/$${f}; done
	-for f in $(R6RS_DEPS:r6rs/%.sls=%.wpo); do $(CHEZ_SUDO) rm -f $(CHEZSCHEME_INSTALLDIR)/$${f}; done
	-rmdir $(CHEZSCHEME_INSTALLDIR)/pvec || true

clean::
	-rm -Rf chezscheme

# You may have to install some software with snow-chibi or by other
# means. (Also, last I tried it, Chibi’s SRFI-1 was incomplete and
# non-compliant, though it was sufficient for this software.)
.PHONY: check-chibi-r7rs
check-chibi-r7rs: $(R7RS_DEPS) $(R7RS_TESTS)
	$(call check-chibi-r7rs, $(TSTPVEC_R7RS))

.PHONY: check-chicken-5-r7rs check-chicken-6-r7rs
check-chicken-5-r7rs: chicken-5/pvec.so $(R7RS_TESTS)
	$(call v,CHECK)( \
	  export CHICKEN_REPOSITORY_PATH=$${PWD}/chicken-5:$(CHICKEN_5_REPOSITORY_PATH); \
	  $(CSI_5) -s $(TSTPVEC_R7RS); \
	)

check-chicken-6-r7rs: chicken-6/pvec.so $(R7RS_TESTS)
	$(call v,CHECK)( \
	  export CHICKEN_REPOSITORY_PATH=$${PWD}/chicken-6:$(CHICKEN_6_REPOSITORY_PATH); \
	  $(CSI_6) -s $(TSTPVEC_R7RS) \
	)

.PHONY: check-gauche-r7rs
check-gauche-r7rs: $(R7RS_DEPS) $(R7RS_TESTS)
	$(call check-gauche-r7rs, $(TSTPVEC_R7RS))

.PHONY: install-gauche uninstall-gauche
install-gauche: $(R7RS_DEPS)
	$(GAUCHE_SUDO) mkdir -p $(GAUCHE_INSTALLDIR)/pvec && \
	for f in $(R7RS_DEPS:r7rs/%=%); do \
	  $(GAUCHE_SUDO) rm -f $(GAUCHE_INSTALLDIR)/$${f} && \
	  $(GAUCHE_SUDO) cp {r7rs,$(GAUCHE_INSTALLDIR)}/$${f}; \
	done
uninstall-gauche:
	-for f in $(R7RS_DEPS:r7rs/%=%); do $(GAUCHE_SUDO) rm -f $(GAUCHE_INSTALLDIR)/$${f}; done
	-$(GAUCHE_SUDO) rmdir $(GAUCHE_INSTALLDIR)/pvec || true

# To test with Loko Scheme one must install SRFI software, such as
# chez-srfi. The R⁶RS libraries can be imported into R⁷RS software.
.PHONY: check-loko-r6rs check-loko-r7rs
check-loko-r6rs: $(R6RS_DEPS) $(R6RS_TESTS)
	$(call check-loko-r6rs, $(TSTPVEC_R6RS))
check-loko-r7rs: $(R7RS_DEPS) $(R7RS_TESTS)
	$(call check-loko-r7rs, $(TSTPVEC_R7RS))

.PHONY: check-sagittarius-r6rs check-sagittarius-r7rs
check-sagittarius-r6rs: $(R6RS_DEPS) $(R6RS_TESTS)
	$(call check-sagittarius-r6rs, $(TSTPVEC_R6RS))
check-sagittarius-r7rs: $(R7RS_DEPS) $(R7RS_TESTS)
	$(call check-sagittarius-r7rs, $(TSTPVEC_R7RS))

clean::
	-rm -f *.log

#---------------------------------------------------------------------
#
# CHICKEN 5 egg.
#

EGG_5_VERSION = $(VERSION)

CSI_5 = csi
CHICKEN_INSTALL_5 = chicken-install
CHICKEN_UNINSTALL_5 = chicken-uninstall

CHICKEN_5_REPOSITORY_PATH = $(shell $(CHICKEN_INSTALL_5) -repository)

chicken-5/README.adoc: README.adoc
	$(call v,COPY)mkdir -p $(@D) && \
	rm -f $(@) && \
	cp $(<) $(@)

chicken-5/%.sld: r7rs/%.sld
	$(call v,AWK)mkdir -p $(@D) && \
	rm -f $(@) && \
	awk '/^#!r7rs/{next}{print}' < $(<) > $(@)

chicken-5/common/%.scm: common/%.scm
	$(call v,AWK)mkdir -p $(@D) && \
	rm -f $(@) && \
	awk '/^#!r7rs/{next}{print}' < $(<) > $(@)

chicken-5/pvec.egg: GNUmakefile \
	$(addprefix chicken-5/, \
		README.adoc \
		pvec/eager-comprehensions.sld pvec.sld \
		pvec/srfi-42.sld pvec/srfi-42-generator.sld \
		pvec/define-record-factory.sld)
	$(call v,AWK)mkdir -p chicken-5 && \
	awk 'BEGIN { \
	  print "((synopsis \"Persistent vectors\")"; \
	  print " (version \"$(EGG_5_VERSION)\")"; \
	  print " (category data)"; \
	  print " (license \"MIT\")"; \
	  print " (author \"Barry Schwartz\")"; \
	  print " (dependencies r7rs srfi-1 srfi-42 srfi-143)"; \
	  print " (component-options"; \
	  print "  (csc-options \"-X\" \"r7rs\" \"-R\" \"r7rs\""; \
	  print "               \"-O4\" \"-C\" \"-O3\"))"; \
	  print " (components"; \
	  print "  (extension pvec.srfi-42"; \
	  print "   (source \"pvec/srfi-42.sld\"))"; \
	  print "  (extension pvec.srfi-42-generator"; \
	  print "   (source \"pvec/srfi-42-generator.sld\"))"; \
	  print "  (extension pvec.define-record-factory"; \
	  print "   (source \"pvec/define-record-factory.sld\"))"; \
	  print "  (extension pvec"; \
	  print "   (source \"pvec.sld\")"; \
	  print "   (component-dependencies"; \
	  print "    pvec.srfi-42"; \
	  print "    pvec.srfi-42-generator"; \
	  print "    pvec.define-record-factory))"; \
	  print "  (extension pvec.eager-comprehensions"; \
	  print "   (source \"pvec/eager-comprehensions.sld\")"; \
	  print "   (component-dependencies"; \
	  print "    pvec pvec.srfi-42 pvec.srfi-42-generator))"; \
	  print "   ))"; \
	}' > $(@)

chicken-5/pvec.so: chicken-5/pvec.egg
	$(call v,CHICKEN-INSTALL-5)( \
	  cd chicken-5 && \
	  $(CHICKEN_INSTALL_5) -n \
	)

pvec-$(EGG_5_VERSION).chicken-5-egg.tar.xz: clean-chicken-5
	$(MAKE) $(MAKEFLAGS) chicken-5/pvec.egg
	$(TAR) -cf - chicken-5 | $(XZ) > $@

.PHONY: install-chicken-5-egg uninstall-chicken-5-egg
install-chicken-5-egg: chicken-5/pvec.egg
	$(call v,CHICKEN-INSTALL-5)( \
	  cd chicken-5 && \
	  $(CHICKEN_INSTALL_5) -s \
	)
uninstall-chicken-5-egg: chicken-5/pvec.egg
	$(call v,CHICKEN-UNINSTALL-5)( \
	  cd chicken-5 && \
	  $(CHICKEN_UNINSTALL_5) -force -s pvec \
	)

clean-chicken-5:
	-rm -Rf chicken-5

clean:: clean-chicken-5

#---------------------------------------------------------------------
#
# CHICKEN 6 egg.
#

EGG_6_VERSION = $(VERSION)

#
# At the time of this writing, CHICKEN 6 is not yet released. Thus I
# have my CHICKEN 6 commands installed with "-6" suffices.
#
CSI_6 = csi-6
CHICKEN_INSTALL_6 = chicken-install-6
CHICKEN_UNINSTALL_6 = chicken-uninstall-6

CHICKEN_6_REPOSITORY_PATH = $(shell $(CHICKEN_INSTALL_6) -repository)

chicken-6/README.adoc: README.adoc
	$(call v,COPY)mkdir -p $(@D) && \
	rm -f $(@) && \
	cp $(<) $(@)

chicken-6/%.sld: r7rs/%.sld
	$(call v,AWK)mkdir -p $(@D) && \
	rm -f $(@) && \
	awk '/^#!r7rs/{next}{print}' < $(<) > $(@)

chicken-6/common/%.scm: common/%.scm
	$(call v,AWK)mkdir -p $(@D) && \
	rm -f $(@) && \
	awk '/^#!r7rs/{next}{print}' < $(<) > $(@)

chicken-6/pvec.egg: GNUmakefile \
	$(addprefix chicken-6/, \
		README.adoc \
		pvec/eager-comprehensions.sld pvec.sld \
		pvec/srfi-42.sld pvec/srfi-42-generator.sld \
		pvec/define-record-factory.sld)
	$(call v,AWK)mkdir -p chicken-6 && \
	awk 'BEGIN { \
	  print "((synopsis \"Persistent vectors\")"; \
	  print " (version \"$(EGG_6_VERSION)\")"; \
	  print " (category data)"; \
	  print " (license \"MIT\")"; \
	  print " (author \"Barry Schwartz\")"; \
	  print " (dependencies srfi-1 srfi-42 srfi-143)"; \
	  print " (component-options (csc-options \"-O4\" \"-C\" \"-O3\"))"; \
	  print " (components"; \
	  print "  (extension pvec.srfi-42"; \
	  print "   (source \"pvec/srfi-42.sld\"))"; \
	  print "  (extension pvec.srfi-42-generator"; \
	  print "   (source \"pvec/srfi-42-generator.sld\"))"; \
	  print "  (extension pvec.define-record-factory"; \
	  print "   (source \"pvec/define-record-factory.sld\"))"; \
	  print "  (extension pvec"; \
	  print "   (source \"pvec.sld\")"; \
	  print "   (component-dependencies"; \
	  print "    pvec.srfi-42"; \
	  print "    pvec.srfi-42-generator"; \
	  print "    pvec.define-record-factory))"; \
	  print "  (extension pvec.eager-comprehensions"; \
	  print "   (source \"pvec/eager-comprehensions.sld\")"; \
	  print "   (component-dependencies"; \
	  print "    pvec pvec.srfi-42 pvec.srfi-42-generator))"; \
	  print "   ))"; \
	}' > $(@)

chicken-6/pvec.so: chicken-6/pvec.egg
	$(call v,CHICKEN-INSTALL-6)( \
	  cd chicken-6 && \
	  $(CHICKEN_INSTALL_6) -n \
	)

pvec-$(EGG_6_VERSION).chicken-6-egg.tar.xz: clean-chicken-6
	$(MAKE) $(MAKEFLAGS) chicken-6/pvec.egg
	$(TAR) -cf - chicken-6 | $(XZ) > $@

.PHONY: install-chicken-6-egg uninstall-chicken-6-egg
install-chicken-6-egg: chicken-6/pvec.egg
	$(call v,CHICKEN-INSTALL-6)( \
	  cd chicken-6 && \
	  $(CHICKEN_INSTALL_6) -s \
	)
uninstall-chicken-6-egg: chicken-6/pvec.egg
	$(call v,CHICKEN-UNINSTALL-6)( \
	  cd chicken-6 && \
	  $(CHICKEN_UNINSTALL_6) -force -s pvec \
	)

clean-chicken-6:
	-rm -Rf chicken-6

clean:: clean-chicken-6

#---------------------------------------------------------------------
