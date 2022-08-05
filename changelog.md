# Changelog

## Release [v3.0](https://github.com/michaelgrund/stacksplit/releases/tag/v3.0) (2021-12-23) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5802051.svg)](https://doi.org/10.5281/zenodo.5802051)

* adjusted and updated several StackSplit functions to work on newer MATLAB versions (>=2020a)
* removed or replaced deprecated built-in MATLAB functions 
* fixed start time extraction by SplitLab (for details see [**_Fröhlich et al., 2022_**](https://doi.org/10.4401/ag-8781))
* added warning message box if non-nulls and nulls are selected together for stacking (which is not really reasonable)
* added warning message box if current screen resolution does not allow to display StackSplit's main panel properly:
  * Solution for **Windows 10**: under *Settings* => *System* => *Display* => *Scale and Layout* => *Change the size of text, apps, and other items*
  the selection sometimes is set to a value different from 100% (e.g. 150%)
  which effectively reduces your screen size in pixels. Set it to 125% or
  better 100% and check again, mostly then the panel fits on the screen.
  
**Contributors**: [Michael Grund](https://github.com/michaelgrund), [Yvonne Fröhlich](https://github.com/yvonnefroehlich)

## Release [v2.0](https://github.com/michaelgrund/stacksplit/releases/tag/v2.0) (2019-06-28)

* adjusted several functions to work also on MATLAB 2018a and b
* now results are additionally saved in a text-file which can be used directly in GMT (Generic Mapping Tools)

**Contributors**: [Michael Grund](https://github.com/michaelgrund)

## Release [v1.0](https://github.com/michaelgrund/stacksplit/releases/tag/v1.0) (2017-04-04) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.464385.svg)](https://doi.org/10.5281/zenodo.464385)

StackSplit is now available for download.

**Contributors**: [Michael Grund](https://github.com/michaelgrund)
