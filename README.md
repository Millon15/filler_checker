# Filler checker
*Checker for the 42 Filler project*

## ACHTUNG

./filler_checker parse output of the `./filler_vm -q` command<br />
Example of this output:

```
# -------------- VM  version 1.1 ------------- #
#                                              #
# 42 / filler VM Developped by: Hcao - Abanlin #
#                                              #
# -------------------------------------------- #
launched resources/players/carli.filler
launched ./vbrazas/vbrazas.filler
== O fin: 0
== X fin: 169
```

You can always get more information about checker if you take look on its source code in *filler_checker.zsh* file

## How to install ?

	git clone https://github.com/millon15/filler_checker

## How to use ?

	chmod +x filler_checker.zsh

```bash
Usage: ./filler_checker.zsh [xlogin.filler]
Example: ./filler_checker.zsh ../filler/vbrazas.filler
```

#### Be aware! Checker folder must contain the filler's resources/ directory
#### NOTE: List of maps and players to test you can always change in the head of the ./filler_checker.zsh files

```bash
PLAYERS="abanlin carli champely grati hcao superjeannot"    #### <<<<<<<< change it!
---------------------------------------
PLAYERS="abanlin carli champely"                            #### <<<<<<<< on it, for example.
```

```bash
MAPS="map00 map01"          #### <<<<<<<< or it!
# map02"
---------------------------------------
MAPS="map00 map01 map02"    #### <<<<<<<< on it!
```
