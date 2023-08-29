# CAPdetection-LSTM

Automated sytem to detect CAP A phases and to classify the respective subtypes from sleep EEG recordings

## Application information
*	Version: MATLAB® R2019b
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

## Important notes
This system has been trained with data from the [CAP Sleep Database 1.0.0](https://physionet.org/content/capslpdb/1.0.0/) on Physionet. Please do not use this system to score any data from this database.

This system does not guarantee a perfect scoring result. Please check some scored events afterwards, and compare statistics to previous publications. It is recommended to use this system for larger data sets and not for individualized scoring.

## Please cite

S. Hartmann and M. Baumert, “Automatic A-phase detection of cyclic alternating patterns in sleep using dynamic temporal information,” IEEE Trans. Neural Syst. Rehabil. Eng., vol. 27, no. 9, pp. 1695–1703, Sep. 2019, [link](doi: 10.1109/TNSRE.2019.2934828).
S. Hartmann and M. Baumert, “Subject-level Normalization to Improve A-phase Detection of Cyclic Alternating Pattern in Sleep EEG,” 2023.

