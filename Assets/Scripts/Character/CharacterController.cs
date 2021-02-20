using Photon.Pun;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterController : MonoBehaviourPun
{
    private float thrust;

    private void Update()
    {
        Movement();
    }

    private void Movement()
    {
        //Rotation
        float axisY = Input.GetAxis("Vertical");
        float axisX = Input.GetAxis("Horizontal");
        Vector3 dir = new Vector3(axisX, 0, axisY);
        if (dir.magnitude > 0)
        {
            GameServer.Instance.RequestRotate(PhotonNetwork.LocalPlayer, dir);
        }

        if (Input.GetKey(KeyCode.LeftShift))
        {
            thrust += Time.deltaTime;
        }
        else if (Input.GetKey(KeyCode.LeftControl))
        {
            thrust -= Time.deltaTime;
        }
        GameServer.Instance.RequestMove(PhotonNetwork.LocalPlayer, thrust);
        GameServer.Instance.RequestRotateElise(PhotonNetwork.LocalPlayer);
    }
}
