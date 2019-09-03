using UnityEngine;

public class CameraController : MonoBehaviour
{
    public float MovementSpeed = 300f;
    public float RotationSpeed = 30f;
    public float ZoomSpeed = 8f;
    public float OutlineWidth = 0.5f;

    public Vector2 ViewPositionBound = new Vector2(-5, 5);
    public Vector2 ZoomValueBound = new Vector2(-3, 10);
    public Vector2 PitchBound = new Vector2(15f, 45f);
    public Vector2 RotationBound = new Vector2(100f, 170f);
    public Vector2 InitAngle = new Vector2(35f, 135f);

    private float m_mobileCorrection = 0.003f;
    private Vector2 m_lastMousePosition;

    private bool m_isMouseDown;
    private bool m_isMouseDownOne;
    private bool m_isFocusOn;

    private Vector2 m_angle;
    private Vector2 m_viewPoint;
    private float m_zoomValue;
    private float m_zoomTime;

    private float m_distanceBetweenFingers = 500f;

    private const float INIT_ZOOM_VALUE = 5f;

    private const string SELECTABLE = "SELECTABLE";

    private Camera m_camera;
    private GameObject m_target;

    private System.Action m_updateCamera;
    private void Awake()
    {
        m_camera = transform.GetComponent<Camera>();

        m_angle = new Vector2(InitAngle.x, InitAngle.y);
        m_viewPoint = Vector2.zero;
        m_zoomValue = INIT_ZOOM_VALUE;

        m_distanceBetweenFingers = Screen.width * 0.2f;

        updateCamera();
        m_updateCamera = UpdateEmpty;
    }

