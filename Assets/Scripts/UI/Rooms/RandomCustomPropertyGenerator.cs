using Photon.Pun;
using TMPro;
using UnityEngine;

public class RandomCustomPropertyGenerator : MonoBehaviour
{
    [SerializeField]
    private TextMeshProUGUI _text;

    private ExitGames.Client.Photon.Hashtable _myCustomProperty = new ExitGames.Client.Photon.Hashtable();

    private void Start()
    {
        SetCustomNumber();
    }

    private void SetCustomNumber()
    {
        if (_myCustomProperty.ContainsKey("PlayerTeam"))
        { 
            if((int)_myCustomProperty["PlayerTeam"] == 1)
                _myCustomProperty["PlayerTeam"] = 2;
            else
                _myCustomProperty["PlayerTeam"] = 1;
        }
        else
        {
            _myCustomProperty["PlayerTeam"] = 1;
        }

        PhotonNetwork.SetPlayerCustomProperties(_myCustomProperty);
        //PhotonNetwork.LocalPlayer.CustomProperties = _myCustomProperty;
    }

    public void OnClick_Button()
    {
        SetCustomNumber();
    }
}