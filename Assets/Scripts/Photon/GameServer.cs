using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Photon.Pun;
using Photon.Realtime;

public class GameServer : MonoBehaviourPun
{
    public static GameServer Instance;
    public string pathPrefab;
    public CharacterController controllerPrefab;
    Player _server;
    int _count = 0;
    public Transform[] spawnPoints;
    Dictionary<Player, CharacterModel> _dic = new Dictionary<Player, CharacterModel>();
    void Start()
    {
        if (Instance == null)
        {
            Instance = this;
            if (PhotonNetwork.IsMasterClient)
            {
                photonView.RPC("SetServer", RpcTarget.AllBuffered, PhotonNetwork.LocalPlayer);
            }
        }
    }
    [PunRPC]
    void SetServer(Player client)
    {
        print("Setting server...");
        _server = client;
        if (PhotonNetwork.LocalPlayer != _server)
        {
            photonView.RPC("AddPlayer", _server, PhotonNetwork.LocalPlayer);
            Instantiate<CharacterController>(controllerPrefab);
        }
        print("Server up");
    }
    [PunRPC]
    void AddPlayer(Player client)
    {
        var obj = PhotonNetwork.Instantiate(pathPrefab, spawnPoints[_count].position, spawnPoints[_count].rotation);
        CharacterModel character = obj.GetComponent<CharacterModel>();
        _dic.Add(client, character);
        _count++;
    }


    #region Requests
    public void RequestMove(Player client, float inputThrust)
    {
        photonView.RPC("Move", _server, client, inputThrust);
    }
    public void RequestRotate(Player client, Vector3 dir)
    {
        photonView.RPC("Rotate", _server, client, dir);
    }
    public void RequestRotateElise(Player client)
    {
        photonView.RPC("RotateElise", _server, client);
    }

    public void RequestShoot(Player client)
    {
        photonView.RPC("Shoot", _server, client);
    }

    #endregion

    #region RPC´s
    [PunRPC]
    public void Move(Player client, float f)
    {
        if (!_dic.ContainsKey(client)) return;
        _dic[client].Move(f);
    }

    [PunRPC]
    public void Rotate(Player client, Vector3 dir)
    {
        if (!_dic.ContainsKey(client)) return;
        _dic[client].Rotate(dir);
    }

    [PunRPC]
    public void Shoot(Player client)
    {
        if (!_dic.ContainsKey(client)) return;
        _dic[client].Shoot();
    }

    [PunRPC]
    public void RotateElise(Player client)
    {
        if (!_dic.ContainsKey(client)) return;
        _dic[client].RotateElise();
    }

    #endregion
}
