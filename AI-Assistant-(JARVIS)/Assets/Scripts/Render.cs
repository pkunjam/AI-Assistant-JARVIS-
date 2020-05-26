using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Render : MonoBehaviour
{
    //public static int size;
    //public GameObject[] gameObjects = new GameObject[size];
    //public float speed;


    //void Start()
    //{
    //    StartCoroutine(MoveTargetToDestinations(gameObjects, speed));
    //}

    public static IEnumerator MoveTargetToDestinations(GameObject[] gameObjects, float speed)
    {
        foreach (var gameObject in gameObjects)
        {
            while (true)
            {
                if (Vector3.Distance(gameObject.transform.localPosition, Vector3.zero) <= 0f)
                    break;

                gameObject.transform.localPosition = Vector3.MoveTowards(gameObject.transform.localPosition, Vector3.zero, speed * Time.deltaTime);
                yield return null;
            }
        }
    }
}
