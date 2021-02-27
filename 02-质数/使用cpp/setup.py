from setuptools import setup
from Cython.Build import cythonize

setup(
    name='Hello world app',
    ext_modules=cythonize("primes.pyx", language='c++'),
    zip_safe=False,
)
