### 04 factorNormalization

1. This module receives alpha loadings from the "03 dailyFactorCreation" module, which is a three dimensional matrix, with its first dimension as dates, second dimension as stocks and third dimension as factors.

2. This module's process contains two steps:

   - Process extreme values

     The factor loadings can be really big and away from the median, so we use Windsor method to compress the values whose absolute values are bigger than a setting value to certain ranges.

     $\begin{equation}\widetilde{x_i}=\begin{cases}x_M+n\times D_{MAD}, &{if\quad x_i>x_M+n\times D_{MAD}}\\x_M-n\times D_{MAD}, &{if\quad x_i<x_M-n\times D_{MAD}}\\x_i, &{else}\end{cases}\end{equation}$ 

     $x_i$ is the loading on stock $i$  of a factor on a single date;

     $x_M$ is the median of cross-sectional loading over stocks of the factor;

     $D_{MAD}$ is the median of the sequence $|x_i-x_M|$ .

   - Normalize

     Using z-score to normalize the processed factor loadings. Record the mean, median, skewness and kurtosis of the distribution for further examination.

3. Function: factorNormalization

   - Variable

     factorCube, a three dimensional matrix, with its first dimension as dates, second dimension as stocks and third dimension as factors.

     Already calculated by Evan Hu.

   - Return

     Processed three dimensional factor loadings.

   - Save

     normFactor: the processed factor loadings;

     meanMatrix: the all-time mean of the distribution for all factors;

     medianMatrix: the all-time median of the distribution for all factors;

     skewnessMatrix: the all-time skewness of the distribution for all factors;

     kurtosisMatrix: the all-time kurtosis of the distribution for all factors;

     date.fig: the histogram of the normFactor distribution on all dates.