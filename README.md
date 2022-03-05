# Action

*Lights, Camera, __ACTION__*

A general-purpose script wrapper that allows you to call collections of
scripts with ease

## Usage

```
Usage: action [OPTIONS] [COMMAND [...ARGS]]

OPTIONS:
	-p | --path=DIR		Use DIR for scripts folder
	-v | --verbose		Verbose output
	-h | --help		Usage | This screen

ARGS:
	COMMAND		The script to run. Can pass arguments to the script
```

## Description

I've often found myself in the position of creating many shell scripts
to help with various work related tasks. The scripts are often related,
and may even work together. At this point you would likely create a
script wrapper for those scripts, so that's what this is.

It works by looking for a scripts directory in your current directory
and above, and displaying all the executable files it finds for the user
to select and run.

## Basic Usage

### The most basic use

```
action
```

### Supplying a specific directory

```
action -p ~/scripts
```
