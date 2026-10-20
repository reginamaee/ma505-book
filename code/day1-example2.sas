/* This code sets the sashelp.class table into a
   dataset called myclass, calculates height in cm,
   and also provides means */

data myclass;
    set sashelp.class;
    heightcm = height*2.54;
run;

proc print data=myclass;
run;

proc means data=myclass;
    var age heightcm;
run;
