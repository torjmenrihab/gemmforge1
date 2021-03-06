from gemmforge.vm import VM
from ..matrix import DenseMatrix
from abc import ABC, abstractmethod

from ..matrix.sp_mock import MockMatrix


class AbstractUniOpThreadPolicy(ABC):
  def __init__(self,
               vm: VM,
               num_threads: int,
               op1: MockMatrix):
    self._vm = vm
    self._num_threads = num_threads
    self._op1 = op1

  @abstractmethod
  def get_num_ops_per_block(self):
    pass


class AbstractBinaryOpThreadPolicy(AbstractUniOpThreadPolicy):
  def __init__(self,
               vm: VM,
               num_threads: int,
               op1: MockMatrix,
               op2: MockMatrix):
    super().__init__(vm, num_threads, op1)
    self._op2 = op2

  @abstractmethod
  def get_num_ops_per_block(self):
    pass


class AbstractGemmLikeThreadPolicy(AbstractBinaryOpThreadPolicy):
  def __init__(self,
               vm: VM,
               reals_per_op: int,
               num_threads: int,
               op1: MockMatrix,
               op2: MockMatrix,
               res: MockMatrix):
    super().__init__(vm, num_threads, op1, op2)
    self._reals_per_op = reals_per_op
    self._res = res

  @abstractmethod
  def get_num_ops_per_block(self):
    pass
