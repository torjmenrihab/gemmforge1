from ..abstract_thread_policy import AbstractBinaryOpThreadPolicy, DenseMatrix
from gemmforge.vm import VM
from ...matrix.sp_mock import MockMatrix


class NvidiaCsaThreadPolicy(AbstractBinaryOpThreadPolicy):
  def __init__(self,
               vm: VM,
               num_threads: int,
               op1: MockMatrix,
               op2: MockMatrix):
    super().__init__(vm, num_threads, op1, op2)

  def get_num_ops_per_block(self):
    total_num_threas_per_op = self._num_threads * self._op1.get_actual_num_cols()
    max_num_regs_per_thread = 10  # Note: derived experimentally

    hw_descr = self._vm.get_hw_descr()
    mults_wrt_num_regs = hw_descr.max_reg_per_block / (total_num_threas_per_op * max_num_regs_per_thread)
    return max(int(mults_wrt_num_regs / hw_descr.max_block_per_sm), 1)
