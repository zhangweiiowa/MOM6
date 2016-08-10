# template for Intel compilers
# typical use with mkmf:
# mkmf -t theia-intel.mk -c "-Duse_libMPI -Duse_netCDF" path_names /usr/local/include

############
# commands #
############

FC = mpiifort
CC = mpiicc
CXX = mpiicpc
LD = mpiifort

############
#  flags   #
############

DEBUG =
REPRO =
VERBOSE =
OPENMP =

MAKEFLAGS += --jobs=1

FPPFLAGS := -fpp -Wp,-w

# NESCC systems set HDF5 as the root directory to the HDF5
# development libraries.
INC = -I$(HDF5)/include $(shell nf-config --fflags)
FFLAGS := -fno-alias -auto -safe-cray-ptr -ftz -assume byterecl -i4 -r8 -nowarn -sox -traceback $(INC)
FFLAGS_OPT = -O3 -debug minimal -fp-model source -override-limits
FFLAGS_DEBUG = -g -O0 -check -check noarg_temp_created -check nopointer -warn -warn noerrors -fpe0 -ftrapuv
FFLAGS_REPRO = -O2 -debug minimal -fp-model source -override-limits
FFLAGS_OPENMP = -openmp
FFLAGS_VERBOSE = -v -V -what

CFLAGS := -D__IFC -sox -traceback $(INC)
CFLAGS_OPT = -O2 -debug minimal
CFLAGS_OPENMP = -openmp
CFLAGS_DEBUG = -O0 -g -ftrapuv

LDFLAGS := -L$(HDF5)/lib $(shell nf-config --flibs)
LDFLAGS_OPENMP := -openmp
LDFLAGS_VERBOSE := -Wl,-V,--verbose,-cref,-M

# start with blank LIBS
LIBS :=

ifneq ($(REPRO),)
  CFLAGS += $(CFLAGS_REPRO)
  FFLAGS += $(FFLAGS_REPRO)
else ifneq ($(DEBUG),)
  CFLAGS += $(CFLAGS_DEBUG)
  FFLAGS += $(FFLAGS_DEBUG)
else
  CFLAGS += $(CFLAGS_OPT)
  FFLAGS += $(FFLAGS_OPT)
endif

ifneq ($(OPENMP),)
  CFLAGS += $(CFLAGS_OPENMP)
  FFLAGS += $(FFLAGS_OPENMP)
  LDFLAGS += $(LDFLAGS_OPENMP)
endif

ifneq ($(VERBOSE),)
  CFLAGS += $(CFLAGS_VERBOSE)
  FFLAGS += $(FFLAGS_VERBOSE)
  LDFLAGS += $(LDFLAGS_VERBOSE)
endif

ifeq ($(NETCDF),3)
  # add the use_LARGEFILE cppdef
  ifneq ($(findstring -Duse_netCDF,$(CPPDEFS)),)
    CPPDEFS += -Duse_LARGEFILE
  endif
endif

ifneq ($(findstring netcdf/4,$(LOADEDMODULES)),)
  LIBS += -lnetcdff -lnetcdf -lhdf5_hl -lhdf5 -lz
else
  LIBS += -lnetcdf
endif

LIBS +=
LIBS += -lmkl_blas95_lp64 -lmkl_lapack95_lp64 -lmkl_intel_lp64 -lmkl_core -lmkl_sequential
LDFLAGS += $(LIBS)

#---------------------------------------------------------------------------
# you should never need to change any lines below.

# see the MIPSPro F90 manual for more details on some of the file extensions
# discussed here.
# this makefile template recognizes fortran sourcefiles with extensions
# .f, .f90, .F, .F90. Given a sourcefile <file>.<ext>, where <ext> is one of
# the above, this provides a number of default actions:

# make <file>.opt	create an optimization report
# make <file>.o		create an object file
# make <file>.s		create an assembly listing
# make <file>.x		create an executable file, assuming standalone
#			source
# make <file>.i		create a preprocessed file (for .F)
# make <file>.i90	create a preprocessed file (for .F90)

# The macro TMPFILES is provided to slate files like the above for removal.

RM = rm -f
SHELL = /bin/csh -f
TMPFILES = .*.m *.B *.L *.i *.i90 *.l *.s *.mod *.opt

.SUFFIXES: .F .F90 .H .L .T .f .f90 .h .i .i90 .l .o .s .opt .x

.f.L:
	$(FC) $(FFLAGS) -c -listing $*.f
.f.opt:
	$(FC) $(FFLAGS) -c -opt_report_level max -opt_report_phase all -opt_report_file $*.opt $*.f
.f.l:
	$(FC) $(FFLAGS) -c $(LIST) $*.f
.f.T:
	$(FC) $(FFLAGS) -c -cif $*.f
.f.o:
	$(FC) $(FFLAGS) -c $*.f
.f.s:
	$(FC) $(FFLAGS) -S $*.f
.f.x:
	$(FC) $(FFLAGS) -o $*.x $*.f *.o $(LDFLAGS)
.f90.L:
	$(FC) $(FFLAGS) -c -listing $*.f90
.f90.opt:
	$(FC) $(FFLAGS) -c -opt_report_level max -opt_report_phase all -opt_report_file $*.opt $*.f90
.f90.l:
	$(FC) $(FFLAGS) -c $(LIST) $*.f90
.f90.T:
	$(FC) $(FFLAGS) -c -cif $*.f90
.f90.o:
	$(FC) $(FFLAGS) -c $*.f90
.f90.s:
	$(FC) $(FFLAGS) -c -S $*.f90
.f90.x:
	$(FC) $(FFLAGS) -o $*.x $*.f90 *.o $(LDFLAGS)
.F.L:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c -listing $*.F
.F.opt:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c -opt_report_level max -opt_report_phase all -opt_report_file $*.opt $*.F
.F.l:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c $(LIST) $*.F
.F.T:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c -cif $*.F
.F.f:
	$(FC) $(CPPDEFS) $(FPPFLAGS) -EP $*.F > $*.f
.F.i:
	$(FC) $(CPPDEFS) $(FPPFLAGS) -P $*.F
.F.o:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c $*.F
.F.s:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c -S $*.F
.F.x:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -o $*.x $*.F *.o $(LDFLAGS)
.F90.L:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c -listing $*.F90
.F90.opt:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c -opt_report_level max -opt_report_phase all -opt_report_file $*.opt $*.F90
.F90.l:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c $(LIST) $*.F90
.F90.T:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c -cif $*.F90
.F90.f90:
	$(FC) $(CPPDEFS) $(FPPFLAGS) -EP $*.F90 > $*.f90
.F90.i90:
	$(FC) $(CPPDEFS) $(FPPFLAGS) -P $*.F90
.F90.o:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c $*.F90
.F90.s:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c -S $*.F90
.F90.x:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -o $*.x $*.F90 *.o $(LDFLAGS)
