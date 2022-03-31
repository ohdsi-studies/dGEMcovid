dGEM (Decentralized Algorithm for Generalized Linear Mixed Model)
=============

<img src="https://img.shields.io/badge/Study%20Status-Repo%20Created-lightgray.svg" alt="Study Status: Repo Created">

- Analytics use case(s): **Patient-Level Prediction**
- Study type: **Clinical Application**
- Tags: **COVID-19**
- Study lead: **add name**
- Study lead forums tag: **[add_username](https://forums.ohdsi.org/u/add_username)**
- Study start date: **month year**
- Study end date: **month year**
- Protocol: **[Here](https://github.com/ohdsi-studies/dGEMcovid/blob/master/extras/dGEM_Decentralized_Algorithm_for_Generalized_Linear_Mixed_Model_v0.3.docx)**
- Publications: **-**
- Results explorer: **-**

This study implements a novel one-shot distributed method, dGEM, that can efficiently combine heterogeneous data while preserving the privacy of protected patient-level and hospital-level health information and calculate effect estimates that are equivalent to pooling the data (highly accurate).  We would like to implement the dGEM method across the OHDSI network for the hospital profiling problem (see Figure 1) to i) demonstrate the applicability of the proposed dGEM method and ii) investigate the effect estimates of patient- and hospital-level factors of COVID-19 mortality. 

## Background
Hospital profiling, which evaluates how much patient outcomes are influenced by the hospital, allows for a quantitative comparison of healthcare providers' quality of care for certain clinical outcomes (e.g., mortality rate). Given the novelty of COVID-19, the study of hospital profiling with COVID-19 specific data is of great interest. The OHDSI network contains a large number of datasets with COVID-19 data and when combined the COVID-19 data are rather large. However, due to privacy issues, it is not possible to pool the datasets during multi-site collaboration. For example, sensitive individual patient data (IPD) including the patient's identity, diagnoses, and treatments are usually not allowed under privacy regulation to be shared across networks. Additionally, for hospital profiling, hospital-level encryption is also needed to keep the hospital health information safe.  

In this study we propose implementing a novel one-shot decentralized algorithm for generalized linear mixed effects models (dGEM). To the best of our knowledge, dGEM is the first real-world hospital profiling solution to account for heterogeneity in multi-site data in a one-shot distributed manner. The proposed algorithm (i.e., dGEM) is based on the generalized linear mixed effect models (GLMM). The dGEM method assumes common fixed-effects of the factors (i.e., patient- and hospital-level factors) and hospital-specific random effects (i.e., random slopes and intercepts) to calculate the directly standardized COVID-19 mortality rates1 for hospital profiling. The proposed method achieves both patient-level privacy protection by only requiring aggregated data; additionally, the hospital-level encryption is accomplished since each hospital can only access their own standardized mortality rate, and the ranking of the hospitals is conducted anonymously using dGEM algorithm.

The aim of this study is to test the performance of the dGEM method for distributed network analyses of hospital profiling on the COVID-19 mortality rate within the OHDSI network. We will implement the dGEM methodology across the COVID-19 datasets within the OHDSI network for the use case of hospital profiling of COVID-19 mortality. This will demonstrate feasibility and enable us to estimate the effect of various factors of COVID-19 mortality.  However, the hospital rankings will be presented anonymously (working ID 1, working ID 2, …) and will not show the names of the OHDSI collaborators’ datasets.


Suggested Requirements
===================
- R studio (https://rstudio.com)
- Java runtime environment

Instructions to Install and Execute from GitHub
========================================================

- [Instructions to install the study library from GitHub using Renv](STUDY-PACKAGE-SETUP.md)
- [Instructions to execute the study ](STUDY-PACKAGE-EXECUTE.md)

Results
========================================================
Once executed you will find multiple json/csv files in the specified outputFolder.
