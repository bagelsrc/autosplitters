state("LegoRacers", "2001")
{
    int track  : 0xEF810, 0xC;
    int points : 0xEF31C, 0x18;
    int timer  : 0xF11C0, 0x2A8, 0x434;
    int lap : 0x0F11C0, 0x10, 0xC4;
    //int laptimer: 0x0F11F0, 0x204, 0x6E4, 0xE0;
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

                13983114 // RRR
            };

            break;
        }
    }
}


start
{
    return current.timer > 0 && current.timer < 50 && current.track == vars.trackList[0];
}

split
{
    return current.lap == 3 && old.lap == 2 && (vars.trackList.Contains(current.track));
}

reset
{
    return current.timer == 0 && current.track == vars.trackList[0] && current.points == 0 && old.points < 100;
}

isLoading
{
    return !vars.trackList.Contains(current.track) && current.track < 14600000;
}
