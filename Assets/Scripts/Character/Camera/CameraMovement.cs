using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMovement : MonoBehaviour
{
    public GameObject follower;
    public GameObject observable;

    [SerializeField]
    private float speed;
    [SerializeField]
    private float changeRotationSpeed;
    [SerializeField]
    private Vector3 offsetPosition;

    void Update()
    {
        FollowObject();
        LookObject();
    }

    private void LookObject()
    {
        if(observable != null)
        {
            Quaternion surfaceRotation = new Quaternion();
            surfaceRotation = Quaternion.FromToRotation(transform.up, observable.transform.up) * transform.rotation;

            transform.rotation = Quaternion.Lerp(transform.rotation, surfaceRotation, changeRotationSpeed * Time.deltaTime);
        }
    }

    private void FollowObject()
    {
        if(follower != null)
        {
            transform.position = Vector3.Lerp(transform.position, follower.transform.position + offsetPosition, speed * Time.deltaTime);
        }
    }
}
