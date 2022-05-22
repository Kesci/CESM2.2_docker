# CESM2.2_docker
## 本项目说明
用来安装气象模式 CESM_2.2
## 配置文件
该模式在使用前，需要编译，编译高度依赖两个配置，因此，项目中附带两个参考配置。具体请根据情况调整。两个文件只作参考之用。
## 注意事项
- HDF5 的安装过程启用了并行安装，安装前默认有一些测试流程，用 16 核心以下的机器构建镜像会导致失败
## 测试方法
cd /opt/cesm/my_cesm_sandbox/cime/scripts
./create_newcase --case FHIST_f19 --res f19_f19 --compset FHIST --run-unsupported --compiler gnu --mach ubuntu
cd FHIST_f19
./case.setup
./case.build