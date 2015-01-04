run: dgemm_cublas_kernels.ptx ptx2kernel.pl
	@echo Converting dgemm_cublas_kernels.ptx ...
	./ptx2kernel.pl dgemm_cublas_kernels.ptx > dgemm_cublas_kernels.cu
	@echo Converting finished. See dgemm_cublas_kernels.cu for the converted kernels.

clean:
	rm -rf dgemm_cublas_kernels.cu

.PHONY:
	run clean
