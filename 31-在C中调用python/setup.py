from setuptools import setup
from Cython.Build import cythonize

setup(
    name='Hello world app',
    ext_modules=cythonize("embedded.pyx"),
    zip_safe=False,
)
