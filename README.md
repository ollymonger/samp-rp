# samp-rp
roleplay script w/ mysql

## needed scripts:
MYSQL R41-4
easyDialog.inc
bcrypt.inc
streamer plugin

## CurrentState:
* 0 = Ready for task, 1 = Doing a job task, 

## Jobs: (in this order)
* Postman (ID1)
* Garbageman (ID2)
* Busdriver (ID3)
* Drug dealer (ID4)

## Factions: (in this order)
* Fort Caron Sheriff's Office (ID1)
* Fort Carson EMS (ID2)

## Faction Types:
1 - gangs,
2 - legal

## Businesses: (in this order)
Businesses with an interior ID set the X Y Z of the exit. This way, we can use original SA mappings.
If it is 0, then it will not assign an ID and allow the admin to create the entry in the DB as it must use other mappings.
Int ids: 16 // 24-7, 6 // ammunation or hardware store.
* Hardware store (TYPE 1) :
    Ability to buy phones, gps
* General Store (TYPE 2)
    Ability to buy cigarretes, lotto tickets, rope, masks, ect
* Ammunation (type 3)
    Ability to buy guns if you have gun license.
* Car Rental (type 4)
    Ability to gain money from rental cars if the rental car has an assigned business. if none, it must be a job specific rental car, and players will not be able to earn business salary from it.
* Car Dealership (type 5)
    Owner can gain money from players buying vehicles! 

## House Types
    5 - Ganghouse, exit point: 2350.339843,-1181.649902,1027.976562

## Prison types
1, normal prison
2, admin jail

## States
* 0 VEHICLE_NOT_RENTABLE 0 (Vehcile is either already rented or not rentable in )
* 1 VEHICLE_RENTABLE 1 (Vehicle is rentable, either a job rentcar or normal rentcar available for all players)
* 2 VEHICLE_PLAYER_OWNED 2 (Vehicle player owned, not rentable)