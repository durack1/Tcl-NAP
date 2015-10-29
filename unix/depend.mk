napsh${OBJEXT}: ${GENERIC_DIR}/napsh.c ${GENERIC_DIR}/napInt.h
napImgNAO${OBJEXT}: ${GENERIC_DIR}/napImgNAO.c ${TCL_HEADER_DIR}/tkDecls.h \
  ${GENERIC_DIR}/nap.h ${GENERIC_DIR}/nap_check.h
napInit${OBJEXT}: ${GENERIC_DIR}/napInit.c ${GENERIC_DIR}/nap.h ${GENERIC_DIR}/nap_check.h \
  ${GENERIC_DIR}/napInt.h
napPolygon${OBJEXT}: ${GENERIC_DIR}/napPolygon.c ${GENERIC_DIR}/nap.h \
  ${GENERIC_DIR}/nap_check.h ${GENERIC_DIR}/napPolygon.h
nap_get${OBJEXT}: ${GENERIC_DIR}/nap_get.c ${GENERIC_DIR}/napInt.h ${GENERIC_DIR}/nap_hdf.h \
  ${HDF_HEADER_DIR}/hlimits.h \
  ${HDF_HEADER_DIR}/hntdefs.h \
  ${HDF_HEADER_DIR}/htags.h \
  ${HDF_HEADER_DIR}/hbitio.h \
  ${HDF_HEADER_DIR}/hcomp.h \
  ${HDF_HEADER_DIR}/herr.h \
  ${HDF_HEADER_DIR}/hproto.h ${HDF_HEADER_DIR}/vg.h \
  ${HDF_HEADER_DIR}/mfgr.h \
  ${HDF_HEADER_DIR}/netcdf.h \
  ${HDF_HEADER_DIR}/hdf2netcdf.h ${GENERIC_DIR}/nap.h \
  ${GENERIC_DIR}/nap_check.h ${GENERIC_DIR}/nap_netcdf.h
linsys${OBJEXT}: ${GENERIC_DIR}/linsys.c ${GENERIC_DIR}/linsys.h ${GENERIC_DIR}/nap.h \
  ${GENERIC_DIR}/nap_check.h
nap${OBJEXT}: ${GENERIC_DIR}/nap.c ${GENERIC_DIR}/nap.h ${GENERIC_DIR}/nap_check.h \
  ${GENERIC_DIR}/napInt.h
napChoice${OBJEXT}: ${GENERIC_DIR}/napChoice.c ${GENERIC_DIR}/nap.h \
  ${GENERIC_DIR}/nap_check.h
napDyad${OBJEXT}: ${GENERIC_DIR}/napDyad.c ${GENERIC_DIR}/nap.h ${GENERIC_DIR}/nap_check.h \
  ${GENERIC_DIR}/linsys.h
napDyadLib${OBJEXT}: ${GENERIC_DIR}/napDyadLib.c ${GENERIC_DIR}/nap.h \
  ${GENERIC_DIR}/nap_check.h
napLib${OBJEXT}: ${GENERIC_DIR}/napLib.c ${GENERIC_DIR}/nap_hdf.h \
  ${HDF_HEADER_DIR}/hlimits.h \
  ${HDF_HEADER_DIR}/hntdefs.h \
  ${HDF_HEADER_DIR}/htags.h \
  ${HDF_HEADER_DIR}/hbitio.h \
  ${HDF_HEADER_DIR}/hcomp.h \
  ${HDF_HEADER_DIR}/herr.h \
  ${HDF_HEADER_DIR}/hproto.h ${HDF_HEADER_DIR}/vg.h \
  ${HDF_HEADER_DIR}/mfgr.h \
  ${HDF_HEADER_DIR}/netcdf.h \
  ${HDF_HEADER_DIR}/hdf2netcdf.h ${GENERIC_DIR}/nap.h \
  ${GENERIC_DIR}/nap_check.h
napMonad${OBJEXT}: ${GENERIC_DIR}/napMonad.c ${GENERIC_DIR}/nap.h ${GENERIC_DIR}/nap_check.h
napParseLib${OBJEXT}: ${GENERIC_DIR}/napParseLib.c ${GENERIC_DIR}/nap.h \
  ${GENERIC_DIR}/nap_check.h ${GENERIC_DIR}/napParse.tab.h
napSpatial${OBJEXT}: ${GENERIC_DIR}/napSpatial.c ${GENERIC_DIR}/nap.h \
  ${GENERIC_DIR}/nap_check.h
nap_netcdf${OBJEXT}: ${GENERIC_DIR}/nap_netcdf.c ${GENERIC_DIR}/nap_netcdf.h \
  ${GENERIC_DIR}/nap.h ${GENERIC_DIR}/nap_check.h
nap_ooc${OBJEXT}: ${GENERIC_DIR}/nap_ooc.c ${GENERIC_DIR}/nap_hdf.h \
  ${HDF_HEADER_DIR}/hlimits.h \
  ${HDF_HEADER_DIR}/hntdefs.h \
  ${HDF_HEADER_DIR}/htags.h \
  ${HDF_HEADER_DIR}/hbitio.h \
  ${HDF_HEADER_DIR}/hcomp.h \
  ${HDF_HEADER_DIR}/herr.h \
  ${HDF_HEADER_DIR}/hproto.h ${HDF_HEADER_DIR}/vg.h \
  ${HDF_HEADER_DIR}/mfgr.h \
  ${HDF_HEADER_DIR}/netcdf.h \
  ${HDF_HEADER_DIR}/hdf2netcdf.h ${GENERIC_DIR}/nap.h \
  ${GENERIC_DIR}/nap_check.h ${GENERIC_DIR}/nap_netcdf.h ${GENERIC_DIR}/napPolygon.h
nap_hdf${OBJEXT}: ${GENERIC_DIR}/nap_hdf.c ${GENERIC_DIR}/nap_hdf.h \
  ${HDF_HEADER_DIR}/hlimits.h \
  ${HDF_HEADER_DIR}/hntdefs.h \
  ${HDF_HEADER_DIR}/htags.h \
  ${HDF_HEADER_DIR}/hbitio.h \
  ${HDF_HEADER_DIR}/hcomp.h \
  ${HDF_HEADER_DIR}/herr.h \
  ${HDF_HEADER_DIR}/hproto.h ${HDF_HEADER_DIR}/vg.h \
  ${HDF_HEADER_DIR}/mfgr.h \
  ${HDF_HEADER_DIR}/netcdf.h \
  ${HDF_HEADER_DIR}/hdf2netcdf.h ${GENERIC_DIR}/nap.h \
  ${GENERIC_DIR}/nap_check.h
napParse.tab${OBJEXT}: ${GENERIC_DIR}/napParse.tab.c ${GENERIC_DIR}/nap.h \
  ${GENERIC_DIR}/nap_check.h
