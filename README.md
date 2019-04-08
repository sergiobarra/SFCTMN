<p align="center">
  <img src="https://github.com/sergiobarra/SFCTMN/blob/master/sfctmn_logo_sr.png" width="340" height="100">
</p>

# 11ax Spatial Reuse in the Spatial Flexible Continuous Time Markov Network (11axSR-SFCTMN)

Continuous Time Markov Network (CTMN) based framework for analyzing Wireless Local Area Networks (WLANs) implementing the IEEE 802.11ax OBSS PD-based Spatial Reuse operation. Single channel transmissions are only supported.

Details on the IEEE 802.11ax SR implementation can be found at [Francesc Wilhelmi, Boris Bellalta, Cristina Cano, Sergio Barrachina-Mu\~noz \& Ioannis Selinis. Spatial Reuse in the IEEE 802.11ax:Current status, Challenges and Research Opportunities. -, 2019.](https://arxiv.org/)

Details on the framework can be found at [S. Barrachina-Muñoz, F. Wilhelmi, and B. Bellalta. Performance of Dynamic Channel Bonding in Spatially Distributed High Density WLANs. arXiv preprint arXiv:1801.00594, 2018.](https://arxiv.org/pdf/1801.00594.pdf)

### Installation

Just [Matlab](https://www.mathworks.com/) is required.

### Usage
 
 * Set the system WLANs' scenario and configuration in files ```wlans_input.csv```, ```constants_script.m``` and ```system_conf.m```. 
 * Run main file ```main_sfctmn.m``` to display the analysis results. Add to the Matlab path any necessary files.
 * (*) New DCB policies may be defined in file ```apply_dsa_policy.m```.
 
 <p align="center">
<img src="https://github.com/sergiobarra/SFCTMN/blob/master/documentation/General%20flowchart.png" width="700" height="300">
</p>

 * See an example scenario below
 <p align="center">
<img src="https://github.com/sergiobarra/SFCTMN/blob/master/documentation/sfctmn_ctmn_example.png" width="380" height="300">
</p>

### Support

These [slides](https://github.com/sergiobarra/SFCTMN/blob/master/documentation/sfctmn_introductory_presentation.pdf) by Francesc Wilhelmi contain a basic introduction to SFCTMN

You can contact me for any issue you may have when using the SFCTMN framework at sergio.barrachina@upf.edu

### Contributing

We are always open to new contributions. Just drop me an email at sergio.barrachina@upf.edu

### Acknowledgements

This work has been partially supported by a Gift from the Cisco University Research Program (CG\#890107, Towards Deterministic Channel Access in High-Density WLANs) Fund, a corporate advised fund of Silicon Valley Community Foundation.

