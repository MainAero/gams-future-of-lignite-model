*Before you start make sure you work in the right project. Use ->file->Project->Open Project to get to the right place
$INCLUDE "Set_Parameters_Variables.gms"    ;
* Includes a file from project directory. If several folders in directory address as ".\Folder\Examlpe.gms"

* the file "Set_Parameters_Variables.gms" will open and the content will be executed
* go to    "Set_Parameters_Variables.gms"

*SETS
*s scenarios /1,2,3/;

ALIAS(mine, mine_e);
ALIAS(plant, plant_e);

PARAMETERS

        c_opening                               Costs for opening a new mine
                / 500000000 /
        c_unit                                  Costs for excavation
                / 10000 /
        c_extern                                External costs of a plant per MWh
                / 10 /
        c_fixed_mine                            Fixed costs for mine
                / 100000000 /
        c_maintenance                           Costs for operation and maintenance
                / 7 /
        c_transport                             Costs for transportation from mine to plant
                / 2000 /
        stabilityFactor                         Restricts changes in plant input. Between 0 and 1
                / 0.1 /
        lignite_quality                         Describes the average quality of the lignite of all districts (how much is used to produce some amount of energy)
                / 2562233.000 /
        big                                     Some value bigger than a binary 0 or 1 value for use in setNew
                / 10000000 /
        ;

POSITIVE VARIABLES
        PRODUCTION(plant, y)                    Electricity production of plant in year y
        DEMAND(plant, y)                        Amount of lignite from mine that is used in plant in year y
        OUTPUT(mine, y, plant)                  Amount of lignite produced in mine in year y for plant p
        PRODUCTION(plant, y)                    part of objective function (of)
        COST(y)                                 part of objective function (of)
        COSTSOFMINES(mine, y)                   part of objective function (of)
        COSTSOFPLANT(plant, y)                  part of objective function (of)
        COSTSOFOPENING(mine, y)                 part of objective function (of)
        ;

VARIABLES
        PROFIT                                  Overall profit for objective function
        ;

BINARY VARIABLES
        ISNEW(mine, y)                          Binary showing if a mine has been newly opened in year y
        MINE_ISOPEN(mine, y)                    Binary showing if a mine is open in year y
        ;

EQUATIONS
        objective                               objective function
        production_eq(plant, y)                 part of the objective function
        cost_eq(y)                              part of the objective function
        costsOfMines_eq(mine, y)                part of the objective function
        costsOfPlant_eq(plant, y)               part of the objective function
        costsOfOpening_eq(mine, y)              part of the objective function
        mineSupplyCap(mine)                     The overall stock of a mine
        mineProductionCap(mine, y)              The cap of production per mine and year
        transportCap(mine, plant, y)            The cap of transportation between plants and mines
        equality(y)                             Input of plants equals output of mines. Everything is used
        equality2(y, plant)                     All demand has to be fullfilled by mines
        setdemand(plant, y)                     Calculates the input demand of lignite for a plant
        setNew1(y, mine)                        Tracks if a mine is newly opened
        setNew2(y, mine)                        Tracks if a mine is newly opened
        openOnce(mine)                         Only open a mine once. Keeps a mine close if it was closed one time.
        ;

* Objective function and its parts
objective..                     PROFIT                       =e= sum(y, price(y) * sum(plant, PRODUCTION(plant, y)) - COST(y));
production_eq(plant, y)..       PRODUCTION(plant, y)         =e= nominal_Output(plant) * flh(plant, y) * plant_isopen(plant, y);
cost_eq(y)..                    COST(y)                      =e= sum(mine, COSTSOFMINES(mine, y)) + sum(plant, COSTSOFPLANT(plant, y)) + sum(mine, COSTSOFOPENING(mine, y));
costsOfMines_eq(mine, y)..      COSTSOFMINES(mine, y)        =e= sum(plant, OUTPUT(mine, y, plant)) * (c_unit + c_transport) + c_fixed_mine * MINE_ISOPEN(mine, y);
costsOfPlant_eq(plant, y)..     COSTSOFPLANT(plant,y)        =e= PRODUCTION(plant, y) * (c_maintenance + c_extern) + c_fixed_plant(plant) * plant_isopen(plant, y);
costsOfOpening_eq(mine, y)$(ord(y) > 1)..    COSTSOFOPENING(mine, y)      =e= ISNEW(mine,y ) * (c_opening + c_relocation(mine));

