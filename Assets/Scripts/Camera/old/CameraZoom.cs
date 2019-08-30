using UnityEngine;

public class CameraZoom : CameraBase
{
    public float ZoomSpeed = 0.01f;

    public Vector2 ZoomBoundX = new Vector2(-5, 10);
    public Vector2 ZoomBoundY = new Vector2(-5, 10);
    public Vector2 ZoomBoundZ = new Vector2(-5, 10);
    public Vector2 OrthographicSizeBound = new Vector2(2, 10);

    private float m_distanceBetweenFingers = 500f;
    private float m_correntValue = 3f;  //touch -> mouse
    protected override void Awake()
    {
        base.Awake();

    }

    void Update()
    {
        if (CameraFocus.IsFocusOn == true)
        {
            return;
        }
        if (Input.touchSupported)
        {
            if (Input.touchCount == 2 && Input.GetTouch(0).phase == TouchPhase.Moved)
            {
                Touch _touch0 = Input.GetTouch(0);
                Touch _touch1 = Input.GetTouch(1);

                if ((_touch1.position - _touch0.position).magnitude > m_distanceBetweenFingers)
                {
                    //zoom 
                    Vector2 _touch0PrevPos = _touch0.position - _touch0.deltaPosition;
                    Vector2 _touch1PrevPos = _touch1.position - _touch1.deltaPosition;
                    float _prevTouchDeltaMagnitude = (_touch0PrevPos - _touch1PrevPos).magnitude;
                    float _touchDeltaMagnitude = (_touch0.position - _touch1.position).magnitude;
                    float _deltaMagnitudeDiff = _prevTouchDeltaMagnitude - _touchDeltaMagnitude;

                    SetCameraZoom(-_deltaMagnitudeDiff * ZoomSpeed);
                }
            }
        }
        else
        {
            float _zoomValue = Input.GetAxis("Mouse ScrollWheel");
            SetCameraZoom(_zoomValue * m_correntValue);
        }
    }

    private void SetCameraZoom(float _value)
    {
        if (m_camera.orthographic)
        {
            m_camera.orthographicSize = Mathf.Clamp(m_camera.orthographicSize + _value, OrthographicSizeBound.x, OrthographicSizeBound.y);
        }
        else
        {
            if (_value > 0)
            {
                if (transform.localPosition.x == ZoomBoundX.x || transform.localPosition.y == ZoomBoundX.x || transform.localPosition.z == ZoomBoundX.x)
                {
                    return;
                }
            }

            transform.position += _value * m_camera.transform.forward;

            Vector3 _clampedPosition = transform.localPosition;

            _clampedPosition.z = Mathf.Clamp(transform.localPosition.z, ZoomBoundZ.x, ZoomBoundZ.y);
            _clampedPosition.y = Mathf.Clamp(transform.localPosition.y, ZoomBoundY.x, ZoomBoundY.y);
            _clampedPosition.x = Mathf.Clamp(transform.localPosition.x, ZoomBoundX.x, ZoomBoundX.y);

            transform.localPosition = _clampedPosition;
        }
    }
}

