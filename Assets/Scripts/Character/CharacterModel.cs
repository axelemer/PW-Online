using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterModel : MonoBehaviour
{
    [SerializeField]
    private float maxSpeed;
    [SerializeField]
    private float rollForce;
    [SerializeField]
    private float pitchForce;
    [SerializeField]
    private float minPower;
    [SerializeField]
    private float maxPower;

    private float thrust;

    public float force;

    public GameObject eliseGameObject;
    public GameObject camPosGameObject;

    public float EnginePower
    {
        get
        {
            thrust = thrust > maxPower ? maxPower : thrust;
            thrust = thrust < minPower ? minPower : thrust;
            return thrust;
        }
        set
        {
            value = thrust;
        }
    }

    private void Start()
    {
        thrust = minPower;

        Camera camera = FindObjectOfType<Camera>();
        if(camera != null)
        {
            CameraMovement camMove = camera.GetComponent<CameraMovement>();
            camMove.follower = camPosGameObject;
            camMove.observable = this.gameObject;
        }
    }


    public void Rotate(Vector3 dir)
    {
        transform.RotateAround(transform.position, transform.forward, -dir.x * rollForce);
        transform.RotateAround(transform.position, transform.right, dir.z * pitchForce);
    }


    public void Move(float thrust)
    {
        this.thrust = thrust;
        transform.position += transform.forward * EnginePower * force * Time.deltaTime;
        //RotateElise();
    }

    public void Shoot()
    {

    }

    public void RotateElise()
    {
        if (eliseGameObject != null)
        {
            eliseGameObject.transform.RotateAround(eliseGameObject.transform.position, eliseGameObject.transform.forward, EnginePower);
        }
    }
}
