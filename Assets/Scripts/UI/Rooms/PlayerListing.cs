using ExitGames.Client.Photon;
using Photon.Pun;
using Photon.Realtime;
using TMPro;
using UnityEngine;

public class PlayerListing : MonoBehaviourPunCallbacks
{
    [SerializeField]
    private TextMeshProUGUI _text;

    public Player Player { get; private set; }

    public void SetPlayerInfo(Player player)
    {
        Player = player;
        SetPlayerText(player);
    }

    public override void OnPlayerPropertiesUpdate(Player targetPlayer, Hashtable changedProps)
    {
        base.OnPlayerPropertiesUpdate(targetPlayer, changedProps);
        if(targetPlayer != null && targetPlayer == Player)
        {
            if(changedProps.ContainsKey("PlayerTeam"))
            {
                SetPlayerText(targetPlayer);
            }
        }
    }

    private void SetPlayerText(Player player)
    {
        int team = 1;
        if (player.CustomProperties.ContainsKey("PlayerTeam"))
            team = (int)player.CustomProperties["PlayerTeam"];

        _text.text = team.ToString() + " - " + player.NickName;
    }
}
