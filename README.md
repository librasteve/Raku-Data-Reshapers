# Raku Data::Reshapers

[![Actions Status](https://github.com/antononcube/Raku-Data-Reshapers/actions/workflows/test.yml/badge.svg)](https://github.com/antononcube/Raku-Data-Reshapers/actions)
[![License: Artistic-2.0](https://img.shields.io/badge/License-Artistic%202.0-0298c3.svg)](https://opensource.org/licenses/Artistic-2.0)

This Raku package has data reshaping functions for different data structures that are 
coercible to full arrays.

The supported data structures are:
  - Positional-of-hashes
  - Positional-of-arrays
 
The five data reshaping provided by the package over those data structures are:

- Cross tabulation, `cross-tabulate`
- Long format conversion, `to-long-format`
- Wide format conversion, `to-wide-format`
- Join across (aka `SQL JOIN`), `join-across`
- Transpose, `transpose`

The first four operations are fundamental in data wrangling and data analysis; 
see [AA1, Wk1, Wk2, AAv1-AAv2].

(Transposing of tabular data is, of course, also fundamental, but it also can be seen as a
basic functional programming operation.)

------

## Usage examples

### Cross tabulation

Making contingency tables -- or cross tabulation -- is a fundamental statistics and data analysis operation,
[Wk1, AA1]. 

Here is an example using the 
[Titanic](https://en.wikipedia.org/wiki/Titanic) 
dataset (that is provided by this package through the function `get-titanic-dataset`):

```perl6
use Data::Reshapers;

my @tbl = get-titanic-dataset();
my $res = cross-tabulate( @tbl, 'passengerSex', 'passengerClass');
say $res;
```
```
# {female => {1st => 144, 2nd => 106, 3rd => 216}, male => {1st => 179, 2nd => 171, 3rd => 493}}
```

```perl6
to-pretty-table($res);
```
```
# +--------+-----+-----+-----+
# |        | 2nd | 1st | 3rd |
# +--------+-----+-----+-----+
# | female | 106 | 144 | 216 |
# | male   | 171 | 179 | 493 |
# +--------+-----+-----+-----+
```

### Long format

Conversion to long format allows column names to be treated as data.

(More precisely, when converting to long format specified column names of a tabular dataset become values
in a dedicated column, e.g. "Variable" in the long format.)

```perl6
my @tbl1 = @tbl.roll(3);
.say for @tbl1;
```
```
# {id => 1291, passengerAge => 50, passengerClass => 3rd, passengerSex => female, passengerSurvival => survived}
# {id => 335, passengerAge => 30, passengerClass => 2nd, passengerSex => male, passengerSurvival => died}
# {id => 245, passengerAge => 40, passengerClass => 1st, passengerSex => male, passengerSurvival => died}
```

```perl6
.say for to-long-format( @tbl1 );
```
```
# {AutomaticKey => 0, Value => 1291, Variable => id}
# {AutomaticKey => 0, Value => 3rd, Variable => passengerClass}
# {AutomaticKey => 0, Value => survived, Variable => passengerSurvival}
# {AutomaticKey => 0, Value => 50, Variable => passengerAge}
# {AutomaticKey => 0, Value => female, Variable => passengerSex}
# {AutomaticKey => 1, Value => 335, Variable => id}
# {AutomaticKey => 1, Value => 2nd, Variable => passengerClass}
# {AutomaticKey => 1, Value => died, Variable => passengerSurvival}
# {AutomaticKey => 1, Value => 30, Variable => passengerAge}
# {AutomaticKey => 1, Value => male, Variable => passengerSex}
# {AutomaticKey => 2, Value => 245, Variable => id}
# {AutomaticKey => 2, Value => 1st, Variable => passengerClass}
# {AutomaticKey => 2, Value => died, Variable => passengerSurvival}
# {AutomaticKey => 2, Value => 40, Variable => passengerAge}
# {AutomaticKey => 2, Value => male, Variable => passengerSex}
```

```perl6
my @lfRes1 = to-long-format( @tbl1, 'id', [], variablesTo => "VAR", valuesTo => "VAL2" );
.say for @lfRes1;
```
```
# {VAL2 => survived, VAR => passengerSurvival, id => 1291}
# {VAL2 => 50, VAR => passengerAge, id => 1291}
# {VAL2 => female, VAR => passengerSex, id => 1291}
# {VAL2 => 3rd, VAR => passengerClass, id => 1291}
# {VAL2 => died, VAR => passengerSurvival, id => 245}
# {VAL2 => 40, VAR => passengerAge, id => 245}
# {VAL2 => male, VAR => passengerSex, id => 245}
# {VAL2 => 1st, VAR => passengerClass, id => 245}
# {VAL2 => died, VAR => passengerSurvival, id => 335}
# {VAL2 => 30, VAR => passengerAge, id => 335}
# {VAL2 => male, VAR => passengerSex, id => 335}
# {VAL2 => 2nd, VAR => passengerClass, id => 335}
```

### Wide format

Here we transform the long format result `@lfRes1` above into wide format -- 
the result has the same records as the `@tbl1`:

```perl6
to-pretty-table( to-wide-format( @lfRes1, 'id', 'VAR', 'VAL2' ) );
```
```
# +------+--------------+--------------+----------------+-------------------+
# |  id  | passengerSex | passengerAge | passengerClass | passengerSurvival |
# +------+--------------+--------------+----------------+-------------------+
# | 1291 |    female    |      50      |      3rd       |      survived     |
# | 245  |     male     |      40      |      1st       |        died       |
# | 335  |     male     |      30      |      2nd       |        died       |
# +------+--------------+--------------+----------------+-------------------+
```

### Transpose

Using cross tabulation result above:

```perl6
my $tres = transpose( $res );

to-pretty-table($res, title => "Original");
```
```
# +--------------------------+
# |         Original         |
# +--------+-----+-----+-----+
# |        | 1st | 3rd | 2nd |
# +--------+-----+-----+-----+
# | female | 144 | 216 | 106 |
# | male   | 179 | 493 | 171 |
# +--------+-----+-----+-----+
```

```perl6
to-pretty-table($tres, title => "Transposed");
```
```
# +---------------------+
# |      Transposed     |
# +-----+------+--------+
# |     | male | female |
# +-----+------+--------+
# | 1st | 179  |  144   |
# | 2nd | 171  |  106   |
# | 3rd | 493  |  216   |
# +-----+------+--------+
```

------

## Type system

There is a type "deduction" system in place. The type system conventions follow
those of Mathematica's 
[`Dataset`](https://reference.wolfram.com/language/ref/Dataset.html) 
-- see the presentation 
["Dataset improvements"](https://www.wolfram.com/broadcast/video.php?c=488&p=4&disp=list&v=3264).

Here we get the Titanic dataset, change the "passengerAge" column values to be numeric, 
and show dataset's dimensions:

```perl6
my @dsTitanic = get-titanic-dataset(headers => 'auto');
@dsTitanic = @dsTitanic.map({$_<passengerAge> = $_<passengerAge>.Numeric; $_}).Array;
dimensions(@dsTitanic)
```
```
# (1309 5)
```

Here is a sample of dataset's records:

```perl6
to-pretty-table(@dsTitanic.pick(5).List, field-names => <id passengerAge passengerClass passengerSex passengerSurvival>)
```
```
# +------+--------------+----------------+--------------+-------------------+
# |  id  | passengerAge | passengerClass | passengerSex | passengerSurvival |
# +------+--------------+----------------+--------------+-------------------+
# | 1096 |      -1      |      3rd       |    female    |        died       |
# |  73  |      30      |      1st       |    female    |      survived     |
# | 1108 |      20      |      3rd       |     male     |        died       |
# | 915  |      30      |      3rd       |     male     |        died       |
# |  88  |      30      |      1st       |     male     |      survived     |
# +------+--------------+----------------+--------------+-------------------+
```

Here is the type of a single record:

```perl6
deduce-type(@dsTitanic[12])
```
```
# Struct([id, passengerAge, passengerClass, passengerSex, passengerSurvival], [Str, Int, Str, Str, Str])
```

Here is the type of single record's values:

```perl6
deduce-type(@dsTitanic[12].values.List)
```
```
# Tuple([Atom((Str)), Atom((Int)), Atom((Str)), Atom((Str)), Atom((Str))])
```

Here is the type of the whole dataset:

```perl6
deduce-type(@dsTitanic)
```
```
# Vector(Struct([id, passengerAge, passengerClass, passengerSex, passengerSurvival], [Str, Int, Str, Str, Str]), 1309)
```

Here is the type of "values only" records:

```perl6
my @valArr = @dsTitanic>>.values>>.Array;
deduce-type(@valArr)
```
```
# Vector((Any), 1309)
```

Here is the type of the string values only records:

```perl6
my @valArr = delete-columns(@dsTitanic, 'passengerAge')>>.values>>.Array;
deduce-type(@valArr)
```
```
# Vector(Vector(Atom((Str)), 4), 1309)
```

------

## TODO

1. [X] DONE Simpler more convenient interface.

   - ~~Currently, a user have to specify four different namespaces
     in order to be able to use all package functions.~~
    
2. [ ] TODO More extensive long format tests.

3. [ ] TODO More extensive wide format tests.

4. [ ] TODO Implement verifications for:
   
    - See the type system implementation -- it has all of functionalities listed here.
    
    - [X] DONE Positional-of-hashes
      
    - [X] DONE Positional-of-arrays
       
    - [X] DONE Positional-of-key-to-array-pairs
    
    - [X] DONE Positional-of-hashes, each record of which has:
      
       - [X] Same keys 
       - [X] Same type of values of corresponding keys
      
    - [X] DONE Positional-of-arrays, each record of which has:
    
       - [X] Same length
       - [X] Same type of values of corresponding elements

5. [X] DONE Implement "nice tabular visualization" using 
   [Pretty::Table](https://gitlab.com/uzluisf/raku-pretty-table)
   and/or
   [Text::Table::Simple](https://github.com/ugexe/Perl6-Text--Table--Simple).

6. [X] DONE Document examples using pretty tables.

7. [X] DONE Implement transposing operation for:
    - [X] hash of hashes
    - [X] hash of arrays
    - [X] array of hashes
    - [X] array of arrays
    - [X] array of key-to-array pairs 

8. [X] DONE Implement to-pretty-table for:
   - [X] hash of hashes
   - [X] hash of arrays
   - [X] array of hashes
   - [X] array of arrays
   - [X] array of key-to-array pairs

9. [ ] DONE Implement join-across:
   - [X] DONE inner, left, right, outer
   - [X] DONE single key-to-key pair
   - [X] DONE multiple key-to-key pairs
   - [X] DONE optional fill-in of missing values
   - [ ] TODO handling collisions

10. [X] DONE Implement semi- and anti-join

11. [ ] TODO Implement to long format conversion for:
    - [ ] TODO hash of hashes
    - [ ] TODO hash of arrays

12. [ ] TODO Speed/performance profiling.
    - [ ] TODO Come up with profiling tests
    - [ ] TODO Comparison with R
    - [ ] TODO Comparison with Python
   
13. [ ] TODO Type system.
    - [X] DONE Base type (Int, Str, Numeric)
    - [X] DONE Homogenous list detection
    - [X] DONE Association detection
    - [X] DONE Struct discovery
    - [ ] TODO Enumeration detection
    - [X] DONE Dataset detection
       - [X] List of hashes
       - [X] Hash of hashes
       - [X] List of lists

14. [X] DONE "Simple" or fundamental functions 
    - [X] `flatten`
    - [X] `take-drop`
    - [X] `tally`
       - Currently in "Data::Summarizers".
       - Can be easily, on the spot, "implemented" with `.BagHash.Hash`.
    
------

## References

### Articles

[AA1] Anton Antonov,
["Contingency tables creation examples"](https://mathematicaforprediction.wordpress.com/2016/10/04/contingency-tables-creation-examples/), 
(2016), 
[MathematicaForPrediction at WordPress](https://mathematicaforprediction.wordpress.com).

[Wk1] Wikipedia entry, [Contingency table](https://en.wikipedia.org/wiki/Contingency_table).

[Wk2] Wikipedia entry, [Wide and narrow data](https://en.wikipedia.org/wiki/Wide_and_narrow_data).

### Functions, repositories

[AAf1] Anton Antonov,
[CrossTabulate](https://resources.wolframcloud.com/FunctionRepository/resources/CrossTabulate),
(2019),
[Wolfram Function Repository](https://resources.wolframcloud.com/FunctionRepository).

[AAf2] Anton Antonov,
[LongFormDataset](https://resources.wolframcloud.com/FunctionRepository/resources/LongFormDataset),
(2020),
[Wolfram Function Repository](https://resources.wolframcloud.com/FunctionRepository).

[AAf3] Anton Antonov,
[WideFormDataset](https://resources.wolframcloud.com/FunctionRepository/resources/WideFormDataset),
(2021),
[Wolfram Function Repository](https://resources.wolframcloud.com/FunctionRepository).

[AAf4] Anton Antonov,
[RecordsSummary](https://resources.wolframcloud.com/FunctionRepository/resources/RecordsSummary),
(2019),
[Wolfram Function Repository](https://resources.wolframcloud.com/FunctionRepository).


### Videos

[AAv1] Anton Antonov,
["Multi-language Data-Wrangling Conversational Agent"](https://www.youtube.com/watch?v=pQk5jwoMSxs),
(2020),
[YouTube channel of Wolfram Research, Inc.](https://www.youtube.com/channel/UCJekgf6k62CQHdENWf2NgAQ).
(Wolfram Technology Conference 2020 presentation.)

[AAv2] Anton Antonov,
["Data Transformation Workflows with Anton Antonov, Session #1"](https://www.youtube.com/watch?v=iXrXMQdXOsM),
(2020),
[YouTube channel of Wolfram Research, Inc.](https://www.youtube.com/channel/UCJekgf6k62CQHdENWf2NgAQ).

[AAv3] Anton Antonov,
["Data Transformation Workflows with Anton Antonov, Session #2"](https://www.youtube.com/watch?v=DWGgFsaEOsU),
(2020),
[YouTube channel of Wolfram Research, Inc.](https://www.youtube.com/channel/UCJekgf6k62CQHdENWf2NgAQ).
