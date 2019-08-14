using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraFocus : CameraBase
{
    public static bool IsFocusOn;
    public float OutlineWidth = 0.5f;

    private const string SELECTABLE = "SELECTABLE";

    private GameObject m_target;

    private Vector3 m_defaultPosition;
    private Vector3 m_velocity = Vector3.zero;
    private float m_smooth = 180f;
    private float m_smoothTime = 0.15f;

    private System.Action m_updateCamera;
    
    protected override void Awake()
    {
        base.Awake();
        m_defaultPosition = m_camera.transform.position;
        IsFocusOn = false;
        m_updateCamera = UpdateEmpty;
    }

    private void Update()
    {
        if (IsFocusOn == true)
        {
            if (Input.GetKey(KeyCode.Escape))
            {
                m_updateCamera = UpdateDefault;
                m_target.GetComponent<MeshRenderer>().material.SetFloat("_Outline", 0f);
                IsFocusOn = false;
            }
        }
        else
        {
            if (Input.touchSupported)
            {
                if (Input.touchCount == 1 && Input.GetTouch(0).phase == TouchPhase.Ended)
                {
                    Touch _touch = Input.GetTouch(0);
                    SelectObject(_touch.position);
                }
            }
            else
            {
                if (Input.GetMouseButtonUp(0))
                {
                    SelectObject(Input.mousePosition);
                }
            }
        }
    }

    private void SelectObject(Vector3 _position)
    {
        var _ray = m_camera.ScreenPointToRay(Input.mousePosition);
        RaycastHit _hit;
        if (Physics.Raycast(_ray, out _hit))
        {
            var _selection = _hit.transform.gameObject;

            if (_selection.CompareTag(SELECTABLE))
            {
                IsFocusOn = true;
                m_target = _selection;
                m_target.GetComponent<MeshRenderer>().material.SetFloat("_Outline", OutlineWidth);
                m_updateCamera = UpdateTarget;
            }
        }
    }

    private void SelectObject(Vector2 _position)
    {
        var _ray = m_camera.ScreenPointToRay(Input.mousePosition);
        RaycastHit _hit;
        if (Physics.Raycast(_ray, out _hit))
        {
            var _selection = _hit.transform.gameObject;

            if (_selection.CompareTag(SELECTABLE))
            {
                IsFocusOn = true;
                m_target = _selection;
                m_target.GetComponent<MeshRenderer>().material.SetFloat("_Outline", OutlineWidth);
                m_updateCamera = UpdateTarget;
            }
        }
    }

    private void LateUpdate()
    {
        m_updateCamera();
    }

    private void UpdateEmpty()
    {
       
    }

    private void UpdateCameraRootToZero()
    {
        transform.localPosition = Vector3.SmoothDamp(transform.localPosition, Vector3.zero, ref m_velocity, 0.05f);
        if ((transform.localPosition - Vector3.zero).magnitude < 0.1f)
        {
            m_updateCamera = UpdateEmpty;
        }
    }

    private void UpdateTarget()
    {
        var _targetPosition = m_target.transform.position - m_camera.transform.forward * 5f;
        m_camera.transform.position = Vector3.SmoothDamp(m_camera.transform.position, _targetPosition, ref m_velocity, m_smoothTime);
    }

    private void UpdateDefault()
    {
        
        m_camera.transform.localPosition = Vector3.SmoothDamp(m_camera.transform.localPosition, m_defaultPosition, ref m_velocity, m_smoothTime);
        transform.localRotation = Quaternion.RotateTowards(transform.localRotation, Quaternion.identity, Time.deltaTime * m_smooth);

        if ((m_camera.transform.localPosition - m_defaultPosition).magnitude < 1f && transform.localRotation == Quaternion.identity)
        {
            m_updateCamera = UpdateCameraRootToZero;
        }
    }
}
