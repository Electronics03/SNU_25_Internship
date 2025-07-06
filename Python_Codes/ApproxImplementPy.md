# Softmax Function Approximation Implement in Python

This document is based on [[1]](#references). 
It implements and explains the paper's proposed approach for approximating the Softmax function in a hardware-friendly way.

This design removes expensive operations like division and exponential functions with simple, modular components using shifts, additions, and look-up tables (LUTs).

Here, we show the approximation formula, the modular design strategy, individual module implementations (LUT and RU), and finally compare the approximation results to the standard Softmax output.

## References

[1] Q.-X. Wu, C.-T. Huang, S.-S. Teng, J.-M. Lu, and M.-D. Shieh,  
“A Low-complexity and Reconfigurable Design for Nonlinear Function Approximation in Transformers,”  
in Proc. IEEE International Symposium on Circuits and Systems (ISCAS), 2025.