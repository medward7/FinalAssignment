# FinalAssignment
This is the work for the final assignment. Not my best work given the time frame, so I apologize. 

## Project Description
The goal of this project is to analyze 2017 EVS Data, specially focused on beliefs in the EU on the impact on mothers working on their children and hiring preferences by employers when jobs are scarce (citizens vs immigrants). 

The data was pulled from https://search.gesis.org/research_data/ZA7500 and then manipulated in another repo: https://github.com/medward7/Assignment2. Data used for analysis is the output dataset located here: https://github.com/medward7/Assignment2/blob/main/data_output/ZA7500_subset.csv.

I downloaded the STATA dataset due to its smaller size. 

## Explanation of Repo
This repository has a basic structure with the following folders:
- SecondApp: contains the .app file and the template for the report. The folder also contain the data used for this report. You need the entire folder to replicate this app. 
- Report_Sample: Contains a sample of what the html output will look like when saved from the app
- README: Contains organization of repo, main findings, and session info

## Main Findings
For more on main findings, please see the shinyApp: https://medward7.shinyapps.io/SecondApp/

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
