
# StackSplit                            [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5802051.svg)](https://doi.org/10.5281/zenodo.5802051) [![View michaelgrund/stacksplit on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://de.mathworks.com/matlabcentral/fileexchange/62402-michaelgrund-stacksplit)

### A plugin for multi-event shear wave splitting analyses in SplitLab

StackSplit is a plugin for the MATLAB toolbox [SplitLab](http://splitting.gm.univ-montp2.fr/) ([**_Wüstefeld et al., 2008_**](https://www.sciencedirect.com/science/article/pii/S0098300407001859)) which allows applying multi-event techniques for shear wave splitting measurements (SWS) directly within the main program.

For details regarding installation and usage, see the [UserGuide](https://github.com/michaelgrund/stacksplit/blob/main/StackSplit/Doc/StackSplit_userguide.md).

Citation
--------

If you make use of StackSplit in your work, please acknowledge my paper in which the program is described:

- **_Grund, M. (2017)_**, StackSplit - a plugin for multi-event shear wave splitting analyses in SplitLab, *Computers & Geosciences*, 105, 43-50, https://doi.org/10.1016/j.cageo.2017.04.015.

Optionally, you can also cite the [Zenodo DOI](https://zenodo.org/record/5802051#) given above, which refers to the latest version of this GitHub repository.

Which stacking methods are available?
-------------------------------------

StackSplit grants easy access to four stacking schemes with which single SWS measurements made with SplitLab can be processed:

1. **WS**: stacking of error surfaces, normalized on the minimum/maximum (depending on input) of each single surface ([**_Wolfe & Silver, 1998_**](https://doi.org/10.1029/97JB02023))

2. **RH**: modified WS method with weight depending on the SNR of each measurement and normalization regarding the available backazimuth directions ([**_Restivo & Helffrich, 1999_**](https://doi.org/10.1046/j.1365-246x.1999.00845.x))

3. **no weight**: stacking of error surfaces without weighting following the PhD thesis of [**_Wüstefeld (2007)_**](http://splitting.gm.univ-montp2.fr/)

4. **SIMW**: simultaneous inversion of multiple waveforms in the time domain ([**_Roy et al., 2017_**](https://doi.org/10.1093/gji/ggw470))

![fig4github](https://user-images.githubusercontent.com/23025878/56716351-6d3d2a80-673a-11e9-8b34-2191c119d780.png)

Compatibility with SplitLab and MATLAB versions
-----------------------------------------------

|StackSplit|SplitLab|MATLAB|
|---|---|---|
|dev ([main branch](https://github.com/michaelgrund/stacksplit))|[1.2.1](https://robporritt.wordpress.com/software/), [1.0.5](http://splitting.gm.univ-montp2.fr/) (not tested)|>= [2020a](https://mathworks.com/help/releases/R2020a/index.html) (< 2020a might work, but not tested yet)|
|[v3.0](https://github.com/michaelgrund/stacksplit/releases/tag/v3.0) (latest release)|[1.2.1](https://robporritt.wordpress.com/software/), [1.0.5](http://splitting.gm.univ-montp2.fr/) (not tested)|>= [2020a](https://mathworks.com/help/releases/R2020a/index.html) (< 2020a might work, but not tested yet)|
|[v2.0](https://github.com/michaelgrund/stacksplit/releases/tag/v2.0)|[1.2.1](https://robporritt.wordpress.com/software/), [1.0.5](http://splitting.gm.univ-montp2.fr/)|>= [2014b](https://mathworks.com/company/newsroom/mathworks-introduces-new-features-in-matlab-and-simulink.html) (tested up to and including [2018b](https://mathworks.com/help/releases/R2018b/index.html))|
|[v1.0](https://github.com/michaelgrund/stacksplit/releases/tag/v1.0)|[1.2.1](https://robporritt.wordpress.com/software/), [1.0.5](http://splitting.gm.univ-montp2.fr/)|<= [2014a](https://mathworks.com/company/newsroom/mathworks-announces-release-2014a-of-the-matlab-and-simulink-product-families.html)|

For details regarding the different StackSplit versions, see the [Changelog](https://github.com/michaelgrund/stacksplit/blob/main/changelog.md).

Contributing
------------

Did you find a bug or have suggestions for improvements? Simply open a new [issue](https://github.com/michaelgrund/stacksplit/issues) or [pull request](https://github.com/michaelgrund/stacksplit/pulls) here on GitHub.

Related topics
--------------

- Most recent SplitLab version (not compatible with StackSplit yet): https://github.com/IPGP/splitlab

- Shear wave splitting analysis in Python (based on SplitLab): https://github.com/paudetseis/SplitPy

- Shear wave splitting analysis in Julia: https://github.com/anowacki/SeisSplit.jl

References
----------

- **_Restivo, A. & Helffrich, G. (1999)_**, Teleseismic shear wave splitting measurements in noisy environments, Geophysical Journal International 137, 821-830, https://doi.org/10.1046/j.1365-246x.1999.00845.x.
- **_Roy, C., Winter, A., Ritter, J. R. R., Schweitzer, J. (2017)_**, On the improvement of SKS splitting measurements by the simultaneous inversion of multiple waveforms (SIMW), Geophysical Journal International, 208, 1508–1523, https://doi.org/10.1093/gji/ggw470.
- **_Wolfe, C. J. & Silver, P. G. (1998)_**, Seismic anisotropy of oceanic upper mantle: Shear wave splitting methodologies and observations, Journal of Geophysical Research 103(B1), 749-771, https://doi.org/10.1029/97JB02023.
- **_Wüstefeld, A. (2007)_**, Methods and applications of shear wave splitting: The East European Craton. Ph.D. thesis, Univ. de Montpellier, France, http://splitting.gm.univ-montp2.fr/.
- **_Wüstefeld, A., Bokelmann, G., Zaroli, C., Barruol, G. (2008)_**, SplitLab: A shear-wave splitting environment in Matlab, Computers & Geosciences 34, 515–528, https://doi.org/10.1016/j.cageo.2007.08.002.
