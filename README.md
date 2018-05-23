A simple script to display stuff on a world map with R and ggplot

# Usage

This is an embarrassingly simple and largely generalized version of an R script that we often use in our lab to visualize the relative abundance and distribution of our marine metagenome-assembled genomes on the map.

Given that it could be useful to others, we decided to put it in a repository. You can generate a copy of it, and run it on the mock data this way:

``` bash
git clone https://github.com/merenlab/world-map-r.git
cd world-map-r
./generate-PDFs.R
```

The input file format is very simple, and you can find an example file called `data.txt` in the repository. It goes like this:

|samples|Lat|Lon|MAG_001|MAG_002|MAG_003|MAG_004|MAG_005|
|:--|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
|Metagenome_01|36.55|-6.57|0.000546189|9.47E-05|2.90E-05|0.017906223|0.00165705|
|Metagenome_02|36.57|-6.54|0.003195782|0.000293193|2.92E-05|0.002439447|0.001757119|
|Metagenome_03|35.91|-37.26|0.076768908|0.000747965|9.38E-06|0.002750737|0.006204557|
|Metagenome_04|35.75|-37.05|0.161819845|0.001082451|7.77E-06|0.003660788|0.00430017|
|Metagenome_05|36.16|-29.01|0.004429273|0.001217411|1.97E-05|0.002480494|0.004635633|
|Metagenome_06|36.19|-28.88|0.003723123|0.000574345|8.91E-06|0.000378173|0.00818276|
|Metagenome_07|43.69|-16.85|0.004529299|0.000376584|0.000988666|0.000285397|0.013052723|
|Metagenome_08|9.85|-80.04|0.086787558|0.00012408|4.50E-07|0.008367581|3.26E-05|
|Metagenome_09|25.51|-88.38|0.118475909|0.00055734|1.69E-06|0.004387672|0.000270463|
|(...)|(...)|(...)|(...)|(...)|(...)|(...)|(...)|

Columns `Lat`, and `Lon` describe the coordinates sampling sites, and column names that start with `MAG_` describe the relative abundance of each metagenome-assembled genome (or a 16S tag, or the function you are interested in, etc).

When you format the `samples.txt` the way you like with your own data, you simply run it like this:

``` bash
./generate-PDFs.R
```

When I run it using this file, the output looks like this:

``` bash
 $ ./generate-PDFs.R
Working on MAG_001 ...
Working on MAG_002 ...
Working on MAG_003 ...
Working on MAG_004 ...
Working on MAG_005 ...
```

For instance, one of the output files in my work directory, `MAG_001.pdf`, looks like this:

![https://i.imgur.com/plA8MoP.png](https://i.imgur.com/plA8MoP.png)

The script will resize the area of interest depending on the sample locations. For instance, if I remove some random metagenomes from the example file and re-run it, I get this figure instead:

![https://i.imgur.com/W3IcrSF.png](https://i.imgur.com/W3IcrSF.png)

---

The repository also contains another example file, called 'data-for-TARA.txt'. This file is the combination of TARA Ocean stations and various measurements along with their latitude and longitude, and the coverage values for MAGs we recovered from these metagenomes. If you would like to see how we generated these MAGs, and to access their FASTA files, you can visit [this URL](http://merenlab.org/data/2017_Delmont_et_al_HBDs/). You can also generate MAPs for MAGs in this file by changing two variables in the script:

``` bash
DATA_FILE="./data-for-TARA.txt"
MAG_PREFIX_IN_DATA_FILE="TARA_"
```

----

Depending on the data you are visualizing, you may need to adjust the PDF output width and height, colors, or the text size through the variables listed in the header section of the script. Just open in a text editor, and save your changes before re-running it.

# Need more from this?

Of course you do :) Feel free to send a message!
