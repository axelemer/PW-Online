using Photon.Pun;
using TMPro;
using UnityEngine;
using Photon.Realtime;
using UnityEngine.UI;

public class CreateRoomMenu : MonoBehaviourPunCallbacks
{
    [SerializeField]
    private TextMeshProUGUI _roomName;
    [SerializeField]
    private TextMeshProUGUI _serverConnectionInfo;
    [SerializeField]
    private Button _buttonCreate;
    [SerializeField]
    private TextMeshProUGUI _nickname;

    private RoomsCanvases _roomsCanvases;

    public void FirstInitialize(RoomsCanvases canvases)
    {
        _roomsCanvases = canvases;
    }

    public void OnClick_CreateRoom()
    {
        if (!PhotonNetwork.IsConnected)
        {
            print("Not connected to Photon");
            return;
        }
        RoomOptions options = new RoomOptions();
        SetPlayerNickName();
        options.BroadcastPropsChangeToAll = true;
        options.MaxPlayers = (byte)MasterManager.GameSettings.MaxPlayers;
        PhotonNetwork.JoinOrCreateRoom(_roomName.text, options, TypedLobby.Default);
    }

    public override void OnCreatedRoom()
    {
        print("Created room succesfully");
        _roomsCanvases.CurrentRoomCanvas.Show();
    }

    public override void OnCreateRoomFailed(short returnCode, string message)
    {
        print("Room creation failed");
    }

    public override void OnConnectedToMaster()
    {
        _buttonCreate.interactable = true;
        _serverConnectionInfo.text = "Servers online";
        _serverConnectionInfo.color = Color.green;
        SetPlayerNickName();
    }

    public void SetPlayerNickName()
    {
        if (PhotonNetwork.IsConnected)
            PhotonNetwork.NickName = string.IsNullOrEmpty(_nickname.text) || _nickname.text.Length < 2 ? "Player" + Mathf.RoundToInt(Random.Range(0, 9999)).ToString() : _nickname.text;
    }
}
