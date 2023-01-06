state("LegoRacers", "2001")
{
    int track  : 0xEF810, 0xC;
    int points : 0xEF31C, 0x18;
    int timer  : 0xF11C0, 0x2A8, 0x434;
    int lap : 0x0F11C0, 0x10, 0xC4;
    //int laptimer: 0x0F11F0, 0x204, 0x6E4, 0xE0;
    // int lap1: 0x0F11C0, 0x200, 0xCE8;
    // int lap2: 0x0F11C0, 0x204, 0x4, 0x810;

    int tlap1: 0x0F11C0, 0x200, 0xCE8;
    int tlap2: 0x0F11C0, 0x200, 0xCEC;
    int tlap3: 0x0F11C0, 0x200, 0xCF0;
    
    int clap1: 0x0F11D8, 0xC, 0x284, 0xCE8;
    int clap2: 0x0F11D8, 0xC, 0x284, 0xCEC;
    int clap3: 0x0F11D8, 0xC, 0x284, 0xCF0;
}

state("LegoRacers", "1999")
{
    int track  : 0xC4E08, 0x20;
    int points : 0xC4914, 0x18;
    int timer  : 0xC67D4, 0x10, 0xCC;
    int lap : 0x0C67B0, 0x294, 0x768;
}



init
{
    var mms = modules.First().ModuleMemorySize;
    print("0x" + mms.ToString("X"));

    vars.inrace = false;
    vars.InGameTime = "";
    vars.InGameRaceTime = "";
    vars.totaltime = 0;
    vars.racetime = 0;
    vars.test = true;


  switch (mms)
  {
    case 0xFF000: version = "2001"; break;
    case 0xD1000: version = "1999"; break;
  }

    switch (mms)
    {
        case 0xFF000:
        {
            version = "2001";

            vars.trackList = new List<int>
            {
                4267672, // IGP
                4268268, // IGP TT

                6953738, // DFD
                6954370, // DFD TT

                6026842, // MMM
                6027450, // MMM TT

                5192798, // DAD
                5193528, // DAD TT

                7848460, // TIT
                7849118, // TIT TT

                3485718, // RKR
                3486396, // RKR TT

                9483708, // IPP
                9484400, // IPP TT

                8656570, // AAA
                8657082, // AAA TT

                10546956, // KAT
                10547850, // KAT TT

                11432210, // PSP
                11432936, // PSP TT

                12371382, // ATT
                12372276, // ATT TT

                13232192, // ARA
                13232952, // ARA TT

                13950156 // RRR
            };

            break;
        }
        case 0xD1000:
        {
            version = "1999";

            vars.trackList = new List<int>
            {
                4249858, // IGP
                4250454, // IGP TT

                6935924, // DFD
                6936556, // DFD TT

                6009028, // MMM
                6009636, // MMM TT

                5174984, // DAD
                5175714, // DAD TT

                7830646, // TIT
                7831304, // TIT TT

                3467904, // RKR
                3468582, // RKR TT

                9465894, // IPP
                9466586, // IPP TT

                8638756, // AAA
                8639268, // AAA TT

                10529142, // KAT
                10530036, // KAT TT

                11465168, // PSP
                11465894, // PSP TT

                12404340, // ATT
                12405234, // ATT TT
                
                13265150, // ARA
                13265910, // ARA TT

                13933114 // RRR
            };

            break;
        }
    }
}