    void LateUpdate()
    {
        m_updateCamera();
    }
    void Update()
    {
        if (m_isFocusOn == true)
        {
            if (Input.GetKey(KeyCode.Escape))
            {
                m_isFocusOn = false;
                m_zoomTime = 0f;
                m_target.GetComponent<MeshRenderer>().material.SetFloat("_Outline", 0f);
                m_updateCamera = UpdateReset;
            }

            if (Input.touchSupported)
            {
                //rotate
                if (Input.touchCount == 2 && Input.GetTouch(0).phase == TouchPhase.Moved)
                {
                    Touch _touch0 = Input.GetTouch(0);
                    Touch _touch1 = Input.GetTouch(1);

                    float _touchDeltaMagnitude = (_touch0.position - _touch1.position).magnitude;

                    if (_touchDeltaMagnitude < m_distanceBetweenFingers)
                    {
                        SetCameraRotation(_touch0.deltaPosition * RotationSpeed * m_mobileCorrection);
                    }
                }
            }
            else
            {
                //rotate
                if (Input.GetMouseButtonDown(1))
                {
                    m_lastMousePosition = Input.mousePosition;
                    m_isMouseDownOne = true;
                }
                if (Input.GetMouseButtonUp(1))
                {
                    m_isMouseDownOne = false;
                }

                if (m_isMouseDownOne)
                {
                    Vector3 _delta = m_camera.ScreenToViewportPoint(m_lastMousePosition - (Vector2)Input.mousePosition);
                    SetCameraRotation(_delta * RotationSpeed);
                    m_lastMousePosition = Input.mousePosition;
                }
            }
        }

        else
        {
            if (Input.touchSupported)
            {
                //rotate
                if (Input.touchCount == 2 && Input.GetTouch(0).phase == TouchPhase.Moved)
                {
                    Touch _touch0 = Input.GetTouch(0);
                    Touch _touch1 = Input.GetTouch(1);

                    float _touchDeltaMagnitude = (_touch0.position - _touch1.position).magnitude;

                    if (_touchDeltaMagnitude < m_distanceBetweenFingers)
                    {
                        SetCameraRotation(_touch0.deltaPosition * RotationSpeed * m_mobileCorrection);
                    }
                }

                //move
                if (Input.touchCount == 1 && Input.GetTouch(0).phase == TouchPhase.Moved)
                {
                    SetCameraPosition(Input.GetTouch(0).deltaPosition * MovementSpeed * m_mobileCorrection);
                }

                //zoom
                if (Input.touchCount == 2 && Input.GetTouch(0).phase == TouchPhase.Moved)
                {
                    Touch _touch0 = Input.GetTouch(0);
                    Touch _touch1 = Input.GetTouch(1);

                    if ((_touch1.position - _touch0.position).magnitude > m_distanceBetweenFingers)
                    {
                        Vector2 _touch0PrevPos = _touch0.position - _touch0.deltaPosition;
                        Vector2 _touch1PrevPos = _touch1.position - _touch1.deltaPosition;
                        float _prevTouchDeltaMagnitude = (_touch0PrevPos - _touch1PrevPos).magnitude;
                        float _touchDeltaMagnitude = (_touch0.position - _touch1.position).magnitude;
                        float _deltaMagnitudeDiff = _prevTouchDeltaMagnitude - _touchDeltaMagnitude;

                        SetCameraZoom(-_deltaMagnitudeDiff * ZoomSpeed * m_mobileCorrection);
                    }
                }

                //focus
                if (Input.touchCount == 1 && Input.GetTouch(0).phase == TouchPhase.Ended)
                {
                    Touch _touch = Input.GetTouch(0);
                    SelectObject(_touch.position);
                }
            }
            else
            {
                //rotate
                if (Input.GetMouseButtonDown(1))
                {
                    m_lastMousePosition = Input.mousePosition;
                    m_isMouseDownOne = true;
                }
                if (Input.GetMouseButtonUp(1))
                {
                    m_isMouseDownOne = false;
                }

                if (m_isMouseDownOne)
                {
                    Vector3 _delta = m_camera.ScreenToViewportPoint(m_lastMousePosition - (Vector2)Input.mousePosition);
                    SetCameraRotation(_delta * RotationSpeed);
                    m_lastMousePosition = Input.mousePosition;
                }

                //move
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
                    Vector3 _delta = m_camera.ScreenToViewportPoint(m_lastMousePosition - (Vector2)Input.mousePosition);
                    SetCameraPosition(_delta * MovementSpeed);
                    m_lastMousePosition = Input.mousePosition;
                }

                //zoom
                float _zoomValue = Input.GetAxis("Mouse ScrollWheel");
                SetCameraZoom(_zoomValue * ZoomSpeed);

                //focus
                if (Input.GetMouseButtonUp(0))
                {
                    SelectObject(Input.mousePosition);
                }
            }
        }
    }

    private void updateCamera()
    {
        m_zoomValue = Mathf.Clamp(m_zoomValue, ZoomValueBound.x, ZoomValueBound.y);

        Vector3 cameraAngle = m_camera.transform.rotation.eulerAngles;
        cameraAngle.x = m_angle.x;
        cameraAngle.y = 360 - m_angle.y;
        m_camera.transform.rotation = Quaternion.Euler(cameraAngle);

        float pitchDeg2Rad = m_angle.x * Mathf.Deg2Rad;
        float rotateDeg2Rad = m_angle.y * Mathf.Deg2Rad;

        float distance = 12f + (m_zoomValue * (1 / Mathf.Sin(pitchDeg2Rad)));

        Vector3 cameraPos = m_camera.transform.localPosition;
        cameraPos.x = (Mathf.Cos(pitchDeg2Rad) * ((Mathf.Sin(rotateDeg2Rad) * distance) * 1f)) + m_viewPoint.x;
        cameraPos.y = (Mathf.Sin(pitchDeg2Rad) * distance) + m_viewPoint.y;
        cameraPos.z = (Mathf.Cos(pitchDeg2Rad) * ((Mathf.Cos(rotateDeg2Rad) * distance) * -1f)) - m_viewPoint.x;
        m_camera.transform.localPosition = cameraPos;
    }

    private void SetCameraPosition(Vector2 _delta)
    {
        float pitchDeg2Rad = m_angle.x * Mathf.Deg2Rad;
        float rotateDeg2Rad = m_angle.y * Mathf.Deg2Rad;

        Vector2 movedPos = Vector2.zero;
        movedPos.x = _delta.x * (m_zoomValue / (Screen.height * 0.5f));
        movedPos.y = _delta.y * (m_zoomValue / (Screen.height * 0.5f));

        m_viewPoint.x += movedPos.x;
        m_viewPoint.y += movedPos.x;

        m_viewPoint.x = Mathf.Clamp(m_viewPoint.x, ViewPositionBound.x, ViewPositionBound.y);
        m_viewPoint.y = Mathf.Clamp(m_viewPoint.y, ViewPositionBound.x, ViewPositionBound.y);

        updateCamera();
    }

    private void SetCameraRotation(Vector2 _delta)
    {
        m_angle.x += (_delta.y);
        m_angle.y += (_delta.x);

        m_angle.x = Mathf.Clamp(m_angle.x, PitchBound.x, PitchBound.y);
        m_angle.y = Mathf.Clamp(m_angle.y, RotationBound.x, RotationBound.y);

        updateCamera();
    }

    private void SetCameraZoom(float _zoomFactor)
    {
        m_zoomValue = m_zoomValue - _zoomFactor;
        updateCamera();
    }

    private void SelectObject(Vector2 _position)
    {

        var _ray = m_camera.ScreenPointToRay(_position);
        RaycastHit _hit;
        if (Physics.Raycast(_ray, out _hit))
        {
            var _selection = _hit.transform.gameObject;

            if (_selection.CompareTag(SELECTABLE))
            {
                m_isFocusOn = true;
                m_target = _selection;
                m_zoomTime = 0f;
                m_target.GetComponent<MeshRenderer>().material.SetFloat("_Outline", OutlineWidth);
                m_updateCamera = UpdateTarget;
            }
        }
    }
    private void UpdateTarget()
    {
        m_zoomTime += Time.deltaTime;
        m_zoomValue = Mathf.Lerp(m_zoomValue, ZoomValueBound.x, m_zoomTime);
        m_viewPoint = Vector2.Lerp(m_viewPoint, (new Vector2(m_target.transform.localPosition.x, m_target.transform.localPosition.z) * 0.5f), m_zoomTime);
        updateCamera();
    }

    private void UpdateReset()
    {
        m_zoomTime += Time.deltaTime;
        m_zoomValue = Mathf.Lerp(m_zoomValue, INIT_ZOOM_VALUE, m_zoomTime);
        m_viewPoint = Vector2.Lerp(m_viewPoint, Vector2.zero, m_zoomTime);
        m_angle = Vector2.Lerp(m_angle, InitAngle, m_zoomTime);

        updateCamera();

        if (m_zoomTime > 1f)
            m_updateCamera = UpdateEmpty;
    }
    private void UpdateEmpty()
    {

    }
}
