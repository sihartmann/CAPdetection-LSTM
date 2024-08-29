# CAPdetection-LSTM

Sytem to detect CAP A phases and to classify the respective subtypes from sleep EEG recordings

More information can be found [here](https://doi.org/10.1109/TNSRE.2019.2934828).

## Application information
*	Version: MATLAB® R2021b
* Signal Processing Toolbox, Wavelet Toolbox, and Machine Learning Toolbox
*	Required EEG file types: .mat, .edf or .rec
*	Required annotation file types: .txt, .xml, .xlsx, or .evt
*	Required EEG channels: C4-A1 and/or C3-A2
*	Year: 2020

## Installation
Either a full MATLAB® license is needed. A standalone application using MATLAB Compiler Runtime can be requested.

Additional software needed:
* [edfread](https://au.mathworks.com/matlabcentral/fileexchange/31900-edfread) to read edf files (Do not use edfread function provided by the Signal Processing Toolbox as of R2020b)
* [export_fig](https://github.com/altmany/export_fig) to save plots
* [xml2struct](https://au.mathworks.com/matlabcentral/fileexchange/28518-xml2struct) to load .xml annotation files
* [FastICA 2.5](https://research.ics.aalto.fi/ica/fastica/code/dlcode.shtml) for cardiac artefact removal


Can be installed by adding to MATLAB file path.

## Script vs GUI
Sleep EEG files can be scored using the Graphical User Interface (GUI) or the automated script. GUI is recommended for users with limited coding experience whereas the script version is preferred when running large data sets. Each folder contains separate instructions how to start the software.

## Extracted variables

| Variables  | Description |
| ------------- | ------------- |
| ID  | subject's ID  |
| SLDUR  | total duration of NREM sleep in seconds  |
| NRAPH  | total number of A-phases  |
| APHDUR  | total duration of A-phases in seconds  |
| AVGAPHDUR  | average duration of A-phases in seconds  |
| NRAPHPH  | number of A-phases per hour of NREM sleep  |
| RAPHSL  | total duration of A-phases/total duration of NREM sleep  |
| NRA1  | total number of A1-phases  |
| NRA2  | total number of A2-phases  |
| NRA3  | total number of A3-phases  |
| A1DUR  | total duration of A1-phases in seconds  |
| A2DUR  | total duration of A2-phases in seconds  |
| A3DUR  | total duration of A3-phases in seconds  |
| AVGA1DUR  | average duration of A1-phases in seconds  |
| AVGA2DUR  | average duration of A2-phases in seconds  |
| AVGA3DUR  | average duration of A3-phases in seconds  |
| RA1APH  | total number of A1-phases/total number of A-phases  |
| RA2APH  | total number of A2-phases/total number of A-phases  |
| RA3APH  | total number of A3-phases/total number of A-phases  |
| RA1NRE  | total duration of A1-phases/total duration of NREM sleep  |
| RA2NRE  | total duration of A2-phases/total duration of NREM sleep  |
| RA3NRE  | total duration of A3-phases/total duration of NREM sleep  |
| A1IND  | A1 index (number of A1-phases per hour)  |
| A2IND  | A2 index (number of A2-phases per hour)  |
| A3IND  | A3 index (number of A3-phases per hour)  |
| NRCAP  | total number of CAP sequences  |
| CAPDUR  | total duration of CAP sequences in seconds  |
| RCAPSL  | CAP rate (percentage of NREM sleep occupied by CAP)  |
| AVGCAPDUR  | average duration of CAP sequences in seconds  |
| AVGCYCLEDUR  | average duration of CAP cycles in seconds  |
| AVGBPHADUR  | average duration of B-phases in seconds  |

## Important notes
This system has been trained with data from the [CAP Sleep Database 1.0.0](https://physionet.org/content/capslpdb/1.0.0/) on Physionet. Please do not use this system to score any data from this database.

This system does not guarantee a perfect scoring result. Please check some scored events afterwards, and compare statistics to previous publications. It is recommended to use this system for larger data sets and not for individualized scoring.

## Please cite

S. Hartmann and M. Baumert, “Automatic A-phase detection of cyclic alternating patterns in sleep using dynamic temporal information,” IEEE Trans. Neural Syst. Rehabil. Eng., vol. 27, no. 9, pp. 1695–1703, Sep. 2019, [link](https://doi.org/10.1109/TNSRE.2019.2934828)

S. Hartmann and M. Baumert, “Subject-level Normalization to Improve A-phase Detection of Cyclic Alternating Pattern in Sleep EEG,” in 2023 45th Annual International Conference of the IEEE Engineering in Medicine and Biology Society (EMBC), 2023.
