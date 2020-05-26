using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveTarget : MonoBehaviour
{

    public static IEnumerator MoveTargetToDestinations(GameObject gameObject)
    {
        while (true)
        {
            if (Vector3.Distance(gameObject.transform.localPosition, Vector3.zero) <= 0)
                break;

            gameObject.transform.localPosition = Vector3.MoveTowards(gameObject.transform.localPosition, Vector3.zero, 50 * Time.deltaTime);
            yield return null;
        }
    }
}
