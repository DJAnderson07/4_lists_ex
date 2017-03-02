---
title       : Lists and an Applied Example
subtitle    : "Lecture 4: Taste of R Workshop, UO COE"
author      : Daniel Anderson
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : zenburn      # 
widgets     : [mathjax]            # {mathjax, quiz, bootstrap}
mode        : selfcontained # {standalone, draft}
knit        : slidify::knit2slides
--- 
<style>
em {
  font-style: italic
}
</style>

<style>
strong {
  font-weight: bold;
}
</style>

## Agenda
* Presentation by Dave Degarmo (~10 minutes)
* Introduction to Lists
* Introduction to the *purrr* package for working with lists
* Artificial example
* Full applied example

--- .segue
# lists

----
## Lists versus other data structures

* To date, we have mostly worked with data frames
	+ type of list
* Each column of a data frame is (almost always) an atomic vector of a specific type
	+ double
	+ integer
	+ character
	+ logical
* All elements within an atomic vector must be of the same type (implicit coercion). 
* Lists are vectors (not atomic) where every element can be of a different type, including other lists.

---- &twocol
## Contrasting lists and atomic vectors

*** =left

# Lists

```r
list("a", 4.35, TRUE, 7L)
```

```
## [[1]]
## [1] "a"
## 
## [[2]]
## [1] 4.35
## 
## [[3]]
## [1] TRUE
## 
## [[4]]
## [1] 7
```

*** =right

# Vectors
(implicit coercion)


```r
c("a", 4.35, TRUE, 7L)
```

```
## [1] "a"    "4.35" "TRUE" "7"
```

```r
c(4.35, TRUE, 7L)
```

```
## [1] 4.35 1.00 7.00
```

----
## Quick aside

* Logical vectors can be coerced to binary numeric (0/1) and vice versa.
* This feature can make a really handy way to investigate missing data.


```r
some_data <- c(12, 15, NA, 5, 7, NA, NA, 18, 6, NA)
sum(is.na(some_data))
```

```
## [1] 4
```

---- &twocol
## Lists
Note that the length of list elements can all be different.

*** =left


```r
l <- list(
	c("a", "b", "c"),
	1:5,
	rep(c(T,F), 7),
	rnorm(3, 100, 25)
		  )
```

*** =right


```r
l
```

```
## [[1]]
## [1] "a" "b" "c"
## 
## [[2]]
## [1] 1 2 3 4 5
## 
## [[3]]
##  [1]  TRUE FALSE  TRUE FALSE  TRUE FALSE  TRUE FALSE  TRUE FALSE  TRUE
## [12] FALSE  TRUE FALSE
## 
## [[4]]
## [1]  55.33627  94.98044 100.45670
```

----
## Lists returned by functions
* Many functions return a list of objects. This is because lists are a great way to store a lot of varied information. For example: `lm`.


```r
mod <- lm(hp ~ mpg, data = mtcars)
str(mod)
```

