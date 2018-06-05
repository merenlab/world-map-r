A simple script to display stuff on a world map with R and ggplot

# Usage

This is an embarrassingly simple and largely generalized version of an R script that we often use in our lab to visualize the relative abundance and distribution of our marine metagenome-assembled genomes on the map.

Given that it could be useful to others, we decided to put it in a repository. You can generate a copy of it, and run it on the mock data this way, assuming that you have `R` installed on your system with `R` libraries `ggplot` and `maps`:

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

When you format the `data.txt` the way you like with your own data, you simply run it like this:

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
CIRCLE_SIZE_PREFIX_IN_DATA_FILE="TARA_"
```

---

Depending on the data you are visualizing, you may need to adjust the PDF output width and height, colors, or the text size through the variables listed in the header section of the script. Just open in a text editor, and save your changes before re-running it.

# Dynamic Color Example

You can also modify the color of each circle according to metadata. Consider the file `data-color-example.txt`:

samples        |  Lat    |  Lon     |  COLOR_001            |  MAG_001                |  COLOR_002  |  MAG_002                 |  COLOR_003    |  MAG_003                 |  COLOR_004    |  MAG_004                 |  COLOR_005               |  MAG_005
---------------|---------|----------|-----------------------|-------------------------|-------------|--------------------------|---------------|--------------------------|---------------|--------------------------|--------------------------|-----------------------
Metagenome_01  |  36.55  |  -6.57   |  0.810030943          |  0.000546189            |  0          |  9.470000000000001e-05   |  0.03859448   |  2.8999999999999997e-05  |  0.03859448   |  0.017906223             |  1.4099999999999999e-05  |  0.00165705
Metagenome_02  |  36.57  |  -6.54   |  0.40296634           |  0.0031957820000000003  |  1          |  0.00029319299999999997  |  0.033449835  |  2.9199999999999998e-05  |  0.033449835  |  0.002439447             |  1.86e-05                |  0.001757119
Metagenome_03  |  35.91  |  -37.26  |  0.552144376          |  0.076768908            |  2          |  0.000747965             |  0.03030056   |  9.38e-06                |  0.03030056   |  0.002750737             |  1.95e-05                |  0.0062045569999999994
Metagenome_04  |  35.75  |  -37.05  |  0.811288701          |  0.161819845            |  3          |  0.0010824510000000001   |  0.027517686  |  7.77e-06                |  0.027517686  |  0.003660788             |  2.08e-05                |  0.00430017
Metagenome_05  |  36.16  |  -29.01  |  0.037641937          |  0.004429273            |  4          |  0.001217411             |  0.023355612  |  1.9699999999999998e-05  |  0.023355612  |  0.0024804939999999998   |  2.2e-05                 |  0.004635633
Metagenome_06  |  36.19  |  -28.88  |  0.9088445140000001   |  0.003723123            |  5          |  0.000574345             |  0.023183939  |  8.91e-06                |  0.023183939  |  0.00037817300000000004  |  2.23e-05                |  0.00818276
Metagenome_07  |  43.69  |  -16.85  |  0.545058927          |  0.0045292990000000005  |  6          |  0.000376584             |  0.019915082  |  0.000988666             |  0.019915082  |  0.000285397             |  2.2899999999999998e-05  |  0.013052723
Metagenome_08  |  9.85   |  -80.04  |  0.114218109          |  0.086787558            |  7          |  0.00012408              |  0.018611573  |  4.5e-07                 |  0.018611573  |  0.008367580999999999    |  2.33e-05                |  3.26e-05
Metagenome_09  |  25.51  |  -88.38  |  0.32953630899999997  |  0.118475909            |  8          |  0.00055734              |  0.018509653  |  1.69e-06                |  0.018509653  |  0.0043876720000000004   |  2.3899999999999998e-05  |  0.000270463
Metagenome_10  |  39.23  |  -70.03  |  0.889719314          |  0.05032168099999999    |  9          |  0.00016785599999999997  |  0.017935595  |  0.000771443             |  0.017935595  |  0.00016434200000000002  |  2.54e-05                |  0.000181648
Metagenome_11  |  34.68  |  -71.3   |  0.162753319          |  0.291392293            |  10         |  0.000891335             |  0.017906223  |  5.69e-06                |  0.017906223  |  0.001446652             |  2.6300000000000002e-05  |  0.0029841840000000004
Metagenome_12  |  31.7   |  -64.25  |  0.5146826489999999   |  0.200199916            |  11         |  0.001131632             |  0.017676353  |  5.92e-06                |  0.017676353  |  0.018509653             |  2.64e-05                |  0.001290775
Metagenome_13  |  34.1   |  -49.89  |  0.761746358          |  0.433873241            |  12         |  0.00126812              |  0.016699203  |  9.34e-06                |  0.016699203  |  0.002886326             |  2.7399999999999995e-05  |  0.004225601

This file has the same columns as `data.txt`, except for each 'MAG' column there is extra 'color' column, which contains numeric values that will be converted into a color. To run this file, open up `generate-PDFs.R` and edit the following lines to look like:

``` bash
DATA_FILE="./data-color-example.txt"
CIRCLE_SIZE_PREFIX_IN_DATA_FILE="MAG_"
CIRCLE_COLOR_PREFIX_IN_DATA_FILE="COLOR_"
```

`MAG_001.pdf` looks like this:

![https://i.imgur.com/MhGTIy3.png](https://i.imgur.com/MhGTIy3.png)

NOTE that the program recognizes `COLOR_001` is the color column of `MAG_001` not because it is beside `MAG_001`, but because they share the suffix `001`. Keep this in mind when coloring your own MAGs.

If you don't like the colors chosen, you can change them in the part of the file that looks like this:

```bash
CIRCLE_COLOR_LOW="red"
CIRCLE_COLOR_HIGH="yellow"
```

# Need more from this?

Of course you do :) Feel free to send a message!
