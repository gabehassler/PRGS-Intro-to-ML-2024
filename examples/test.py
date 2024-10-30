import numpy as np
import time
# from multiprocessing import Pool
from pathos.multiprocessing import ProcessingPool as Pool

def rdet(n):
    X = np.random.normal(size=(n, n))
    X = np.dot(X.T, X)
    return np.log(np.linalg.det(X))

iterations = 1000
ns = range(1, 51)

# Serial computation
mean_dets1 = np.zeros(len(ns))
t1 = time.time()
for i in range(len(ns)):
    s = 0
    for j in range(iterations):
        s += rdet(ns[i])
    mean_dets1[i] = s / iterations

t2 = time.time()

# Parallel computation
# def parallel_rdet(iterations):
#     for j in range(iterations):
#         s += rdet(n)
#     return s / iterations

# if __name__ == '__main__':
t3 = time.time()

for n in ns:
    mean_det =0

    with Pool(processes=8) as pool:
        dets = pool.map(rdet, iterations)
        mean_det = np.mean(dets)
    print(mean_det)
t4 = time.time()

print(f"Serial time: {t2 - t1}")
# print(f"Serial time (list comprehension): {t2s - t1s}")
print(f"Parallel time: {t4 - t3}")

import pandas as pd
df = pd.DataFrame({'n': ns, 'serial': mean_dets1, 'parallel': mean_dets2})
