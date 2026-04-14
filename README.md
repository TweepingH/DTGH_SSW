# DTGH_SSW
Semi-open-source code for DTGH_SSW: An area-based Optical/SAR image matching algorithm.
# 项目名称 (例如: Robust CV Algorithm for XXX)
这是一个基于区域的光学到 SAR 图像匹配方法的 MATLAB 程序。
相关代码与数据正在整理与规范中，将于论文发表后尽快发布
## ⚠️ 半开源声明 (Semi-Open Source)
为了保护核心知识产权，本项目的核心算法已通过 MATLAB Coder 编译为底层的机器码 (MEX 文件)。
- **接口与上层逻辑：** 完全开源，你可以自由查看和修改数据的预处理、后处理逻辑。
- **核心算子：** 封装在 `DTGH_SSW_mex` 中，作为黑盒提供调用。
## 系统要求
- MATLAB R2021b 或更高版本
- 操作系统：Windows 64-bit
## 快速开始 (Quick Start)
1. 克隆本仓库
2. 运行 demo 脚本
