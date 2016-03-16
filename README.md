# GenomeWalk

## Description

The purpose of this app is to generate and display DNA walks of bacterial genomes. 
DNA walks are simple graphical representations of DNA molecules.
Each of the four nucleotides (A,C,G and T) found in DNA is assigned to a different vector in 2-dimensional space:

Nucleotide | Direction
------------ | -------------
A | left
C | down
G | up
T | right

The sequence of nucleotides is translated into a path of vectors forming a unique graphical representation of the molecule.

## Usage

```
perl genome_walk.pl -i [/path/to/fasta/file]  -o [path/to/output/file]
```


## Example output
![Alt text](http://digiomics.github.io/GenomeWalk/img/EcEDL9331.svg)
