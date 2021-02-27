以斐波那契数列为例，比较三种写法：
* python
* c
* cython:其中cython中又有三种写法
  * 使用cdef+类型标注，性能最高
  * 使用def+类型标注
  * 使用def纯python

执行build.sh，完成c和cython的构建

执行python compare.py比较三种方法的性能差异。  

在我的电脑上，cython的运行速度比纯C写的代码还要快。  