```
## List of 12
##  $ coefficients : Named num [1:2] 324.08 -8.83
##   ..- attr(*, "names")= chr [1:2] "(Intercept)" "mpg"
##  $ residuals    : Named num [1:32] -28.7 -28.7 -29.8 -25.1 16 ...
##   ..- attr(*, "names")= chr [1:32] "Mazda RX4" "Mazda RX4 Wag" "Datsun 710" "Hornet 4 Drive" ...
##  $ effects      : Named num [1:32] -829.8 296.3 -23.6 -20 19.3 ...
##   ..- attr(*, "names")= chr [1:32] "(Intercept)" "mpg" "" "" ...
##  $ rank         : int 2
##  $ fitted.values: Named num [1:32] 139 139 123 135 159 ...
##   ..- attr(*, "names")= chr [1:32] "Mazda RX4" "Mazda RX4 Wag" "Datsun 710" "Hornet 4 Drive" ...
##  $ assign       : int [1:2] 0 1
##  $ qr           :List of 5
##   ..$ qr   : num [1:32, 1:2] -5.657 0.177 0.177 0.177 0.177 ...
##   .. ..- attr(*, "dimnames")=List of 2
##   .. .. ..$ : chr [1:32] "Mazda RX4" "Mazda RX4 Wag" "Datsun 710" "Hornet 4 Drive" ...
##   .. .. ..$ : chr [1:2] "(Intercept)" "mpg"
##   .. ..- attr(*, "assign")= int [1:2] 0 1
##   ..$ qraux: num [1:2] 1.18 1.02
##   ..$ pivot: int [1:2] 1 2
##   ..$ tol  : num 1e-07
##   ..$ rank : int 2
##   ..- attr(*, "class")= chr "qr"
##  $ df.residual  : int 30
##  $ xlevels      : Named list()
##  $ call         : language lm(formula = hp ~ mpg, data = mtcars)
##  $ terms        :Classes 'terms', 'formula'  language hp ~ mpg
##   .. ..- attr(*, "variables")= language list(hp, mpg)
##   .. ..- attr(*, "factors")= int [1:2, 1] 0 1
##   .. .. ..- attr(*, "dimnames")=List of 2
##   .. .. .. ..$ : chr [1:2] "hp" "mpg"
##   .. .. .. ..$ : chr "mpg"
##   .. ..- attr(*, "term.labels")= chr "mpg"
##   .. ..- attr(*, "order")= int 1
##   .. ..- attr(*, "intercept")= int 1
##   .. ..- attr(*, "response")= int 1
##   .. ..- attr(*, ".Environment")=<environment: R_GlobalEnv> 
##   .. ..- attr(*, "predvars")= language list(hp, mpg)
##   .. ..- attr(*, "dataClasses")= Named chr [1:2] "numeric" "numeric"
##   .. .. ..- attr(*, "names")= chr [1:2] "hp" "mpg"
##  $ model        :'data.frame':	32 obs. of  2 variables:
##   ..$ hp : num [1:32] 110 110 93 110 175 105 245 62 95 123 ...
##   ..$ mpg: num [1:32] 21 21 22.8 21.4 18.7 18.1 14.3 24.4 22.8 19.2 ...
##   ..- attr(*, "terms")=Classes 'terms', 'formula'  language hp ~ mpg
##   .. .. ..- attr(*, "variables")= language list(hp, mpg)
##   .. .. ..- attr(*, "factors")= int [1:2, 1] 0 1
##   .. .. .. ..- attr(*, "dimnames")=List of 2
##   .. .. .. .. ..$ : chr [1:2] "hp" "mpg"
##   .. .. .. .. ..$ : chr "mpg"
##   .. .. ..- attr(*, "term.labels")= chr "mpg"
##   .. .. ..- attr(*, "order")= int 1
##   .. .. ..- attr(*, "intercept")= int 1
##   .. .. ..- attr(*, "response")= int 1
##   .. .. ..- attr(*, ".Environment")=<environment: R_GlobalEnv> 
##   .. .. ..- attr(*, "predvars")= language list(hp, mpg)
##   .. .. ..- attr(*, "dataClasses")= Named chr [1:2] "numeric" "numeric"
##   .. .. .. ..- attr(*, "names")= chr [1:2] "hp" "mpg"
##  - attr(*, "class")= chr "lm"
```

----
You can access the elements through the list


```r
mod$coefficients
```

```
## (Intercept)         mpg 
##  324.082314   -8.829731
```


```r
mod$residuals
```

```
##           Mazda RX4       Mazda RX4 Wag          Datsun 710 
##         -28.6579634         -28.6579634         -29.7644476 
##      Hornet 4 Drive   Hornet Sportabout             Valiant 
##         -25.1260710          16.0336553         -59.2641833 
##          Duster 360           Merc 240D            Merc 230 
##          47.1828390         -46.6368780         -27.7644476 
##            Merc 280           Merc 280C          Merc 450SE 
##         -31.5514792         -43.9131026           0.7252741 
##          Merc 450SL         Merc 450SLC  Cadillac Fleetwood 
##           8.6720320          -9.8704031         -27.2531119 
## Lincoln Continental   Chrysler Imperial            Fiat 128 
##         -17.2531119          35.7147314          28.0009699 
##         Honda Civic      Toyota Corolla       Toyota Corona 
##          -3.6584921          40.2455664         -37.2430979 
##    Dodge Challenger         AMC Javelin          Camaro Z28 
##         -37.2214838         -39.8704031          38.3531080 
##    Pontiac Firebird           Fiat X1-9       Porsche 914-2 
##          20.4485208         -17.0306581          -3.5093084 
##        Lotus Europa      Ford Pantera L        Ferrari Dino 
##          57.3415079          79.4274355          24.8633863 
##       Maserati Bora          Volvo 142E 
##         143.3636507         -26.1260710
```

----
## Extractors

Often with functions there are more efficient methods for extracting model output.


```r
coef(mod)
```

```
## (Intercept)         mpg 
##  324.082314   -8.829731
```

In this case the methods are roughly equivalent, but sometimes it can make a
  difference (*ltm* example)

----
## Other functions will transform data into lists


```r
cyls <- split(mtcars, mtcars$cyl)
str(cyls)
```

