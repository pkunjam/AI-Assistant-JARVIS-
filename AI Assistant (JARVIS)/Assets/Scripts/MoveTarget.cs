using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveTarget : MonoBehaviour
{

    public static IEnumerator MoveTargetToDestinations(GameObject gameObject)
    {
        while (true)
        {
            if (Vector3.Distance(gameObject.transform.position, Vector3.zero) <= 0)
                break;

            gameObject.transform.position = Vector3.MoveTowards(gameObject.transform.position, Vector3.zero, 5 * Time.deltaTime);
            yield return null;
        }
    }
}
