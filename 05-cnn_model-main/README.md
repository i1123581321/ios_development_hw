# cnn_model

依赖见 requirements.txt，系统为 Windows 10，python 版本 3.7.9，使用 pytorch 无 gpu 的版本

转换流程为先将 pytorch 的模型转换为 onnx 格式，然后再将其转换为 mlmodel 格式，具体过程见 main.py