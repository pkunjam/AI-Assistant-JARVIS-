using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour
{
    public int speed;

    void Update()
    {
        transform.Rotate(new Vector3(0, Time.deltaTime * speed, 0));
    }
}