* Calculate the demand of plants
setdemand(plant, y)..           DEMAND(plant, y)                                        =e= (PRODUCTION(plant, y) / (lignite_quality * efficiency(plant))) * plant_isopen(plant, y);

* Sets caps for the model
mineSupplyCap(mine)..           sum((y, plant), OUTPUT(mine, y, plant))                 =l= cap_mine(mine);
mineProductionCap(mine, y)..    sum(plant, OUTPUT(mine, y, plant))  =l= cap_minePerYear(mine) * MINE_ISOPEN(mine, y);
transportCap(mine, plant, y)..  OUTPUT(mine, y, plant) =l= cap_transport(plant,mine);

* Links some values
equality(y)..                   sum((mine, plant), OUTPUT(mine, y, plant))      =e= sum(plant, DEMAND(plant, y));
equality2(y, plant)..           DEMAND(plant, y)                                =e= sum(mine, OUTPUT(mine, y, plant));

* Finds out when a mine has opened
setNew1(y, mine)$(ord(y) > 1).. MINE_ISOPEN(mine, y) =l= MINE_ISOPEN(mine, y-1) + big * ISNEW(mine, y);
setNew2(y, mine)$(ord(y) > 1).. MINE_ISOPEN(mine, y) =g= MINE_ISOPEN(mine, y-1) + 1e-6 - big * (1- ISNEW(mine, y));

* Makes sure that a mine is only opened once
openOnce(mine).. sum(y, ISNEW(mine, y)) =l= 1;

* Locks in some starting values (e.g. in the next 3 years no running mines will be closed)
MINE_ISOPEN.fx(mine, setyears) = 1;
MINE_ISOPEN.fx('Jänschwalde-Nord', setyears) = 0;
MINE_ISOPEN.fx('Nochten 2', setyears) = 0;
MINE_ISOPEN.fx('Welzow-Süd 2', setyears) = 0;
MINE_ISOPEN.fx('Erweiterung Vereinigtes Schleenhain', setyears) = 0;
MINE_ISOPEN.fx('new mine rhenish region', setyears) = 0;

* Sets for the first year all open mines to new
ISNEW.fx(mine, '2016') = 1;
ISNEW.fx('Jänschwalde-Nord', '2016') = 0;
ISNEW.fx('Nochten 2', '2016') = 0;
ISNEW.fx('Welzow-Süd 2', '2016') = 0;
ISNEW.fx('Erweiterung Vereinigtes Schleenhain', '2016') = 0;
ISNEW.fx('new mine rhenish region', '2016') = 0;

*with this option gams puts the results of your model into a file with the name modelname_p.gdx
OPTION Savepoint = 1;

* choose right solver
MODEL lignite /all/;
SOLVE lignite using mip maximizing PROFIT;

DISPLAY PROFIT.l, DEMAND.l, OUTPUT.l, nominal_Output, ISNEW.l, MINE_ISOPEN.l, flh, lignite_quality, efficiency,
cap_transport, cap_minePerYear, plant_isopen, COSTSOFOPENING.l, COSTSOFMINES.l, COSTSOFPLANT.l, PRODUCTION.l, price, COST.l, c_fixed_plant;


*unload the data you want to put in excel into a "results.gdx" file
execute_unload "results.gdx"  cap_minePerYear, COST, MINE_ISOPEN, PRODUCTION, COSTSOFPLANT, COSTSOFOPENING, COSTSOFMINES, OUTPUT ;

*write data from "results.gdx" to in Excel to Results.xlsx
*UpdLinks => recalculate excel sheets before writing results
*Results.txt contains details on data to be written in Excel sheet
execute 'gdxxrw.exe i=results.gdx UpdLinks =3 o= Results.xlsx @Results.txt';

