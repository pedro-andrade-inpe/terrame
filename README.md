## What is TerraME?

TerraME is a programming environment for spatial dynamical modelling. It supports system dynamics, cellular automata, agent-based models, and network models. TerraME provides functionalities to cover the whole modelling cycle, from building cellular representations of data (if necessary), runnning multiple simulations, and publishing outputs into GoogleMaps applications. Its modelling language has in built functions that makes it easier to develop multi-scale and multi-paradigm models. For full documentation please visit the [TerraME Home Page](http://terrame.org) and [TerraME Wiki Page](https://github.com/TerraME/terrame/wiki).

## How to use TerraME

### Supported Platforms
MS Windows, Mac OS X and Linux.

### Installing

Please visit the [download page](https://github.com/TerraME/terrame/releases). There you can find installers and instructions for different operational systems. It is also possible to [compile TerraME from scratch](https://github.com/TerraME/terrame/wiki/Building-and-Configuring) if needed.

### Getting started

In Windows, you can run TerraME by clicking in the icon on Desktop. In Mac and Linux, it is possible to run it by calling

```bash
$> terrame
```

using the command prompt. The graphical interface has options to run examples, configure and run models,
see documentation, as well as download and install additional packages. There are links to the source code
of the models as well as the examples in the documentation.

To develop your own models you will need a Lua editor. We currently recommend ZeroBrane.
Please follow the instructions available [here](http://www.terrame.org/doku.php#editor) to install and configure it properly.

## Reporting Bugs
If you have found a bug, please report it at [TerraME Issue Tracker](https://github.com/TerraME/terrame/issues).
The list of known bugs is available [here](https://github.com/TerraME/terrame/issues?q=is%3Aopen+is%3Aissue+label%3Abug).

## License
TerraME is distributed under the GNU Lesser General Public License as published by the Free Software Foundation. See [terrame-license-lgpl-3.0.txt](https://github.com/TerraME/terrame/blob/master/licenses/terrame-license-lgpl-3.0.txt) for details.

## Code Status

The output of the [daily tests](http://www.dpi.inpe.br/jenkins/view/TerraME-Daily/) is shown below. Daily installers are available [here](http://www.dpi.inpe.br/jenkins-data/terrame/installers/) (use with care as they might be unstable).

| Task            | Windows | Linux | Mac |
|---|---|---|---|
| dependencies   | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-terralib-build-windows-10">](http://www.dpi.inpe.br/jenkins/job/terrame-terralib-build-windows-10/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-terralib-build-linux-ubuntu-14.04">](http://www.dpi.inpe.br/jenkins/job/terrame-terralib-build-linux-ubuntu-14.04/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-terralib-build-mac-el-captain">](http://www.dpi.inpe.br/jenkins/job/terrame-terralib-build-mac-el-captain/lastBuild/consoleFull)|
| cpp-check       |  | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-syntaxcheck-cpp-linux-ubuntu-14.04">](http://www.dpi.inpe.br/jenkins/job/terrame-syntaxcheck-cpp-linux-ubuntu-14.04/lastBuild/consoleFull) | |
| compile         | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-build-windows-10">](http://www.dpi.inpe.br/jenkins/job/terrame-build-windows-10/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-build-linux-ubuntu-14.04">](http://www.dpi.inpe.br/jenkins/job/terrame-build-linux-ubuntu-14.04/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-build-mac-el-captain">](http://www.dpi.inpe.br/jenkins/job/terrame-build-mac-el-captain/lastBuild/consoleFull)|
| base-check       |  | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-code-analysis-base-linux-ubuntu-14.04">](http://www.dpi.inpe.br/jenkins/job/terrame-code-analysis-base-linux-ubuntu-14.04/lastBuild/consoleFull) | |
| gis-check       |  | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-code-analysis-gis-linux-ubuntu-14.04">](http://www.dpi.inpe.br/jenkins/job/terrame-code-analysis-gis-linux-ubuntu-14.04/lastBuild/consoleFull) | |
| base-doc        | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-doc-base-windows-10">](http://www.dpi.inpe.br/jenkins/job/terrame-doc-base-windows-10/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-doc-base-linux-ubuntu-14.04">](http://www.dpi.inpe.br/jenkins/job/terrame-doc-base-linux-ubuntu-14.04/lastBuild/consoleFull)| [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-doc-base-mac-el-captain">](http://www.dpi.inpe.br/jenkins/job/terrame-doc-base-mac-el-captain/lastBuild/consoleFull)|
| gis-doc    |[<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-doc-gis-windows-10">](http://www.dpi.inpe.br/jenkins/job/terrame-doc-gis-windows-10/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-doc-gis-linux-ubuntu-14.04">](http://www.dpi.inpe.br/jenkins/job/terrame-doc-gis-linux-ubuntu-14.04/lastBuild/consoleFull)| [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-doc-gis-mac-el-captain">](http://www.dpi.inpe.br/jenkins/job/terrame-doc-gis-mac-el-captain/lastBuild/consoleFull)|
| base-test       | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-unittest-base-windows-10">](http://www.dpi.inpe.br/jenkins/job/terrame-unittest-base-windows-10/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-unittest-base-linux-ubuntu-14.04">](http://www.dpi.inpe.br/jenkins/job/terrame-unittest-base-linux-ubuntu-14.04/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-unittest-base-mac-el-captain">](http://www.dpi.inpe.br/jenkins/job/terrame-unittest-base-mac-el-captain/lastBuild/consoleFull) |
| gis-test   | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-unittest-gis-windows-10">](http://www.dpi.inpe.br/jenkins/job/terrame-unittest-gis-windows-10/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-unittest-gis-linux-ubuntu-14.04">](http://www.dpi.inpe.br/jenkins/job/terrame-unittest-gis-linux-ubuntu-14.04/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-unittest-gis-mac-el-captain">](http://www.dpi.inpe.br/jenkins/job/terrame-unittest-gis-mac-el-captain/lastBuild/consoleFull) |
| execution-test  | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-test-execution-windows-10">](http://www.dpi.inpe.br/jenkins/job/terrame-test-execution-windows-10/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-test-execution-linux-ubuntu-14.04">](http://www.dpi.inpe.br/jenkins/job/terrame-test-execution-linux-ubuntu-14.04/lastBuild/consoleFull)| [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-test-execution-mac-el-captain">](http://www.dpi.inpe.br/jenkins/job/terrame-test-execution-mac-el-captain/lastBuild/consoleFull) |
| repository-test | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-repository-test-windows-10">](http://www.dpi.inpe.br/jenkins/job/terrame-repository-test-windows-10/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-repository-test-linux-ubuntu-14.04">](http://www.dpi.inpe.br/jenkins/job/terrame-repository-test-linux-ubuntu-14.04/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-repository-test-mac-el-captain">](http://www.dpi.inpe.br/jenkins/job/terrame-repository-test-mac-el-captain/lastBuild/consoleFull)|
| installer | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-installer-windows-10">](http://www.dpi.inpe.br/jenkins/job/terrame-installer-windows-10/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-installer-linux-ubuntu-14.04">](http://www.dpi.inpe.br/jenkins/job/terrame-installer-linux-ubuntu-14.04/lastBuild/consoleFull) | [<img src="http://www.dpi.inpe.br/jenkins/buildStatus/icon?job=terrame-installer-mac-el-captain">](http://www.dpi.inpe.br/jenkins/job/terrame-installer-mac-el-captain/lastBuild/consoleFull) |

