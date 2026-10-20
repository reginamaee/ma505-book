/* This code creates a dataset called "example"
   and prints out the SAS table */

data example;
  input name $ age height;
  datalines;
Alice 30 5.5
Bob 25 6.1
;
run;

proc print data=example;
run;
