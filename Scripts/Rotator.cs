using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotator : MonoBehaviour
{
    public GameObject[] ObjectList;

    private void Update()
    {
        foreach (var _obj in ObjectList)
        {
            _obj.transform.Rotate(Vector3.up * Time.deltaTime * 25f);
        }
    }
}