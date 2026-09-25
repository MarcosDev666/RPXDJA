CMD:desmayarse(playerid)
{
   	Descongelar(playerid);
    SetPlayerPos(playerid, 2032.4774,-1418.9844,2010.8862);
    return 1;
}

CMD:kill(playerid,params[])
{
   SetPlayerHealth(playerid,-1);
   return 1;
}

CMD:wanted(playerid)
{
	Player[playerid][Jail]=true;
	SetPlayerWantedLevel(playerid,Player[playerid][pWanted]+=1);
	return 1;
}