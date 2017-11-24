How to check available disk space in unix and windows

Three techniques

INPUT (access unix or windows command line)
===========================================

 You need to supply a path for solution one and three.
 Solution two does all logical disks


PROCESS
=======

     1. %windows_bytes_free(d:);
        * filename tempdir pipe "dir /-c  ""&sm_path""  | find ""bytes free"" " ;

     2. filename gather pipe "wmic logicaldisk get name,size,freespace /format:csv";
        data want;
            length drive size used $32;
            infile gather;
            input;
            if _n_ > 1;
            _infile_ = compress(_infile_, '0d'x);
            drive = scan(_infile_,3,",");
            size  = scan(_infile_,4,",");
            free  = scan(_infile_,2,",");
        run;quit;

     3 unix
       * too lazy to file up unix and check this code;
       x cd &path.;
       x du -sk * -ls > d:/txt/size.txt;

OUTPUT
======
     1  BYTES FREE
        D:
        BYTES=167,464,468,480
        KB=163,539,520.0
        MB=159,706.6
        GB=156.0

     2   DRIVE         SIZE               FREE

          C:      120,033,042,432     53,240,532,992
          D:      240,054,693,888    167,464,333,312

     3. Too lazy to run

post
https://stackoverflow.com/questions/47455337/how-to-check-available-disk-space-using-sas

Profile Raunak Thomas
https://stackoverflow.com/users/3625350/raunak-thomas

profile Richard
https://stackoverflow.com/users/1249962/richard


*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

 You need to supply a path for One and three.
 Solution two does all logical disks


 *          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __  ___
/ __|/ _ \| | | | | __| |/ _ \| '_ \/ __|
\__ \ (_) | | |_| | |_| | (_) | | | \__ \
|___/\___/|_|\__,_|\__|_|\___/|_| |_|___/

;

  %macro windows_bytes_free(sm_path);
    %global mv_bytes_free;
    /* In case of error */
    %let mv_bytes_free = -1;
    /* Run the DIR command and retrieve results using an unnamed pipe */
    filename tempdir pipe "dir /-c  ""&sm_path""  | find ""bytes free"" " ;
    data _null_;
        infile tempdir length=reclen ;
        input line $varying1024. reclen ;
        /* Parse the output of DIR using a Perl regular expression */
        re = prxparse('/([0-9]+) bytes/');
        if prxmatch(re, line) then do;
            bytes_str = prxposn(re, 1, line);
            bytes = input(bytes_str, 20.);
            /* Assign available disk space in bytes to a global macro variable */
            call symput('mv_bytes_free', bytes);
            kb = bytes /1024;
            mb = kb / 1024;
            gb = mb / 1024;
            format bytes comma20.0;
            format kb mb gb comma20.1;

            /* Write a note to the SAS log */
            put "BYTES FREE" / "&sm_path " / bytes= / kb= / mb= / gb=;
            if gb<1 then put '** Available space is less than 1 gb';
            else put '** Enough space is available';
        end;

    run;
    %if &mv_bytes_free eq -1 %then %put ERROR: error in windows_bytes_free macro;

    %mend windows_bytes_free;


    %windows_bytes_free(D:);



    filename gather pipe "wmic logicaldisk get name,size,freespace /format:csv";
    data want;
        infile gather;
        input;
        if _n_ > 2;
        _infile_ = compress(_infile_, '0d'x);
        drive = scan(_infile_,3,",");
        size  = put(input(scan(_infile_,4,","),14.),comma19.);
        free  = put(input(scan(_infile_,2,","),14.),comma19.);
     run;quit;


   * too lazy to file up unix and check this code;
   x cd &path.;
   x du -sk * -ls > d:/txt/size.txt;







