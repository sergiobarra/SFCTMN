![alt text](https://github.com/sergiobarra/SFCTMN/blob/master/sfctmn_logo.png)

# Spatial Flexible Continuous Time Markov Network (SFCTMN)

Continuous Time Markov Network (CTMN) based framework for analyzing Wireless Local Area Networks (WLANs) implementing Dynamic Channel Bonding (DCB) policies in spatially distributed scenarios, where WLANs are not required to be within the carrier sense range of each other.
Details on the framework can be found at [S. Barrachina-Muñoz, F. Wilhelmi, and B. Bellalta. Performance of Dynamic Channel Bonding in Spatially Distributed High Density WLANs. arXiv preprint arXiv:1801.00594, 2018.](https://arxiv.org/pdf/1801.00594.pdf)

### Installation

Just [Matlab](https://www.mathworks.com/) is required.

### Usage
 
 * Set the system WLANs' scenario and configuration in files ```wlans_input.csv```, ```constants_script.m``` and ```system_conf.m```. 
 * Run main file ```main_sfctmn.m``` to display the analysis results.
 * (*) New DCB policies may be defined in file ```apply_dsa_policy.m```.
 
### Support
You can contact me for any issue you may have when using the SFCTMN framework.

### Contributing
I am always open to new contributions. Just drop me an email at sergio.barrachina@upf.edu

![alt text](https://github.com/sergiobarra/SFCTMN/blob/master/documentation/General%20flowchart.png)
