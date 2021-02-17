using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(menuName = "Manager/GameSettings")]
public class GameSettings : SingletonScriptableObject<GameSettings>
{
    [SerializeField]
    private string _gameVersion = "0.1";
    public string GameVersion { get { return _gameVersion; } }

    [SerializeField]
    private int _maxPlayers = 10;
    public int MaxPlayers { get { return _maxPlayers; } }

    [SerializeField]
    private int _minPlayers = 1;
    public int MinPlayers { get { return _minPlayers; } }

    [SerializeField]
    private string _nickName = "Axel";
    public string NickName {
        get
        {
            int value = Random.Range(0, 9999);
            return _nickName + value.ToString();
        }
    }
}
