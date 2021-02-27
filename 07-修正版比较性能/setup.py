from distutils.core import setup, Extension

from Cython.Build import cythonize

setup(
    ext_modules=(
            [Extension("cfib", sources=["cfib.c", "cfib_wrap.c"])] +
            cythonize("cyfib.pyx") +
            cythonize([Extension("wrap_fib", sources=["cfib.c", "wrap_fib.pyx"])])
    ),
)
