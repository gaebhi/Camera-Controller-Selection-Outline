using UnityEngine;

public class CameraMove : CameraBase
{

    public float MovementSpeed = 0.01f;

    public Vector2 PositionBoundX = new Vector2(-5, 10);
    public Vector2 PositionBoundY = new Vector2(-5, 10);
    public Vector2 PositionBoundZ = new Vector2(-5, 10);

    private Vector3 m_lastMousePosition;
    private bool m_isMouseDown;
    private float m_correntValue = 10f;  //touch -> mouse
    protected override void Awake()
    {
        base.Awake();
    }

    void Update ()
    {
        if (CameraFocus.IsFocusOn == true)
        {
            return;
        }
        if (Input.touchSupported)
        {
            if (Input.touchCount == 1 && Input.GetTouch(0).phase == TouchPhase.Moved)
            {
                SetCameraPosition(Input.GetTouch(0).deltaPosition);
            }
        }
        else
        {
            if (Input.GetMouseButtonDown(0))
            {
                m_lastMousePosition = Input.mousePosition;
                m_isMouseDown = true;
            }
            if (Input.GetMouseButtonUp(0))
            {
                m_isMouseDown = false;
            }

            if (m_isMouseDown)
            {
                Vector3 _delta = m_camera.ScreenToViewportPoint(Input.mousePosition - m_lastMousePosition);
                SetCameraPosition(_delta * m_correntValue);
                m_lastMousePosition = Input.mousePosition;
            }
        }
    }

    private void SetCameraPosition(Vector3 _delta)
    {
        Vector3 _move = new Vector3(_delta.x, -_delta.y, -_delta.x);

        transform.Translate(_move, Space.World);

        Vector3 _pos = transform.position;

        _pos.x = Mathf.Clamp(transform.position.x, PositionBoundX.x, PositionBoundX.y);
        _pos.y = Mathf.Clamp(transform.position.y, PositionBoundY.x, PositionBoundY.y);
        _pos.z = Mathf.Clamp(transform.position.z, PositionBoundZ.x, PositionBoundZ.y);

        transform.position = _pos;
    }

    private void SetCameraPosition(Vector2 _delta)
    {
        transform.Translate(_delta.x * MovementSpeed, -_delta.y * MovementSpeed, -_delta.x * MovementSpeed);
        Vector3 _pos = transform.position;

        _pos.x = Mathf.Clamp(transform.position.x, PositionBoundX.x, PositionBoundX.y);
        _pos.y = Mathf.Clamp(transform.position.y, PositionBoundY.x, PositionBoundY.y);
        _pos.z = Mathf.Clamp(transform.position.z, PositionBoundZ.x, PositionBoundZ.y);

        transform.position = _pos;
    }
}
