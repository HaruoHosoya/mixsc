# Mixture of sparse coding models: A computational model for primate face-processing system

This is an official implementation of mixture of sparse coding models [1].

# Prerequisites

* Matlab
* [SMICA](https://github.com/HaruoHosoya/smica) (Score-matching Independent Component Analysis).  
  Download, install, and place it in parallel to this code.


# Code folder structure

mixsc/                  top-level main code
    expdata/            extracts from published experimental data 
    freiwald_stimuli/   stimulus generation simulating [2]
    freiwald/           data analysis simulating [2]
    functions/          auxiliary functions
    learning/           model learning 
    preprocess/         data preprocessing
smica/                  SMICA package


# Image data

We rely on two image datasets based on [Caltech101](https://data.caltech.edu/records/mzrjq-6wc02) and [Labeled faces in the wild](http://vis-www.cs.umass.edu/lfw/) (Deep funneled version).

However, we provide preprocessed data files for our purpose:
* [face images](https://mega.nz/file/lWdVGCYR#q6S7DafcYtJU_W6OyQvET0F6HSU41Nmrq3B68kyh4JA)
* [object images](https://mega.nz/file/pHkEWZaT#hdRSzlHMpOkCcL7Pgquzc4Z1E674unhuL873b5MKgLQ)


# To reproduce the results

0) Prepare data directory.  Put the two provided image data files in your data directory.

1) Set up path. Type:

        initpath

2) Set up directories.  First modify result_dir variable and dataset_dir variable (the one used in step 0) in scr_setup_dirs.m.  Type:

        scr_setup_dirs

3) Generate image data of cartoon faces into dataset_dir.  Type:

        scr_generate_data

4) Set up image data.  Type:

        scr_setup_data

5) Build all models and save them into result_dir.  Type:

        scr_build_models
  
6) Test the built models.  Type:

        scr_test_models

7) Show figures and save them.  Type:

        scr_save_figures


# Comments

* In various parts of code, you can find "parfor"s commented out.  If you have Parallel Computing Toolbox, you may replace uncomment them and comment out "for"s next to them.

* In scr_build_models and scr_test_models, a total of 10 models are built and tested, which takes quite a bit of time.  You could skip some of them by commenting out the corresponding parts in those scripts.  



# References and contact

If you publish a paper based on this code/data, please cite [1].  If you have difficulty of downloading datasets, etc., please contact with the first author.

[1] Haruo Hosoya, Aapo Hyvärinen. A mixture of sparse coding models explaining properties of face neurons related to holistic and parts-based processing. PLoS Computational Biology, 13(7): e1005667, 2017.

[2] Winrich A Freiwald, Doris Y Tsao.  Functional compartmentalization and viewpoint generalization within the macaque face-processing system.  Science, 2010 Nov 5;330(6005):845-51.  
