import pyximport

pyximport.install()

import add
import numpy as np

"""
可以发现这种写法是传值
"""
a = np.array([1, 2, 3], dtype=np.float)
add.add(a)
print(a)