```
## List of 3
##  $ 4:'data.frame':	11 obs. of  11 variables:
##   ..$ mpg : num [1:11] 22.8 24.4 22.8 32.4 30.4 33.9 21.5 27.3 26 30.4 ...
##   ..$ cyl : num [1:11] 4 4 4 4 4 4 4 4 4 4 ...
##   ..$ disp: num [1:11] 108 146.7 140.8 78.7 75.7 ...
##   ..$ hp  : num [1:11] 93 62 95 66 52 65 97 66 91 113 ...
##   ..$ drat: num [1:11] 3.85 3.69 3.92 4.08 4.93 4.22 3.7 4.08 4.43 3.77 ...
##   ..$ wt  : num [1:11] 2.32 3.19 3.15 2.2 1.61 ...
##   ..$ qsec: num [1:11] 18.6 20 22.9 19.5 18.5 ...
##   ..$ vs  : num [1:11] 1 1 1 1 1 1 1 1 0 1 ...
##   ..$ am  : num [1:11] 1 0 0 1 1 1 0 1 1 1 ...
##   ..$ gear: num [1:11] 4 4 4 4 4 4 3 4 5 5 ...
##   ..$ carb: num [1:11] 1 2 2 1 2 1 1 1 2 2 ...
##  $ 6:'data.frame':	7 obs. of  11 variables:
##   ..$ mpg : num [1:7] 21 21 21.4 18.1 19.2 17.8 19.7
##   ..$ cyl : num [1:7] 6 6 6 6 6 6 6
##   ..$ disp: num [1:7] 160 160 258 225 168 ...
##   ..$ hp  : num [1:7] 110 110 110 105 123 123 175
##   ..$ drat: num [1:7] 3.9 3.9 3.08 2.76 3.92 3.92 3.62
##   ..$ wt  : num [1:7] 2.62 2.88 3.21 3.46 3.44 ...
##   ..$ qsec: num [1:7] 16.5 17 19.4 20.2 18.3 ...
##   ..$ vs  : num [1:7] 0 0 1 1 1 1 0
##   ..$ am  : num [1:7] 1 1 0 0 0 0 1
##   ..$ gear: num [1:7] 4 4 3 3 4 4 5
##   ..$ carb: num [1:7] 4 4 1 1 4 4 6
##  $ 8:'data.frame':	14 obs. of  11 variables:
##   ..$ mpg : num [1:14] 18.7 14.3 16.4 17.3 15.2 10.4 10.4 14.7 15.5 15.2 ...
##   ..$ cyl : num [1:14] 8 8 8 8 8 8 8 8 8 8 ...
##   ..$ disp: num [1:14] 360 360 276 276 276 ...
##   ..$ hp  : num [1:14] 175 245 180 180 180 205 215 230 150 150 ...
##   ..$ drat: num [1:14] 3.15 3.21 3.07 3.07 3.07 2.93 3 3.23 2.76 3.15 ...
##   ..$ wt  : num [1:14] 3.44 3.57 4.07 3.73 3.78 ...
##   ..$ qsec: num [1:14] 17 15.8 17.4 17.6 18 ...
##   ..$ vs  : num [1:14] 0 0 0 0 0 0 0 0 0 0 ...
##   ..$ am  : num [1:14] 0 0 0 0 0 0 0 0 0 0 ...
##   ..$ gear: num [1:14] 3 3 3 3 3 3 3 3 3 3 ...
##   ..$ carb: num [1:14] 2 4 3 3 3 4 4 4 2 2 ...
```

----
## More on lists
* Note that the previous slide looked like a nested list (list inside a list). 
  This is because data frames are lists, where each element of the list is a
  vector of the same length.
* lists are tremendously useful and flexible, and can lead to massive jumps in efficiency when combined with loops
  	+ Often want to loop through a list and apply a function to each element
  	  of the list.

---- &twocol
## Lists and data frames

*** =left


```r
l <- list(
	lets = letters[1:5],
	ints = 9:5,
	dbl = rnorm(5, 12, 0.75)
	)
l
```

```
## $lets
## [1] "a" "b" "c" "d" "e"
## 
## $ints
## [1] 9 8 7 6 5
## 
## $dbl
## [1] 11.04065 12.25495 12.46319 11.35958 12.34298
```

*** =right


```r
as.data.frame(l)
```

```
##   lets ints      dbl
## 1    a    9 11.04065
## 2    b    8 12.25495
## 3    c    7 12.46319
## 4    d    6 11.35958
## 5    e    5 12.34298
```

--- &twocol
# Alternative

*** =left


```r
dframe <- data.frame(
	lets = letters[1:5],
	ints = 9:5,
	dbl = rnorm(5, 12, 0.75)
	)
dframe
```

```
##   lets ints      dbl
## 1    a    9 13.07447
## 2    b    8 11.56394
## 3    c    7 12.10932
## 4    d    6 11.97803
## 5    e    5 12.88137
```

*** =right


```r
as.list(dframe)
```

```
## $lets
## [1] a b c d e
## Levels: a b c d e
## 
## $ints
## [1] 9 8 7 6 5
## 
## $dbl
## [1] 13.07447 11.56394 12.10932 11.97803 12.88137
```

---- .segue
# Brief introduction to *purrr*
![purr](assets/img/purrr.png)