update
{
    int c3lap = current.clap1 + current.clap2 + current.clap3;  // 3 lap timer if in circuit mode
    int t3lap = current.tlap1 + current.tlap2 + current.tlap3;  // 3 lap timer if in time race

    vars.test = (c3lap-20 > t3lap);

    int racetimer = (c3lap > 0 && !(c3lap-20 > t3lap))? c3lap :(t3lap > 0)? t3lap : 0; // selects timer based on mode


// updating the total timer pool ---

  // on race completion
    if ( current.lap > old.lap && current.lap == 3 )  {

        if(c3lap > 0) { // in circuit mode
            // add the floor of each lap to the total timer pool
            vars.totaltime = vars.totaltime + ( ((current.clap1/10)*10) + ((current.clap2/10)*10) + ((current.clap3/10)*10) );
        }
        else if (t3lap > 0) { // in time race
            // add the floor of the sum of the 3 laps to the total timer pool
            vars.totaltime = vars.totaltime + ((t3lap/10)*10);
        }
    }


  // on track restart
    else if ( vars.inrace && vars.racetime > 0 ) {  // check if previous frame was in race

        vars.inrace =  !( (current.lap <= 0 && racetimer == 0) || current.lap == 3 );   // update inrace status

        if(!vars.inrace && racetimer == 0) {    // check if current frame is not in race
            // add the old timer to the timer pool

            if(old.clap1 > 0) { // was in circuit mode
                // add the floor of each lap to the total timer pool
                vars.totaltime = vars.totaltime + ( ((old.clap1/10)*10) + ((old.clap2/10)*10) + ((old.clap3/10)*10) );
            }
            else if (old.tlap1 > 0) { // was in time race
                // add the floor of the sum of the 3 laps to the total timer pool
                vars.totaltime = vars.totaltime + (( (old.tlap1 + old.tlap2 + old.tlap3) /10)*10);
            }
        }   
    }



    vars.inrace =  !( (current.lap <= 0 && racetimer == 0) || current.lap == 3 );   // update inrace status for next frame
    vars.racetime = racetimer;  // update racetime for next frame



// formatting the in game timer ---

    vars.InGameTime = "";
    int t = vars.totaltime;     // set timer to current timer pool
    if(current.lap != 3) {      // if in race, add the current race time
        t = t + racetimer;
    }


    // get digits from timer
    int ms = ( t / 10 ) % 100;
    int s = ( t / 1000 ) % 60;
    int m = ( t / 1000 ) / 60;
    int hr = ( t / (1000*60*60) ) % 24;


    // append milliseconds (with a leading zero)
    vars.InGameTime = ms;
    if(ms < 10) { vars.InGameTime = "0" + vars.InGameTime; }

    // append seconds
    vars.InGameTime = s + "." + vars.InGameTime;

    // if enough time has elapsed, add the minutes (with a leading zero on the seconds)
    if(m > 0) {                
        if(s < 10) { vars.InGameTime = "0" + vars.InGameTime; }
        vars.InGameTime = m + ":" + vars.InGameTime;
    }

    // if enough time has elapsed, add the hours
    if(hr > 0) { vars.InGameTime = hr + ":" + vars.InGameTime; }



// formatting the in game race timer ---

    vars.InGameRaceTime = "";
    int t2 = racetimer;

    // decimal correction
    if ( current.lap == 3 )  {
        if(c3lap > 0) { // in circuit mode
            t2 = ((current.clap1/10)*10) + ((current.clap2/10)*10) + ((current.clap3/10)*10) ;
        }
        else if (t3lap > 0) { // in time race
            t2 = (t3lap/10)*10;
        }
    }

    // get digits from timer
    int ms2 = ( t2 / 10 ) % 100;
    int s2 = ( t2 / 1000 ) % 60;
    int m2 = ( t2 / 1000 ) / 60;
    int hr2 = ( t2 / (1000*60*60) ) % 24;


    // append milliseconds (with a leading zero)
    vars.InGameRaceTime = ms2;
    if(ms2 < 10) { vars.InGameRaceTime = "0" + vars.InGameRaceTime; }

    // append seconds
    vars.InGameRaceTime = s2 + "." + vars.InGameRaceTime;

    // if enough time has elapsed, add the minutes (with a leading zero on the seconds)
    if(m2 > 0) {                
        if(s2 < 10) { vars.InGameRaceTime = "0" + vars.InGameRaceTime; }
        vars.InGameRaceTime = m2 + ":" + vars.InGameRaceTime;
    }

    // if enough time has elapsed, add the hours
    if(hr2 > 0) { vars.InGameRaceTime = hr2 + ":" + vars.InGameRaceTime; }

}



start
{
    vars.inrace = false;
    vars.InGameTime = "";
    vars.InGameRaceTime = "";
    vars.totaltime = 0;
    vars.racetime = 0;

    return current.timer > 0 && current.timer < 50 && current.track == vars.trackList[0];
}

split
{
    return current.lap > old.lap && current.lap == 3;
}

reset
{
    return current.timer == 0 && current.track == vars.trackList[0] && current.points == 0;
}

isLoading
{
    return !vars.trackList.Contains(current.track) && current.track < 14600000;
}
