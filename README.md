<p align="center">
  <img src="https://github.com/sergiobarra/SFCTMN/blob/single_channel_IEEE80211ax_spatial_reuse/sfctmn_logo_sr.png" width="340" height="100">
</p>

# 11ax Spatial Reuse in the Spatial Flexible Continuous Time Markov Network (11axSR-SFCTMN)

Continuous Time Markov Network (CTMN) based framework for analyzing Wireless Local Area Networks (WLANs) implementing the IEEE 802.11ax OBSS PD-based Spatial Reuse operation. 

**Disclaimer:** single channel transmissions are only supported at this development stage.

Details on the IEEE 802.11ax SR implementation can be found in Francesc Wilhelmi, Boris Bellalta, Cristina Cano, Sergio Barrachina-Mu\~noz \& Ioannis Selinis. *Spatial Reuse in the IEEE 802.11ax:Current status, Challenges and Research Opportunities.* -, 2019. Available [here](https://arxiv.org/).

Details on the SFCTMN framework can be found in S. Barrachina-Muñoz, F. Wilhelmi, and B. Bellalta. *Performance of Dynamic Channel Bonding in Spatially Distributed High Density WLANs.* arXiv preprint arXiv:1801.00594, 2018. Available [here](https://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=8642923).

### Installation

Just [Matlab](https://www.mathworks.com/) is required.

### Usage
 
 * Set the system WLANs' scenario and configuration in files ```wlans_input.csv```, ```constants_script.m``` and ```system_conf.m```. 
 * Run main file ```main_sfctmn.m``` to display the analysis results. Add to the Matlab path any necessary files.
 * *Alternatively, use ```function_main_sftcmn.m```, which receives the 'wlan' object as an input and returns the throughput per WLAN.*

The general flowchart of the framework is detailed in the following image:
 
<p align="center">
<img src="https://github.com/sergiobarra/SFCTMN/blob/master/documentation/General%20flowchart.png" width="700" height="300">
<br>
<em>SFCTMN's flowchart.</em>
</p>

Next, we show an example of input to use the 11ax SR in the SFCTMN. First of all, the input must contain additional parameters regarding the SR operation.

| code | primary | left ch | right ch | tx_power | cca | lambda | x_ap | y_ap | z_ap | x_sta | y_sta | z_sta | legacy_node | cw  | non_srg_activated | srg | non_srg_obss_pd | srg_obss_pd | tx_pwr_ref |
|------|---------|---------|----------|----------|-----|--------|------|------|------|-------|-------|-------|-------------|-----|-------------------|-----|-----------------|-------------|------------|
| 1    | 1       | 1       | 1        | 20       | -82 | 14815  | 0    | 4    | 0    | 0     | 0     | 0     | 0           | 512 | 1                 | 0   | -78             | -82         | 21         |
| 2    | 1       | 1       | 1        | 20       | -82 | 14815  | 6    | 4    | 0    | 6     | 8     | 0     | 0           | 512 | 0                 | 0   | -78             | -82         | 21         |

Notice that new fields are:
* **non_srg_activated:** indicates whether the WLAN applies the SR operation or not.
* **srg:** indicated the Spatial Reuse Group (SRG) that the WLAN belongs to.
* **non_srg_obss_pd:** indicates the non-SRG OBSS PD threshold (in dBm).
* **srg_obss_pd:** indicates the SRG OBSS PD threshold (in dBm).
* **tx_pwr_ref:** indicates the transmission power reference (in dBm). According to the 11ax amendment, this value can be 21 or 25 dBm, according to the device's capabilities.

The previous input generates the following output (provided that the default 11ax parameters are used):
<p align="center">
<img src="https://github.com/sergiobarra/SFCTMN/blob/single_channel_IEEE80211ax_spatial_reuse/documentation/example_output_sr.png" width="580" height="460">
  <br>
    <em>Example of 11ax SR in SFCTMN. (a) WLAN scenario, (b) Channels allocation, (c) CTMN.</em>
</p>

### Support

These [slides](https://github.com/sergiobarra/SFCTMN/blob/master/documentation/sfctmn_introductory_presentation.pdf) by Francesc Wilhelmi contain a basic introduction to SFCTMN.

You can upload any issue to this repository in case you have doubts or find an error related to the implementation of the 11ax Spatial Reuse Operation. Alternatively, you can also send me an email to [francisco.wilhelmi@upf.edu](francisco.wilhelmi@upf.edu).

### Contributing

We are always open to new contributions. Just drop me an email at sergio.barrachina@upf.edu

### Acknowledgements

This work has been partially supported by a Gift from the Cisco University Research Program (CG\#890107, Towards Deterministic Channel Access in High-Density WLANs) Fund, a corporate advised fund of Silicon Valley Community Foundation.