----
## *purrr*
* As everything with the tidyverse, base equivalents exist
* *purrr* (note three r's) is pipe (`%>%`) friendly
* Has nice parallelization features. 
* We'll focus today on `map` and friends, which is the primary function from the package.
* Generally used with lists (for me at least), but can work with any type of vector.

----
## Data
*mtcars* dataset split by cylinder


```r
cyls <- split(mtcars, mtcars$cyl)
str(cyls)
```

```
## List of 3
##  $ 4:'data.frame':	11 obs. of  11 variables:
##   ..$ mpg : num [1:11] 22.8 24.4 22.8 32.4 30.4 33.9 21.5 27.3 26 30.4 ...
##   ..$ cyl : num [1:11] 4 4 4 4 4 4 4 4 4 4 ...
##   ..$ disp: num [1:11] 108 146.7 140.8 78.7 75.7 ...
##   ..$ hp  : num [1:11] 93 62 95 66 52 65 97 66 91 113 ...
##   ..$ drat: num [1:11] 3.85 3.69 3.92 4.08 4.93 4.22 3.7 4.08 4.43 3.77 ...
##   ..$ wt  : num [1:11] 2.32 3.19 3.15 2.2 1.61 ...
##   ..$ qsec: num [1:11] 18.6 20 22.9 19.5 18.5 ...
##   ..$ vs  : num [1:11] 1 1 1 1 1 1 1 1 0 1 ...
##   ..$ am  : num [1:11] 1 0 0 1 1 1 0 1 1 1 ...
##   ..$ gear: num [1:11] 4 4 4 4 4 4 3 4 5 5 ...
##   ..$ carb: num [1:11] 1 2 2 1 2 1 1 1 2 2 ...
##  $ 6:'data.frame':	7 obs. of  11 variables:
##   ..$ mpg : num [1:7] 21 21 21.4 18.1 19.2 17.8 19.7
##   ..$ cyl : num [1:7] 6 6 6 6 6 6 6
##   ..$ disp: num [1:7] 160 160 258 225 168 ...
##   ..$ hp  : num [1:7] 110 110 110 105 123 123 175
##   ..$ drat: num [1:7] 3.9 3.9 3.08 2.76 3.92 3.92 3.62
##   ..$ wt  : num [1:7] 2.62 2.88 3.21 3.46 3.44 ...
##   ..$ qsec: num [1:7] 16.5 17 19.4 20.2 18.3 ...
##   ..$ vs  : num [1:7] 0 0 1 1 1 1 0
##   ..$ am  : num [1:7] 1 1 0 0 0 0 1
##   ..$ gear: num [1:7] 4 4 3 3 4 4 5
##   ..$ carb: num [1:7] 4 4 1 1 4 4 6
##  $ 8:'data.frame':	14 obs. of  11 variables:
##   ..$ mpg : num [1:14] 18.7 14.3 16.4 17.3 15.2 10.4 10.4 14.7 15.5 15.2 ...
##   ..$ cyl : num [1:14] 8 8 8 8 8 8 8 8 8 8 ...
##   ..$ disp: num [1:14] 360 360 276 276 276 ...
##   ..$ hp  : num [1:14] 175 245 180 180 180 205 215 230 150 150 ...
##   ..$ drat: num [1:14] 3.15 3.21 3.07 3.07 3.07 2.93 3 3.23 2.76 3.15 ...
##   ..$ wt  : num [1:14] 3.44 3.57 4.07 3.73 3.78 ...
##   ..$ qsec: num [1:14] 17 15.8 17.4 17.6 18 ...
##   ..$ vs  : num [1:14] 0 0 0 0 0 0 0 0 0 0 ...
##   ..$ am  : num [1:14] 0 0 0 0 0 0 0 0 0 0 ...
##   ..$ gear: num [1:14] 3 3 3 3 3 3 3 3 3 3 ...
##   ..$ carb: num [1:14] 2 4 3 3 3 4 4 4 2 2 ...
```

----
## `map` basic usage


```r
library(purrr)
map(cyls, ~lm(hp ~ mpg, data = .)) 
```

```
## $`4`
## 
## Call:
## lm(formula = hp ~ mpg, data = .)
## 
## Coefficients:
## (Intercept)          mpg  
##      147.43        -2.43  
## 
## 
## $`6`
## 
## Call:
## lm(formula = hp ~ mpg, data = .)
## 
## Coefficients:
## (Intercept)          mpg  
##     164.156       -2.121  
## 
## 
## $`8`
## 
## Call:
## lm(formula = hp ~ mpg, data = .)
## 
## Coefficients:
## (Intercept)          mpg  
##     294.497       -5.648
```

---
## Basic usage


```r
map(LIST, FUN, ...)
```
* LIST = list to loop through
* FUN = Function to loop through the list
* ... Other arguments passed to the function

---
## Different ways to specify functions 

The below are equivalent


```r
map(cyls, function(x) lm(hp ~ mpg, data = x))
map(cyls, ~lm(hp ~ mpg, data = .)) 
```

If we want to extract something from each element of the list, and the that something is named, we can also just supply that name as a string. 


```r
models <- map(cyls, ~lm(hp ~ mpg, data = .)) 
map(models, "coefficients")
```

```
## $`4`
## (Intercept)         mpg 
##  147.431465   -2.430092 
## 
## $`6`
## (Intercept)         mpg 
##  164.156412   -2.120802 
## 
## $`8`
## (Intercept)         mpg 
##  294.497384   -5.647887
```

---- &twocol
## Different versions of map

*** =left

If we call a single function, just list it.


```r
lst <- list(first = 1:3, 
			second = 80:100, 
			third = -2:4)

map(lst, mean)
```

```
## $first
## [1] 2
## 
## $second
## [1] 90
## 
## $third
## [1] 1
```

`map` will alway return a list. Other variants will return other output.

*** =right



```r
map_df(lst, mean)
```

```
## # A tibble: 1 × 3
##   first second third
##   <dbl>  <dbl> <dbl>
## 1     2     90     1
```

```r
map_dbl(lst, mean)
```

```
##  first second  third 
##      2     90      1
```

```r
map_chr(lst, mean)
```

```
##       first      second       third 
##  "2.000000" "90.000000"  "1.000000"
```

----
## Putting them together


```r
library(tidyverse)
map(cyls, ~lm(hp ~ mpg, data = .)) %>% 
	map_df(coef) %>% 
	mutate(param = c("intercept", "slope")) %>% 
	gather(cyl, val, -4) %>% 
	spread(param, val)
```

```
## # A tibble: 3 × 3
##     cyl intercept     slope
## * <chr>     <dbl>     <dbl>
## 1     4  147.4315 -2.430092
## 2     6  164.1564 -2.120802
## 3     8  294.4974 -5.647887
```

----
## Alternatively: *broom*


```r
library(broom)
map(cyls, ~lm(hp ~ mpg, data = .)) %>% 
	map_df(tidy)
```

```
##          term   estimate  std.error  statistic     p.value
## 1 (Intercept) 147.431465  35.606406  4.1405882 0.002519431
## 2         mpg  -2.430092   1.318359 -1.8432709 0.098398581
## 3 (Intercept) 164.156412 146.508014  1.1204603 0.313430721
## 4         mpg  -2.120802   7.403631 -0.2864543 0.786020206
## 5 (Intercept) 294.497384  84.337195  3.4919040 0.004447715
## 6         mpg  -5.647887   5.512168 -1.0246218 0.325753780
```

--- &twocol
## More complex versions of `map`
* `map2` iterates over two lists (or any type of vector) in parallel
* `pmap` 

# Calculate differences in means

(spacing added just for clarity)

*** =left


```r
set.seed(222)
map2(list(rnorm(100), 
		  rnorm(100),
		  rnorm(100)),

	 list(rnorm(100, 0.5), 
	 	  rnorm(100, 1), 
	 	  rnorm(100, 0.2)), 

	~mean(.x) - mean(.y))
```

*** =right


```
## [[1]]
## [1] -0.5997455
## 
## [[2]]
## [1] -1.083101
## 
## [[3]]
## [1] -0.2517111
```

----
## Calculate effect sizes


```r
set.seed(222)
map2_dbl(list(rnorm(100), 
		  	  rnorm(100),
		  	  rnorm(100)),

	 	 list(rnorm(100, 0.5), 
	 	  	  rnorm(100, 1), 
	 	  	  rnorm(100, 0.2)),

	~ (mean(.x) - mean(.y)) / sqrt(
		((length(.x) - 1) * sd(.x) +  (length(.y) - 1) * sd(.y)) /
					 ((length(.x) + length(.y)) - 2)))
```

```
## [1] -0.6061655 -1.0823470 -0.2482222
```

----
## `pmap`
* We won't focus on `pmap` today, but it's worth noting that the syntax is slightly different. You supply one (possibly nested) list with all the arguments to the function, and then supply the function.

For example, setup a simulation with different sample sizes, means, and standard deviations. (In this particular example we could )


```r
n <- list(50, 100, 250, 500)
mu <- list(10, 15, 10, 15)
stdev <- list(1, 1, 2, 2)

sim_data <- pmap(list(n, mu, stdev), rnorm)
str(sim_data)
```

```
## List of 4
##  $ : num [1:50] 10.06 10.2 10.39 9.67 10.75 ...
##  $ : num [1:100] 15.1 16.5 17.2 14.4 15.2 ...
##  $ : num [1:250] 8.04 7.37 8.17 10.49 11.96 ...
##  $ : num [1:500] 15.4 15.7 15 18.4 17.8 ...
```

----
## Use `map` to check simulation
* *sim_data* is a list, so we can loop through it
* We saw on the previous slide that the sample sizes were correct. What about the means and standard deviations?


```r
map_dbl(sim_data, mean)
```

```
## [1] 10.045945 15.062124  9.768937 14.980899
```

```r
map_dbl(sim_data, sd)
```

```
## [1] 0.7623378 0.9640901 2.0434633 2.0012167
```

---
## Nesting data frames
Rather than splitting data frames (as we did before), it can often be helpful to `nest()` them instead. The reason you would want to nest a data frame is for similar reasons to wanting to split it.

For example,


```r
nested <- mtcars %>% 
	group_by(cyl) %>% 
	nest()
nested
```

```
## # A tibble: 3 × 2
##     cyl               data
##   <dbl>             <list>
## 1     6  <tibble [7 × 10]>
## 2     4 <tibble [11 × 10]>
## 3     8 <tibble [14 × 10]>
```

----
## List columns
In the previous example:
* Data are split by cylinder, just as before
* The list of data are then stored into a list column in a data frame
* Each "cell" in the list column contains all the data for that corresponding 
  row in the data frame (cylinder).
* In some ways this is a bit odd, but it can help us stay organized.

---

```r
nested$data
```

```
## [[1]]
## # A tibble: 7 × 10
##     mpg  disp    hp  drat    wt  qsec    vs    am  gear  carb
##   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
## 1  21.0 160.0   110  3.90 2.620 16.46     0     1     4     4
## 2  21.0 160.0   110  3.90 2.875 17.02     0     1     4     4
## 3  21.4 258.0   110  3.08 3.215 19.44     1     0     3     1
## 4  18.1 225.0   105  2.76 3.460 20.22     1     0     3     1
## 5  19.2 167.6   123  3.92 3.440 18.30     1     0     4     4
## 6  17.8 167.6   123  3.92 3.440 18.90     1     0     4     4
## 7  19.7 145.0   175  3.62 2.770 15.50     0     1     5     6
## 
## [[2]]
## # A tibble: 11 × 10
##      mpg  disp    hp  drat    wt  qsec    vs    am  gear  carb
##    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
## 1   22.8 108.0    93  3.85 2.320 18.61     1     1     4     1
## 2   24.4 146.7    62  3.69 3.190 20.00     1     0     4     2
## 3   22.8 140.8    95  3.92 3.150 22.90     1     0     4     2
## 4   32.4  78.7    66  4.08 2.200 19.47     1     1     4     1
## 5   30.4  75.7    52  4.93 1.615 18.52     1     1     4     2
## 6   33.9  71.1    65  4.22 1.835 19.90     1     1     4     1
## 7   21.5 120.1    97  3.70 2.465 20.01     1     0     3     1
## 8   27.3  79.0    66  4.08 1.935 18.90     1     1     4     1
## 9   26.0 120.3    91  4.43 2.140 16.70     0     1     5     2
## 10  30.4  95.1   113  3.77 1.513 16.90     1     1     5     2
## 11  21.4 121.0   109  4.11 2.780 18.60     1     1     4     2
## 
## [[3]]
## # A tibble: 14 × 10
##      mpg  disp    hp  drat    wt  qsec    vs    am  gear  carb
##    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
## 1   18.7 360.0   175  3.15 3.440 17.02     0     0     3     2
## 2   14.3 360.0   245  3.21 3.570 15.84     0     0     3     4
## 3   16.4 275.8   180  3.07 4.070 17.40     0     0     3     3
## 4   17.3 275.8   180  3.07 3.730 17.60     0     0     3     3
## 5   15.2 275.8   180  3.07 3.780 18.00     0     0     3     3
## 6   10.4 472.0   205  2.93 5.250 17.98     0     0     3     4
## 7   10.4 460.0   215  3.00 5.424 17.82     0     0     3     4
## 8   14.7 440.0   230  3.23 5.345 17.42     0     0     3     4
## 9   15.5 318.0   150  2.76 3.520 16.87     0     0     3     2
## 10  15.2 304.0   150  3.15 3.435 17.30     0     0     3     2
## 11  13.3 350.0   245  3.73 3.840 15.41     0     0     3     4
## 12  19.2 400.0   175  3.08 3.845 17.05     0     0     3     2
## 13  15.8 351.0   264  4.22 3.170 14.50     0     1     5     4
## 14  15.0 301.0   335  3.54 3.570 14.60     0     1     5     8
```

---
## Fit multiple models


```r
nested <- nested %>% 
	mutate(m1_mpg = map(data, ~lm(hp ~ mpg, data = .)),
		   m2_mpg_disp = map(data, ~lm(hp ~ mpg + disp, data = .)))
nested
```

```
## # A tibble: 3 × 4
##     cyl               data   m1_mpg m2_mpg_disp
##   <dbl>             <list>   <list>      <list>
## 1     6  <tibble [7 × 10]> <S3: lm>    <S3: lm>
## 2     4 <tibble [11 × 10]> <S3: lm>    <S3: lm>
## 3     8 <tibble [14 × 10]> <S3: lm>    <S3: lm>
```

---
## See models for *mpg* and *disp*


```r
nested$m2_mpg_disp
```

```
## [[1]]
## 
## Call:
## lm(formula = hp ~ mpg + disp, data = .)
## 
## Coefficients:
## (Intercept)          mpg         disp  
##    201.1055      -1.2504      -0.2953  
## 
## 
## [[2]]
## 
## Call:
## lm(formula = hp ~ mpg + disp, data = .)
## 
## Coefficients:
## (Intercept)          mpg         disp  
##   140.68630     -2.29124      0.02894  
## 
## 
## [[3]]
## 
## Call:
## lm(formula = hp ~ mpg + disp, data = .)
## 
## Coefficients:
## (Intercept)          mpg         disp  
##   311.35825     -6.06153     -0.03006
```

----
## Summary of models for *mpg* and *disp*


```r
map(nested$m2_mpg_disp, summary)
```

```
## [[1]]
## 
## Call:
## lm(formula = hp ~ mpg + disp, data = .)
## 
## Residuals:
##       1       2       3       4       5       6       7 
## -17.599 -17.599  11.841  -7.030  -4.605  -6.356  41.346 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept) 201.1055   144.6027   1.391    0.237
## mpg          -1.2504     7.1714  -0.174    0.870
## disp         -0.2953     0.2508  -1.177    0.304
## 
## Residual standard error: 25.4 on 4 degrees of freedom
## Multiple R-squared:  0.2694,	Adjusted R-squared:  -0.09595 
## F-statistic: 0.7374 on 2 and 4 DF,  p-value: 0.5338
## 
## 
## [[2]]
## 
## Call:
## lm(formula = hp ~ mpg + disp, data = .)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -27.026  -8.575   1.428   4.442  39.215 
## 
## Coefficients:
##              Estimate Std. Error t value Pr(>|t|)
## (Intercept) 140.68630   99.64213   1.412    0.196
## mpg          -2.29124    2.35746  -0.972    0.360
## disp          0.02894    0.39565   0.073    0.943
## 
## Residual standard error: 19.94 on 8 degrees of freedom
## Multiple R-squared:  0.2745,	Adjusted R-squared:  0.09318 
## F-statistic: 1.514 on 2 and 8 DF,  p-value: 0.277
## 
## 
## [[3]]
## 
## Call:
## lm(formula = hp ~ mpg + disp, data = .)
## 
## Residuals:
##    Min     1Q Median     3Q    Max 
## -60.08 -27.76 -15.19  23.83 123.61 
## 
## Coefficients:
##              Estimate Std. Error t value Pr(>|t|)  
## (Intercept) 311.35825  167.65969   1.857   0.0903 .
## mpg          -6.06153    6.73483  -0.900   0.3874  
## disp         -0.03006    0.25441  -0.118   0.9081  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 53.11 on 11 degrees of freedom
## Multiple R-squared:  0.08161,	Adjusted R-squared:  -0.08536 
## F-statistic: 0.4888 on 2 and 11 DF,  p-value: 0.6261
```

----
## For the `$` averse


```r
nested %>% 
	transmute(smry = map(m2_mpg_disp, summary)) %>% 
	flatten()
```

```
## [[1]]
## 
## Call:
## lm(formula = hp ~ mpg + disp, data = .)
## 
## Residuals:
##       1       2       3       4       5       6       7 
## -17.599 -17.599  11.841  -7.030  -4.605  -6.356  41.346 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept) 201.1055   144.6027   1.391    0.237
## mpg          -1.2504     7.1714  -0.174    0.870
## disp         -0.2953     0.2508  -1.177    0.304
## 
## Residual standard error: 25.4 on 4 degrees of freedom
## Multiple R-squared:  0.2694,	Adjusted R-squared:  -0.09595 
## F-statistic: 0.7374 on 2 and 4 DF,  p-value: 0.5338
## 
## 
## [[2]]
## 
## Call:
## lm(formula = hp ~ mpg + disp, data = .)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -27.026  -8.575   1.428   4.442  39.215 
## 
## Coefficients:
##              Estimate Std. Error t value Pr(>|t|)
## (Intercept) 140.68630   99.64213   1.412    0.196
## mpg          -2.29124    2.35746  -0.972    0.360
## disp          0.02894    0.39565   0.073    0.943
## 
## Residual standard error: 19.94 on 8 degrees of freedom
## Multiple R-squared:  0.2745,	Adjusted R-squared:  0.09318 
## F-statistic: 1.514 on 2 and 8 DF,  p-value: 0.277
## 
## 
## [[3]]
## 
## Call:
## lm(formula = hp ~ mpg + disp, data = .)
## 
## Residuals:
##    Min     1Q Median     3Q    Max 
## -60.08 -27.76 -15.19  23.83 123.61 
## 
## Coefficients:
##              Estimate Std. Error t value Pr(>|t|)  
## (Intercept) 311.35825  167.65969   1.857   0.0903 .
## mpg          -6.06153    6.73483  -0.900   0.3874  
## disp         -0.03006    0.25441  -0.118   0.9081  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 53.11 on 11 degrees of freedom
## Multiple R-squared:  0.08161,	Adjusted R-squared:  -0.08536 
## F-statistic: 0.4888 on 2 and 11 DF,  p-value: 0.6261
```

----
## Another alternative


```r
nested %>% 
	select(m2_mpg_disp) %>% 
	map(map, summary)
```

```
## $m2_mpg_disp
## $m2_mpg_disp[[1]]
## 
## Call:
## lm(formula = hp ~ mpg + disp, data = .)
## 
## Residuals:
##       1       2       3       4       5       6       7 
## -17.599 -17.599  11.841  -7.030  -4.605  -6.356  41.346 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept) 201.1055   144.6027   1.391    0.237
## mpg          -1.2504     7.1714  -0.174    0.870
## disp         -0.2953     0.2508  -1.177    0.304
## 
## Residual standard error: 25.4 on 4 degrees of freedom
## Multiple R-squared:  0.2694,	Adjusted R-squared:  -0.09595 
## F-statistic: 0.7374 on 2 and 4 DF,  p-value: 0.5338
## 
## 
## $m2_mpg_disp[[2]]
## 
## Call:
## lm(formula = hp ~ mpg + disp, data = .)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -27.026  -8.575   1.428   4.442  39.215 
## 
## Coefficients:
##              Estimate Std. Error t value Pr(>|t|)
## (Intercept) 140.68630   99.64213   1.412    0.196
## mpg          -2.29124    2.35746  -0.972    0.360
## disp          0.02894    0.39565   0.073    0.943
## 
## Residual standard error: 19.94 on 8 degrees of freedom
## Multiple R-squared:  0.2745,	Adjusted R-squared:  0.09318 
## F-statistic: 1.514 on 2 and 8 DF,  p-value: 0.277
## 
## 
## $m2_mpg_disp[[3]]
## 
## Call:
## lm(formula = hp ~ mpg + disp, data = .)
## 
## Residuals:
##    Min     1Q Median     3Q    Max 
## -60.08 -27.76 -15.19  23.83 123.61 
## 
## Coefficients:
##              Estimate Std. Error t value Pr(>|t|)  
## (Intercept) 311.35825  167.65969   1.857   0.0903 .
## mpg          -6.06153    6.73483  -0.900   0.3874  
## disp         -0.03006    0.25441  -0.118   0.9081  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 53.11 on 11 degrees of freedom
## Multiple R-squared:  0.08161,	Adjusted R-squared:  -0.08536 
## F-statistic: 0.4888 on 2 and 11 DF,  p-value: 0.6261
```

---
## Compare Models


```r
nested <- nested %>% 
	mutate(m12_comp = map2(m1_mpg, m2_mpg_disp, anova), 
		   p = map(m12_comp, "Pr(>F)"),
		   p = map_dbl(p, `[`, 2))
nested
```

```
## # A tibble: 3 × 6
##     cyl               data   m1_mpg m2_mpg_disp        m12_comp         p
##   <dbl>             <list>   <list>      <list>          <list>     <dbl>
## 1     6  <tibble [7 × 10]> <S3: lm>    <S3: lm> <anova [2 × 6]> 0.3043020
## 2     4 <tibble [11 × 10]> <S3: lm>    <S3: lm> <anova [2 × 6]> 0.9434844
## 3     8 <tibble [14 × 10]> <S3: lm>    <S3: lm> <anova [2 × 6]> 0.9080672
```

----
## Extract all coefficients


```r
coefs <- nested %>% 
	select(3:4) %>% 
	map(map_df, tidy) 
coefs
```

```
## $m1_mpg
##          term   estimate  std.error  statistic     p.value
## 1 (Intercept) 164.156412 146.508014  1.1204603 0.313430721
## 2         mpg  -2.120802   7.403631 -0.2864543 0.786020206
## 3 (Intercept) 147.431465  35.606406  4.1405882 0.002519431
## 4         mpg  -2.430092   1.318359 -1.8432709 0.098398581
## 5 (Intercept) 294.497384  84.337195  3.4919040 0.004447715
## 6         mpg  -5.647887   5.512168 -1.0246218 0.325753780
## 
## $m2_mpg_disp
##          term     estimate   std.error   statistic   p.value
## 1 (Intercept) 201.10545950 144.6026821  1.39074502 0.2366760
## 2         mpg  -1.25040042   7.1713987 -0.17435935 0.8700522
## 3        disp  -0.29530305   0.2508059 -1.17741686 0.3043020
## 4 (Intercept) 140.68630194  99.6421350  1.41191577 0.1956675
## 5         mpg  -2.29123552   2.3574552 -0.97191054 0.3595602
## 6        disp   0.02894082   0.3956489  0.07314773 0.9434844
## 7 (Intercept) 311.35824930 167.6596917  1.85708471 0.0902559
## 8         mpg  -6.06152869   6.7348316 -0.90002676 0.3873854
## 9        disp  -0.03006197   0.2544069 -0.11816490 0.9080672
```

---
## Next steps
From here we could go on to plotting, etc., instead, let's look at a full, applied example that uses some of these topics.

# Context
* Evaluating intervention response through "checkpoints"
* Only concerning if students do not receive full credit at each checkpoint
* Evaluate patterns of checkpoint response to see if we can identify different types of non-responders

# Analysis
* Examine means at pre- and post-test on various measures of mathematics for student groups (according to their patterns of response)
* Examine residual gains by groups
* Ask Lina if you have more questions, she's the guru here.
