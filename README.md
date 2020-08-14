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

## States
* 0 VEHICLE_NOT_RENTABLE 0 (Vehcile is either already rented or not rentable in )
* 1 VEHICLE_RENTABLE 1 (Vehicle is rentable, either a job rentcar or normal rentcar available for all players)
* 2 VEHICLE_PLAYER_OWNED 2 (Vehicle player owned, not rentable)