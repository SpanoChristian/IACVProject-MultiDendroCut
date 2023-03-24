# Multi-Class Multi-Model Fitting via Dendrogram Cut
The aim of the project is to analyze the dendrogram produced by the agglomerative clustering to find optimal multi-level cut to define the best segmentation and model classes.

## Brief Description
Given a set of data contaminated by noise and outliers, multi model fitting aims at recovering multiple geometric structures from data. Typical applications can be encountered in stereo-vision where sparse correspondence can be described by a mixture of homographies (if the scene is composed by multiple planar surfaces) or multiple fundamental matrices (when the scene is dynamic and contains multiple moving objects).

Preference analysis addresses this problem by leveraging agglomerative clustering techniques in a preference space. The attained clusters correspond to structures described by a parametric model of a given class. The aim of the project is to analyze the dendrogram produced by the agglomerative clustering to find optimal multi-level cut to define the best segmentation and the model classes.
