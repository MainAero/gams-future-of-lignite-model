*This file includes all sets, parameters and variables


*************Producer Sets*****************************************
sets
mine              mines
plant             plants
header            Headers of Sources-Sheet Columns
y                 years /2016*2050/
setyears(y)       years that we set the values for /2016*2018/;

********************************************************************************
************** Producer Parameters *********************************************
********************************************************************************
parameters
minedata(mine, *)          Batch parameter containing all Producer Information
plantdata(plant,*)
cap_mine(mine)                  capacity of the individual facility
cap_minePerYear(mine)        Capacity of the mine in year y
efficiency(plant)               Efficiency of plant
plant_isopen(plant, y)          Binary showing if a plant is open in year y
c_relocation(mine)               costs for resettlement
cap_transport(plant,mine)      Max amount of lignite that can be transported from mine to plant in one year
flh(plant, y)                Full load hour per year of a plant in a scenario s
c_fixed_plant                           Fixed costs for plant
nominal_Output(plant)                          Full output of a plant
price(y)                     Price of electricity per year in a scenario    ;



* the next line reads in data from "InputData.xlsx"
* UpLinks =3 updates the tables in the respective excel file before doing anything else
* an output file inputdata.gdx will be generated
* the data to be written into the gdx is in inputdata.txt
* next: take a look at inputdata.txt

$onUNDF
$call "gdxxrw.exe InputData.xlsx UpdLinks =3 MaxDupeErrors = 100 o=inputdata.gdx  @Inputdata_s3.txt"


********************************************************************************
************** Parameter Import*************************************************
********************************************************************************

*Reads in inputdata.gdx and loads the following data into Gams so that it can be further used
$GDXIN   inputdata.gdx
$LOAD    mine
$LOAD    plant
$LOAD    minedata
$LOAD    plantdata
$LOAD    plant_isopen
$LOAD    cap_transport
$LOAD    flh
$LOAD    header
$LOAD    price
$GDXIN




********************************************************************************
************** Parameter Assignment - Producer**********************************
********************************************************************************

*at this point the sets and the parameter producerdata has been loaded into Gams and can be usded to assign the parameters for the model
cap_mine(mine) =  minedata(mine,"cap_mine");
cap_minePerYear(mine) =  minedata(mine,"cap_minePerYear");
*lignite_quality(mine) = minedata(mine,"lignite_quality");
efficiency(plant) = plantdata(plant,"efficiency");
c_fixed_plant(plant) = plantdata(plant,"c_fixed_plant");
c_relocation(mine) = minedata(mine,"c_relocation");
nominal_Output(plant) = plantdata(plant,"Netto-Nennleistung MW");
Display header, minedata, cap_mine, cap_minePerYear, plantdata, efficiency, plant_isopen, flh, c_relocation, cap_transport;

* at this point the execution goes back to the file where this file was called


