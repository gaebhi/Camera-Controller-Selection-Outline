using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HitController : MonoBehaviour
{
    private SkinnedMeshRenderer m_skin;
    private Material m_material;
    private float m_hit;
    private void Awake()
    {
        m_hit = 0;
        m_skin = GetComponent<SkinnedMeshRenderer>();
        m_material = m_skin.materials[0];

        StartCoroutine(Hit());
    }

    private IEnumerator Hit()
    {
        while (true)
        {
            ++m_hit;
            m_hit = m_hit % 2;
            Debug.Log(m_hit);
            m_material.SetFloat("_Hit", m_hit * 0.1f);
            yield return new WaitForSeconds(0.15f);
        }
    }
}
