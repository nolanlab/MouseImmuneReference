# MouseImmuneReference
A reference map of the mouse Immune System

========

# Installation


Open an R session, type the following command and select a CRAN mirror when prompted.

`install.packages("devtools")`

Once the devtools package has been installed type the following commands in your R session

```
library(devtools)
install_github("nolanlab/MouseImmuneReference")
```

# Usage

Download the data file available [here](http://www.cytobank.org/nolanlab/reports/Spitzer2015.html) and save it anywhere on your computer. Launch the MouseImmuneReference GUI by typing the following commands in an R session

```
library(MouseImmuneReference)
MouseImmuneReference.run()
```
When you launch the GUI you will be prompted to select the data file you just downloaded. After that a browser window will pop-up with the GUI running inside. The data will take a minute or so to load. When the data loading process is completed you will see a list of markers appearing in the right part of the interface. To quit the GUI simply press ESC in your R session.


## Explore the maps

This is a rundown of what the operation of the differnent controls:

1. **Choose a graph**: This dropdown allows you to select the map you want to visualize.
2. **Nodes color**: use this dataset to color the nodes according to the expression of a specific marker, or with "Default" colors (unsupervised clusters:Blue, landmark populations:Red).
3. **Color scaling**: select whether you want the color scale of the nodes to be calculated globally for the whole dataset, or locally for the currently visualized graph.
4. **Nodes size**: select whether you want the size of the nodes to be proportional to the number of cells in each cluster. Presently the size scale is calculated across the entire dataset.
5. **Display edges**: select whether you want to display all the edges in the graph, or only the highest scoring one for each cluster. Even you if you are displaying all the edges you can visualize the highest scoring one for an individual cluster by hovering the mouse over the node.
6. **Reset graph**: this button will reset the graph to its initial position, which is intended to display most of the nodes in a single image
7. **Toggle landmark labels**: toggle the display of the landmark labels on/off
8. **Toggle cluster labels**: toggle the display of the cluster labels on/off
9. **Markers to plot in cluster view**: one of the most useful ways to inspect a cluster is to plot the distribution of expression values for the cells that comprise the cluster as compared to the cells that define the landmark nodes the cluster is connected to. This can help you understand what is similar and what is different between a cluster and a landmark population. Using this box you can select the markers you want to inspect. To generate the actual plot simply click on a cluster node. A plot of the markers distributions will then appear in the lower half of the window. The figure will contains multiple subplots, one for each marker. Each subplot consists of a distribution of expression values for the cells in the cluster and the cells in all the landmark nodes the cluster is connected to. The different distribution can be distinguished by line color, with a legend to the right of each plot.






