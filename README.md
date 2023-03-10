# A standardized risk-based framework for the evaluation of treatment effect heterogeneity

## How to install

Clone the repository and open `HteFramework` project in RStudio. Make sure
package `renv` is installed. From the R-console run:

```r
renv::restore()
```
This will recreate the R environment of our analyses which is crucial for the
extraction of the LEGEND cohorts. Install the package using:

```r
devtools::install()
```
Make sure to skip any updates, if suggested.


## Reproduce the main analyses

To reproduce the main analyses open the file [settings/Run.R](https://github.com/mi-erasmusmc/HteFramework/blob/main/settings/Run.R) and follow the
instructions.
