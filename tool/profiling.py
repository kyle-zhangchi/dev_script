from torch_npu.profiler.profiler import analyse
import torch_npu
if __name__ == "__main__":
    analyse(profiler_path="/home/z00804445/a5/202606242009/profiling/vllmprofiling/node-25-102_173342_20260624122318056_ascend_pt/", max_process_number=128, export_type=torch_npu.profiler.ExportType.Text)
