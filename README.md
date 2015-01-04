PTX2Kernel: Converting PTX Code into Compilable Kernels
=============

Overview
-------------

The PTX2Kernel convertor is designed for converting embedded PTX code into editable and compilable CUDA C kernels without efficiency loss. The converted kernels have legal CUDA C interfaces, and PTX instructions are inlined in the CUDA kernel bodies. With the PTX2Kernel convertor, it is much easier for programmers to make optimized kernel versions in case that only embedded PTX code is available.

Note that PTX2Kernel is not for recovering the CUDA C source code of the kernels from the PTX code.

Example
-------------

PTX code can be extracted from binary files by the cuobjdump tool. Following is a piece of the GEMM code extraced from the cuBLAS library:

    .visible .entry _Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii(
    .param .u64 _Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii_param_0,
    .param .u64 _Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii_param_1,
    .param .u64 _Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii_param_2,
    .param .u32 _Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii_param_3,
    .param .u32 _Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii_param_4,
    .param .u32 _Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii_param_5,
    .param .u32 _Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii_param_6,
    .param .u32 _Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii_param_7,
    .param .u32 _Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii_param_8,
    .param .f64 _Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii_param_9,
    .param .f64 _Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii_param_10,
    .param .u32 _Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii_param_11,
    .param .u32 _Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii_param_12
    )
    {
    .reg .pred %p<4>;
    .reg .s32 %r<138>;
    .reg .s64 %rd<60>;
    .reg .f64 %fd<918>;
 
            .shared .align 8 .b8 _Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii$__cuda_local_var_40142_36_non_const_Bb[8320];
 
            .shared .align 8 .b8 _Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii$__cuda_local_var_40143_36_non_const_Abs[8704];
 
    ld.param.u32 %r18, [_Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii_param_5];
    ld.param.u32 %r19, [_Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii_param_6];
    ld.param.u32 %r20, [_Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii_param_7];
    ld.param.f64 %fd76, [_Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii_param_10];
    ld.param.u32 %r62, [_Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii_param_11];
    ld.param.u32 %r63, [_Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii_param_12];
    mov.u32 %r64, %tid.x;
    mov.u32 %r65, %ctaid.y;
    shl.b32 %r1, %r65, 6;
    mov.u32 %r66, %tid.y;
    shl.b32 %r67, %r66, 6;
    add.s32 %r68, %r67, %r64;
    shr.s32 %r69, %r68, 31;
    shr.u32 %r70, %r69, 28;
    add.s32 %r71, %r68, %r70;
    ......

Take above code as input, the PTX2Kernel convertor generate a legal CUDA C kernel:

    // void fermiDgemm_v2_kernel_val<true, false, false>(double*, double const*, double const*, int, int, int, int, int, int, double, double, int, int)
    __global__
    void fermiDgemm_v2_kernel_val(double* param_0, double const* param_1, double const* param_2, int param_3, int param_4, int param_5, int param_6, int param_7, int param_8, double param_9, double param_10, int param_11, int param_12)
    {
            asm(".reg .pred p<4>;");
            asm(".reg .s32 r<138>;");
            asm(".reg .s64 rd<60>;");
            asm(".reg .f64 fd<918>;");
 
            asm(".shared .align 8 .b8 _Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii$__cuda_local_var_40142_36_non_const_Bb[8320];");
 
            asm(".shared .align 8 .b8 _Z24fermiDgemm_v2_kernel_valILb1ELb0ELb0EEvPdPKdS2_iiiiiiddii$__cuda_local_var_40143_36_non_const_Abs[8704];");
 
            asm("mov.u32 r18, %0;"::"r"(param_5));
            asm("mov.u32 r19, %0;"::"r"(param_6));
            asm("mov.u32 r20, %0;"::"r"(param_7));
            asm("mov.f64 fd76, %0;"::"d"(param_10));
            asm("mov.u32 r62, %0;"::"r"(param_11));
            asm("mov.u32 r63, %0;"::"r"(param_12));
            asm("mov.u32 r64, %tid.x;");
            asm("mov.u32 r65, %ctaid.y;");
            asm("shl.b32 r1, r65, 6;");
            asm("mov.u32 r66, %tid.y;");
            asm("shl.b32 r67, r66, 6;");
            asm("add.s32 r68, r67, r64;");
            asm("shr.s32 r69, r68, 31;");
            asm("shr.u32 r70, r69, 28;");
            asm("add.s32 r71, r68, r70;");
            ......

Now it is much easier for programmers to modify ( adding new parameters, disable blocks, adding new branches, or any optimization ) and re-compile this kernel.
