比较四种方式的性能：
* 纯C
* 纯Python
* 使用Cython包装C
* 使用python.h包装C

四种方式性能排序：
纯C是Cython的三倍，Cython比使用Python.h包装的还要快，因为Cython做了很多优化，Cython大约比Python.h快1.5倍，使用扩展可以对Python提速二十倍。  