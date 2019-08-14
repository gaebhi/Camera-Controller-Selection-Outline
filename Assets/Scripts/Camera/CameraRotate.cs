using UnityEngine;

public class CameraRotate : CameraBase
{
    public float RotationSpeed = 0.35f;

    public Vector2 RotationBoundX = new Vector2(-18, 18);
    public Vector2 RotationBoundY = new Vector2(-45, 45);
    public Vector2 RotationBoundZ = new Vector2(-18, 18);

    private Vector3 m_lastMousePosition;
    private bool m_isMouseDown;

    private float m_distanceBetweenFingers = 500f;
    private float m_correntValue = 85f;  //touch -> mouse
    protected override void Awake()
    {
        base.Awake();
    }

    void Update()
    {
        if (Input.touchSupported)
        {
            if (Input.touchCount == 2 && Input.GetTouch(0).phase == TouchPhase.Moved)
            {
                Touch _touch0 = Input.GetTouch(0);
                Touch _touch1 = Input.GetTouch(1);

                float _touchDeltaMagnitude = (_touch0.position - _touch1.position).magnitude;

                if (_touchDeltaMagnitude < m_distanceBetweenFingers)
                {
                    SetCameraRotation(_touch0.deltaPosition * RotationSpeed);
                }
            }
        }
        else
        {
            if (Input.GetMouseButtonDown(1))
            {
                m_lastMousePosition = Input.mousePosition;
                m_isMouseDown = true;
            }
            if (Input.GetMouseButtonUp(1))
            {
                m_isMouseDown = false;
            }

            if (m_isMouseDown)
            {
                Vector3 _delta = m_camera.ScreenToViewportPoint(Input.mousePosition - m_lastMousePosition);
                SetCameraRotation(_delta * m_correntValue);
                m_lastMousePosition = Input.mousePosition;
            }
        }
    }

    private void SetCameraRotation(Vector3 _delta)
    {
        if (Mathf.Abs(_delta.x) >= Mathf.Abs(_delta.y))
        {
            var _value = _delta.x * RotationSpeed;
            transform.RotateAround(Vector3.zero, Vector3.up, _value);

            float _y = transform.rotation.eulerAngles.y;

            if (_y > 100f)
            {
                _y = transform.rotation.eulerAngles.y - 360f;
            }

            _y = Mathf.Clamp(_y, RotationBoundY.x, RotationBoundY.y);

            Vector3 _clampRotation = transform.localRotation.eulerAngles;
            _clampRotation.y = _y;
            transform.localRotation = Quaternion.Euler(_clampRotation);
        }
        else
        {
            var _value = _delta.y * RotationSpeed;

            if (_value < 0)
            {
                if (transform.rotation.eulerAngles.x == RotationBoundX.x || transform.rotation.eulerAngles.z == RotationBoundZ.y)
                {
                    return;
                }
            }
            else if(_value > 0)
            {
                if (transform.rotation.eulerAngles.x == RotationBoundX.y || transform.rotation.eulerAngles.z == RotationBoundZ.x)
                {
                    return;
                }
            }


            transform.RotateAround(Vector3.zero, m_camera.transform.right, -_value);

            float _x = transform.rotation.eulerAngles.x;
            if (_x > 300f)
            {
                _x = _x - 360f;
            }

            float _z = transform.rotation.eulerAngles.z;
            if (_z > 300f)
            {
                _z = _z - 360f;
            }

            Vector3 _clampRotation = transform.rotation.eulerAngles;
            _clampRotation.x = Mathf.Clamp(_x, RotationBoundX.x, RotationBoundX.y);
            _clampRotation.z = Mathf.Clamp(_z, RotationBoundZ.x, RotationBoundX.y);

            transform.localRotation = Quaternion.Euler(_clampRotation);
        }
    }
}
