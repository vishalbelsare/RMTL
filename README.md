# RMTL
An R Library for Multi-task Learning

# Description 
This package provides an efficient implementation of regularized multi-task learning comprising 10 algorithms applicable for regression, classification, joint feature selection, task clustering, low-rank learning, sparse learning and network incorporation. All algorithms are implemented basd on the accelerated gradient descent method and feature a complexity of O(1/k^2). Sparse model structure is induced by the solving the proximal operator.

# Required Packages
Three packages have to be instaled in advanced:‘psych’, ‘corpcor’ and ‘fields’. You can install them using the following codes.
```R
install.packages("psych")
install.packages("corpcor")
install.packages("fields")
```

# Installation
1) Install directly from the github
```R
install.packages("devtools")
library("devtools")
install_github("transbioZI/RMTL")
```

2) Install from the downloaded package
```shell
git clone https://github.com/transbioZI/RMTL.git
R CMD build ./RMTL/
R CMD INSTALL RMTL*.tar.gz
```

# Details
Please check ["RMTL-manuel.pdf"](https://github.com/transbioZI/RMTL/blob/master/RMTL-manual.pdf) for more details.

# Reference
[Cao, Han, et al. "RMTL: An R Library for Multi-Task Learning." Bioinformatics (2018).](https://doi.org/10.1093/bioinformatics/bty831)


# Contact
If you have any question, please contact: hank9cao@gmail.com
