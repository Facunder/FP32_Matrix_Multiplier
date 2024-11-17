# 方法：
向量乘法器  
——FP32乘法器  
————尾数乘: Radix-4 Booth乘法器  
——————部分积压缩: Wallace Tree  
——————最终加法: SQRT Carry Select Adder  
———加法数: 16->8->4->2->1流水  

# 测试:
./src/tb/tb_test_matrix_multiply.v: 矩阵乘测试，可以外部生成再读入data.txt测试  
./src/tb/tb_FP32Vector16Multiplier.v: 向量乘测试  
./src/tb/tb_FP32Multiplier.v: FP32乘法器测试  
./src/tb/tb_Radix4BoothMultiplier.v: FP32尾数拓展后乘积的24位无符号(先转有符号实现)基4Booth乘法器测试  
./src/tb/tb_FP32Adder.v: FP32加法器测试  

# 使用：
在sim/文件夹下:  
`vcs -R -full64 +v2k -fsdb +define+FSDB -sverilog -f file_list.f -l run.log`

 
