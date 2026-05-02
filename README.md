# FinalAssignment
This is the work for the final assignment

## Project Description
The goal of this project is to analyze 2017 EVS Data, specially focused on beliefs in the EU on the impact on mothers working on their children and hiring preferences by employers when jobs are scarce (citizens vs immigrants). 

The data was pulled from https://search.gesis.org/research_data/ZA7500 and then manipulated in another repo: https://github.com/medward7/Assignment2. Data used for analysis is the output dataset located here: https://github.com/medward7/Assignment2/blob/main/data_output/ZA7500_subset.csv.

I downloaded the STATA dataset due to its smaller size. 

## Explanation of Repo
This repository has a basic structure with the following folders:
- scripts: contains R scripts. They are numbered so they can be run in order. The templates for reports are in this folder also.
- data_output: Contains data used to generate graphs for the general report and the country specific reports. This is not raw data, but data that has been cleaned and merged. The country level reports do not use this data.
- batch_reports: Contains reports for all countries available in the 2017 data (36). These reports are generated using the template in the scripts folder.
- er_reports: Contains reports on data aggregated from all 36 countries, including a statistical version (includes code) and a non-statistical version (no code, just graphs and interpretations).
- README: Contains organization of repo, main findings, and session info

To make code work, the downloaded data needs to be in the main folder of the repo, and the scripts need to be run in order.

## Main Findings
For more on main findings, please see the shinyApp and reports. 

## Session Info
```{r }
sessionInfo()

R version 4.5.2 (2025-10-31)
Platform: x86_64-apple-darwin20
Running under: macOS Sonoma 14.8.4

Matrix products: default
BLAS:   /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib 
LAPACK: /Library/Frameworks/R.framework/Versions/4.5-x86_64/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.1

locale:
[1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

time zone: America/New_York
tzcode source: internal

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

loaded via a namespace (and not attached):
[1] compiler_4.5.2 tools_4.5.2   
R version 4.5.2 (2025-10-31) -- "[Not] Part in a Rumble"
Copyright (C) 2025 The R Foundation for Statistical Computing
Platform: x86_64-apple-darwin20

RStudio 2026.01.1+403 "Apple Blossom" Release (0e924abb984501b0d66b204ea06b60fc7813275a, 2026-02-04) for macOS
Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) RStudio/2026.01.1+403 Chrome/140.0.7339.249 Electron/38.7.2 Safari/537.36, Quarto 1.8.25
```

For any questions, contact at medward7@umd.edu
