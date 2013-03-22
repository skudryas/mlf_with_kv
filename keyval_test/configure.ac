AC_INIT(tests, 1.0, a@a.com)
AC_CONFIG_AUX_DIR(config)
AC_CONFIG_SRCDIR(src)
AM_CONFIG_HEADER(config.h)

AM_INIT_AUTOMAKE
AC_PROG_CXX
AC_PROG_LIBTOOL

AM_ICONV

AC_ARG_ENABLE(all-static,
[ --enable-all-static build completely static (standalone) binaries],
[
 if test "$enableval" = "yes" ; then
   LT_LDFLAGS="-all-static $LT_LDFLAGS"
 fi
])
AC_SUBST(LT_LDFLAGS)
AX_BOOST_BASE
AX_BOOST_SYSTEM
AX_BOOST_ASIO
AX_BOOST_THREAD
#AX_BOOST_LOCALE
#AX_BOOST_PROGRAM_OPTIONS
#AX_BOOST_REGEX
AX_BOOST_UNIT_TEST_FRAMEWORK

AC_ARG_ENABLE(debug, [  --enable-debug          turn on debugging [default=no]],, enable_debug=no)
AC_MSG_CHECKING(Is debug version needed)
if test "x$enable_debug" = "xyes";
then
AC_MSG_RESULT(debug mode)
else
AC_MSG_RESULT(release mode)
fi

AC_OUTPUT(Makefile)
AC_OUTPUT(src/Makefile)

