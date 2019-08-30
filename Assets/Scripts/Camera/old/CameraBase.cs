using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraBase : MonoBehaviour
{
    protected Camera m_camera;
    protected virtual void Awake()
    {
        m_camera = transform.GetChild(0).GetComponent<Camera>();
    }

}
