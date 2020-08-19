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

## Businesses: (in this order)
* Hardware store (TYPE 1) :
    Ability to buy phones, gps
* General Store (TYPE 2)
    Ability to buy cigarretes, lotto tickets, rope, masks, ect
* Ammunation (type 3)
    Ability to buy guns if you have gun license.
* Car Rental (type 4)
    Ability to gain money from rental cars if the rental car has an assigned business. if none, it must be a job specific rental car, and players will not be able to earn business salary from it.

## States
* 0 VEHICLE_NOT_RENTABLE 0 (Vehcile is either already rented or not rentable in )
* 1 VEHICLE_RENTABLE 1 (Vehicle is rentable, either a job rentcar or normal rentcar available for all players)
* 2 VEHICLE_PLAYER_OWNED 2 (Vehicle player owned, not rentable)