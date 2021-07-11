cython是一门语言，它连接了C和Python。  

# cython安装
```plain
pip install Cython
```
cython中的头文件为pxd，python中的实现为pyx。

# cython-book
cython官网教程：https://cython.readthedocs.io/en/latest/
oreilly的cython书：https://www.oreilly.com/library/view/cython/9781491901731/  
代码实例：https://github.com/cythonbook/examples  


# Python扩展教程
Python的C API：https://docs.python.org/zh-cn/3/c-api/index.html#c-api-index  这个文档是python C接口的详细教程。  
Python扩展写法：https://docs.python.org/zh-cn/3/extending/index.html  这个文档是扩展写法的简易版教程。
python3 cookbook：https://python3-cookbook.readthedocs.io/zh_CN/latest/chapters/p15_c_extensions.html

# cython的标注库
https://github.com/cython/cython/tree/master/Cython/Includes
* libc
* libcpp
* numpy
* posix
* cpython
* openmp.pxd

# 编译的常见写法
由此文档查看cythonize全部参数
https://cython.readthedocs.io/en/latest/src/userguide/source_files_and_compilation.html
```plain
from setuptools import Extension, setup
from Cython.Build import cythonize

ext_modules = [
    Extension("demo",
              sources=["demo.pyx"],
              libraries=["m"]  # Unix-like specific
              )
]

setup(name="Demos",
      ext_modules=cythonize(ext_modules))
```

# 常见的问题
在写setup.py的过程中，顺序很重要
`error: each element of 'ext_modules' option must be an Extension instance or 2-tuple`
```python
from setuptools import setup
from Cython.Build import cythonize
```
