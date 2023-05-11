# GRACE Gravity Space Missions Toolkit

This is a toolbox for processing GRACE (Gravity Recovery and Climate Experiment) and GRACE-FO mission level-1 data products. 

1. This work puts the GRACE missions in a "gradiometer-mode" to estimate the gravity gradient of the Earth directly from measurements through a series of spatiotemporal transformations. 
2. The software here can be used for other research work on the level-1 data.
4. Process-GM computes derives the gravity gradient. It's output are point cloud gradiometer measurements and need to be gridded. 
5. GM_facade calls the routines requires to compute the gradient. There are many different modes for computing the gradient like..
              a) Mission selection, single satellite mode, dual satellite mode, using accelerometer measurements, using POD accelerations... etc
              b) These are all selected by an input structure that gets parsed into GM_facade. 
7. GMT-plotting derives publication quality visualizations with hillshading put in automatically. Just requires xyz geospatial data. 
8. The gridding and visualization routines will be released soon. 

--------------------------------------------------------------------------

Written by Nikeet Pandit. Copyright 2023

--------------------------------------------------------------------------

Advances the concept here: Peidou, A & Pagiatakis, S (2020). The new concept of GRACE gradiometry and the unravelling of the mystery of
stripes [Doctoral dissertation, York University]. YorkSpace. https://yorkspace.library.yorku.ca/xmlui/handle/10315/37695
