AC_DEFUN([OS_WINDOWS_CHECKS],[
  AC_MSG_CHECKING([if building for Windows or Cygwin])
  AM_CONDITIONAL([OS_WINDOWS], [test "x$windows" = "xyes"])
  AM_COND_IF([OS_WINDOWS],[],[windows=no])
  AC_MSG_RESULT([$windows])

  AM_COND_IF([OS_WINDOWS],[
    dnl ao_wasapi uses COM to load symbols, only needs -lole32 and headers
    AX_CC_CHECK_LIBS([-lole32],[WASAPI],[WASAPI],[
#define COBJMACROS 1
#define _WIN32_WINNT 0x600
#include <initguid.h>
#include <mmdeviceapi.h>
#include <audioclient.h>
#include <endpointvolume.h>

int main(void) {
    const GUID *check[[]] = {
      &IID_IAudioClient,
      &IID_IAudioRenderClient,
      &IID_IAudioEndpointVolume,
    };
    (void)check[[0]];

    CoInitialize(NULL);
    IMMDeviceEnumerator *e;
    CoCreateInstance(&CLSID_MMDeviceEnumerator, NULL, CLSCTX_ALL,
                     &IID_IMMDeviceEnumerator, (void **)&e);
    IMMDeviceEnumerator_Release(e);
    CoUninitialize();
}
    ])

    dnl ao_dsound uses LoadLibrary to load symbols, only needs the header
    AX_CHECK_STATEMENT([DSOUND],[DirectSound],[dsound.h])

    AX_CC_CHECK_LIBS(["-lopengl32 -lgdi32"],[OPENGL],[OpenGL],[
#include <windows.h>
#include <GL/gl.h>
#include <GL/glext.h>

int main(void) {
  HDC dc;
  wglCreateContext(dc);
  glFinish();
  return !GL_INVALID_FRAMEBUFFER_OPERATION;
}
    ])

    dnl vo_direct3d uses LoadLibrary to load symbols, only needs the header
    AX_CHECK_STATEMENT([DIRECT3D],[Direct3D 9],[d3d9.h])
  ])

  AM_CONDITIONAL([HAVE_WASAPI],[test "x$have_wasapi" = "xyes"])
  AM_CONDITIONAL([HAVE_DSOUND],[test "x$have_dsound" = "xyes"])
  AM_CONDITIONAL([HAVE_DIRECT3D],[test "x$have_direct3d" = "xyes"])

  AM_CONDITIONAL([HAVE_OPENGL],[test "x$have_opengl" = "xyes"])
  AM_COND_IF([HAVE_OPENGL],[
    AC_DEFINE([HAVE_OPENGL_WIN32], [1], [Define 1 if OpenGL on Win32 is enabled])])
])
